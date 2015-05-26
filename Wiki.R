setwd('/Users/mmartinez/Desktop/Wikimedia_Analysis/')
library(ggplot2)
library(dplyr)
library(markdown)
library(reshape2)
library(gridExtra)
library(lubridate)
require(knitr) # required for knitting from rmd to md
require(markdown) # required for md to html 
options(scipen=999)



data <- read.table("search_dataset.tsv", sep="\t", header=TRUE)
summary(data)
###Convert timestamp to date
data$timestamp <- strptime(data$timestamp,"%Y%m%d%H%M%S")

###Extract weekday, hour, and month from date to create two new columns and date formatting
data$Weekday <- weekdays(data$timestamp)
data$Weekday <- factor(data$Weekday, levels= c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday"))

data$Hour <- substr(data$timestamp , 12,13)
data$Month <- months(data$timestamp)
data$Month <- factor(data$Month, levels= c("November","December","January","February","March","April","May"))
head(data)

##Bar plots

plottingfunction <- function(data, xlabel){
  newDf <- data.frame(table(data))
  orders <- newDf[order(newDf$Freq, decreasing = FALSE), ]$data
  newDf$data <- factor(newDf$data, orders)
  
  plot <- ggplot(newDf, aes(x = data, y = Freq)) +
    geom_bar(fill="lightblue", colour="black",stat = "identity") +
    xlab(xlabel) +
    ylab("Frequency") +
    coord_flip() +
    theme(axis.text=element_text(size=20),
          axis.title = element_text(size=40,face="bold"),
          plot.title = element_text(size =60, face="bold",lineheight=.8))
  
  return(plot)
}

eventactionbar <- plottingfunction(data$event_action,"Event Action")
weekdaybar <- plottingfunction(data$Weekday,"Weekday")
monthbar <- plottingfunction(data$Month,"Month")
grid.arrange(eventactionbar, weekdaybar, monthbar, ncol=3)


#####Histogram by Month

resulthist <- data[data$event_action == "results" & !(data$event_timeToDisplayResults < 2000), ] #Cut off long tail
nrow(resulthist)/nrow(data)
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

###Average data by Weekday + Hour for heatmap

results <- data[data$event_action == "results", ]
averagedatedata <- aggregate(event_timeToDisplayResults ~ Weekday + Hour, data = results, FUN= "median" )

##Heat map 
colnames(averagedatedata)[3] <- "Median"
eventheat <- ggplot(averagedatedata,aes(x = Hour, y = Weekday, fill = Median )) + 
                    geom_tile(aes(fill=Median), colour="white") +
                    scale_fill_gradient(low = "white",high = "steelblue") +
                    theme(axis.text=element_text(size=20),
                          axis.title=element_text(size=40,face="bold"),
                          legend.text=element_text(size=20),
                          legend.title=element_text(size=20)) 
eventheat

##Heat map of freq of actions

freqofactions <- data[ ,c(4,5)] %>% group_by(Weekday,Hour)  %>%
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

##Data preparation
datawithoutmonths <- data[!(data$Month == "November" | data$Month == "May"), ] ##Remove November and May dates from df
datawithoutmonths$date  <- as.Date(datawithoutmonths$timestamp)

datawithoutmonths$week <- cut(datawithoutmonths[,"date"],breaks = 'weeks')
df <- data.frame(table(datawithoutmonths$week,datawithoutmonths$event_action))
df$Var1 <- as.Date(df$Var1)

##Plotting
timeclicks <- ggplot(df[df$Var2 == "click",],aes(x=Var1,y=Freq)) + 
                                             xlab("Clicks") +
                                             geom_line() +
                                             theme(axis.text=element_text(size=20),
                                                  axis.title=element_text(size=40,face="bold"),
                                                  legend.text=element_text(size=20),
                                                  legend.title=element_text(size=20)) 

head(data[,c(4,6,7)])
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


