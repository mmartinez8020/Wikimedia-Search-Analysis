setwd('/Users/mmartinez/Desktop/search_task/')
library("ggplot2")
library(ggplot2)
options(scipen=999)

data <- read.table("search_dataset.tsv",sep="\t", header=TRUE)

###Convert timestamp to date
data$timestamp <- strptime(data$timestamp,"%Y%m%d%H%M%S")

###Extract weekday and hour from date to create two new columns
data$Weekday <- weekdays(data$timestamp)
data$Hour <- substr(data$timestamp , 12,13)
data$TimeOfDay <- cut(as.numeric(data$Hour), 
                      breaks=c(0,6,12,18,24), 
                      labels=c("Early Morning","Morning","Afternoon","Evening"),
                      include.lowest=T)

###Average data by Weekday + Hour for d3 visual
averagedatedata <- aggregate(event_timeToDisplayResults ~ Weekday + Hour, data = results, FUN= "median" )
averagedatedata$Weekday <-factor(averagedatedata$Weekday, levels= c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday"))

##Heat map 
p <- ggplot(averagedatedata,aes(x = Hour, y = Weekday, fill = event_timeToDisplayResults )) 
p <- p + geom_tile(aes(fill=event_timeToDisplayResults), colour="white") 
p <- p + scale_fill_gradient(low = "white",high = "steelblue")
p








