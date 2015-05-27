setwd('/Users/mmartinez/Desktop/Wikimedia-Search-Analysis')
require(ggplot2)
require(dplyr)
require(markdown)
require(reshape2)
require(gridExtra)
require(knitr) 
require(markdown) 
require(rmarkdown)
options(scipen=999)

request <- read.table("search_dataset.tsv", sep = "\t", header = TRUE)

###Convert timestamp to date
request$timestamp <- strptime(request$timestamp, "%Y%m%d%H%M%S")

###Extract weekday, hour, and month from date to create two new columns and date formatting
request$Weekday <- weekdays(request$timestamp)
request$Weekday <- factor(request$Weekday, levels= c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))

request$Hour <- substr(request$timestamp , 12, 13)

request$Month <- months(request$timestamp)
request$Month <- factor(request$Month, levels = c("November", "December", "January", "February", "March", "April", "May"))


###Bar plots
plottingfunction <- function(request, xlabel){
  newDf <- data.frame(table(request))
  orders <- newDf[order(newDf$Freq, decreasing = FALSE), ]$request
  newDf$request <- factor(newDf$request, orders)
  
  plot <- ggplot(newDf, aes(x = request, y = Freq)) +
    geom_bar(fill = "lightblue", colour = "black", stat = "identity") +
    xlab(xlabel) +
    ylab("Frequency") +
    coord_flip() +
    theme(axis.text = element_text(size = 20),
          axis.title = element_text(size = 40, face="bold"),
          plot.title = element_text(size = 60, face="bold", lineheight=.8))
  
  return(plot)
}

eventactionbar <- plottingfunction(request$event_action, "Event Action")
weekdaybar <- plottingfunction(request$Weekday, "Weekday")
monthbar <- plottingfunction(request$Month, "Month")

grid.arrange(eventactionbar, weekdaybar, monthbar, ncol=3)


###Histogram of event_timeToDisplayResults
resulthist <- request[request$event_action == "results" & (request$event_timeToDisplayResults < 2000), ] #Cut off long tail
resulthist <- resulthist[resulthist$event_timeToDisplayResults > 0, ]

resulthistogram <- ggplot(resulthist, aes(x = event_timeToDisplayResults, y = ..density..)) + 
                      geom_histogram(fill = "white", colour = "black") + 
                      xlab("Time to Display Results") + 
                      ylab("Density") +
                      ggtitle("Histogram of Time to Display Results") +
                      theme(axis.text=element_text(size = 15),
                            axis.title = element_text(size = 30,face = "bold"),
                            plot.title = element_text(size = 45, face = "bold",lineheight = .8))

resulthistogram

###Average request by Weekday + Hour for heat map
results <- request[request$event_action == "results", ]
averagedaterequest <- aggregate(event_timeToDisplayResults ~ Weekday + Hour, data = results, FUN= "median" )


###Heat map for event_timeToDisplayResults
colnames(averagedaterequest)[3] <- "Median"
eventheat <- ggplot(averagedaterequest,aes(x = Hour, y = Weekday, fill = Median )) + 
              geom_tile(aes(fill = Median), colour = "white") +
              scale_fill_gradient(low = "white",high = "steelblue") +
              theme(axis.text = element_text(size = 20),
                    axis.title = element_text(size = 40,face="bold"),
                    legend.text = element_text(size = 20),
                    legend.title = element_text(size = 20)) 

eventheat

###Heat map of frequency of actions
freqofactions <- request[ ,c(4,5)]  %>%  group_by(Weekday, Hour)  %>%
  summarize(Count = n())

heataction <- ggplot(freqofactions,aes(x = Hour, y = Weekday, fill = Count )) +
                geom_tile(aes(fill = Count), colour = "white") +
                scale_fill_gradient(low = "white",high = "steelblue") +
                theme(axis.text = element_text(size = 20),
                      axis.title = element_text(size = 40,face = "bold"),
                      legend.text = element_text(size = 20),
                      legend.title = element_text(size = 20)) 



###Time series

##request preparation
requestwithoutmonths <- request[!(request$Month == "November" | request$Month == "May"), ] ##Remove November and May dates from df
requestwithoutmonths$date  <- as.Date(requestwithoutmonths$timestamp)

requestwithoutmonths$week <- cut(requestwithoutmonths[,"date"],breaks = 'weeks')
timeseries <- data.frame(table(requestwithoutmonths$week, requestwithoutmonths$event_action))
timeseries$Var1 <- as.Date(timeseries$Var1)
head(timeseries)
##Plotting
timeseriesplot <- function(action, label){
  plot <- ggplot(timeseries[timeseries$Var2 == action,],aes(x = Var1,y = Freq)) +
            xlab(label) +
            geom_line() +
            theme(axis.text=element_text(size = 10),
            axis.title=element_text(size = 20),
            legend.text=element_text(size = 10),
            legend.title=element_text(size = 10)) 
  return(plot)
}

timestarts <- timeseriesplot("start", "Starts")
timeclicks <- timeseriesplot("click", "Clicks")
timeresults <- timeseriesplot("results", "Results")


grid.arrange(timeclicks,timestarts,timeresults,main = textGrob("Event Action by Week", gp = gpar(fontsize = 20)))
 
knit('markup.rmd', 'docs.md')
markdownToHTML('docs.md', 'WikimediaAnalysis.html', header = TRUE)
render("markup.Rmd", "pdf_document")
