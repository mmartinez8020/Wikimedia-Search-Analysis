setwd('/Users/mmartinez/Desktop/Wikimedia-Search-Analysis')
require(ggplot2)
require(dplyr)
require(markdown)
require(reshape2)
require(gridExtra)
require(knitr) 
require(markdown) 
options(scipen=999)

request <- read.table("search_dataset.tsv", sep="\t", header=TRUE)

###Convert timestamp to date
request$timestamp <- strptime(request$timestamp,"%Y%m%d%H%M%S")

###Extract weekday, hour, and month from date to create two new columns and date formatting
request$Weekday <- weekdays(request$timestamp)
request$Weekday <- factor(request$Weekday, levels= c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday"))

request$Hour <- substr(request$timestamp , 12,13)
request$Month <- months(request$timestamp)
request$Month <- factor(request$Month, levels= c("November","December","January","February","March","April","May"))
head(request)

##Bar plots

plottingfunction <- function(request, xlabel){
  newDf <- data.frame(table(request))
  orders <- newDf[order(newDf$Freq, decreasing = FALSE), ]$request
  newDf$request <- factor(newDf$request, orders)
  
  plot <- ggplot(newDf, aes(x = request, y = Freq)) +
    geom_bar(fill="lightblue", colour="black",stat = "identity") +
    xlab(xlabel) +
    ylab("Frequency") +
    coord_flip() +
    theme(axis.text=element_text(size=20),
          axis.title = element_text(size=40,face="bold"),
          plot.title = element_text(size =60, face="bold",lineheight=.8))
  
  return(plot)
}

eventactionbar <- plottingfunction(request$event_action,"Event Action")
weekdaybar <- plottingfunction(request$Weekday,"Weekday")
monthbar <- plottingfunction(request$Month,"Month")
grid.arrange(eventactionbar, weekdaybar, monthbar, ncol=3)


#####Histogram by Month

resulthist <- request[request$event_action == "results" & !(request$event_timeToDisplayResults < 2000), ] #Cut off long tail
nrow(resulthist)/nrow(request)
resulthist <- resulthist[resulthist$event_timeToDisplayResults > 0, ]#Remove values less than 0

resulthistogram <- ggplot(resulthist, aes(x=event_timeToDisplayResults, y = ..density..)) + 
                          geom_histogram(fill="white", colour="black") + 
                          xlab("Time to Display Results") + 
                          ylab("Density") +
                          ggtitle("Histogram of Time to Display Results") +
                          theme(axis.text=element_text(size=20),
                                axis.title = element_text(size=40,face="bold"),
                                plot.title = element_text(size =60, face="bold",lineheight=.8))
resulthistogram

###Average request by Weekday + Hour for heatmap

results <- request[request$event_action == "results", ]
averagedaterequest <- aggregate(event_timeToDisplayResults ~ Weekday + Hour, request = results, FUN= "median" )

##Heat map 
colnames(averagedaterequest)[3] <- "Median"
eventheat <- ggplot(averagedaterequest,aes(x = Hour, y = Weekday, fill = Median )) + 
                    geom_tile(aes(fill=Median), colour="white") +
                    scale_fill_gradient(low = "white",high = "steelblue") +
                    theme(axis.text=element_text(size=20),
                          axis.title=element_text(size=40,face="bold"),
                          legend.text=element_text(size=20),
                          legend.title=element_text(size=20)) 
eventheat

##Heat map of freq of actions

freqofactions <- request[ ,c(4,5)] %>% group_by(Weekday,Hour)  %>%
  summarize(Count = n())
head(freqofactions)
heataction <- ggplot(freqofactions,aes(x = Hour, y = Weekday, fill = Count )) +
                      geom_tile(aes(fill=Count), colour="white") +
                      scale_fill_gradient(low = "white",high = "steelblue") +
                      labs(colour = "Median") +
                      theme(axis.text=element_text(size=20),
                            axis.title=element_text(size=40,face="bold"),
                            legend.text=element_text(size=20),
                            legend.title=element_text(size=20)) 

heataction
################################
#########Time series############
################################

##request preparation
requestwithoutmonths <- request[!(request$Month == "November" | request$Month == "May"), ] ##Remove November and May dates from df
requestwithoutmonths$date  <- as.Date(requestwithoutmonths$timestamp)

requestwithoutmonths$week <- cut(requestwithoutmonths[,"date"],breaks = 'weeks')
df <- data.frame(table(requestwithoutmonths$week,requestwithoutmonths$event_action))
df$Var1 <- as.Date(df$Var1)

##Plotting
timeclicks <- ggplot(df[df$Var2 == "click",],aes(x=Var1,y=Freq)) + 
                                             xlab("Clicks") +
                                             geom_line() +
                                             theme(axis.text=element_text(size=20),
                                                  axis.title=element_text(size=40,face="bold"),
                                                  legend.text=element_text(size=20),
                                                  legend.title=element_text(size=20)) 


#time series for clicks
timeresults <- ggplot(df[df$Var2 == "results",],aes(x=Var1,y=Freq)) + 
                                            xlab("Results") +
                                            geom_line() +
                                            theme(axis.text=element_text(size=20),
                                                  axis.title=element_text(size=40,face="bold"),
                                                  legend.text=element_text(size=20),
                                                  legend.title=element_text(size=20)) 

timestarts <- ggplot(df[df$Var2 == "start",],aes(x=Var1,y=Freq)) +
                                            xlab("Starts") +
                                            geom_line() +
                                            theme(axis.text=element_text(size=20),
                                                  axis.title=element_text(size=40,face="bold"),
                                                  legend.text=element_text(size=20),
                                                  legend.title=element_text(size=20)) 

grid.arrange(timeclicks,timestarts,timeresults,main = textGrob("Event Action by Week",gp=gpar(fontsize=60)))
require(knitr) # required for knitting from rmd to md
require(markdown) # required for md to html 
knit('markup.rmd', 'docs.md')
markdownToHTML('docs.md', 'WikimediaAnalysis.html',header = TRUE)


