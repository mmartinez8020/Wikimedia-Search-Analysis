library("ggplot2")
library(ggplot2)
setwd('/Users/mmartinez/Desktop/search_task/')
data <- read.table("search_dataset.tsv",sep="\t", header=TRUE)
options(scipen=999)
head(data)
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


p <- ggplot(averagedatedata,aes(x = Hour, y = Weekday, fill = event_timeToDisplayResults )) 
p + geom_tile(aes(fill=event_timeToDisplayResults), colour="white") + scale_fill_gradient(low = "white",high = "steelblue")


paste(datedata[order(datedata$Weekday),]$event_timeToDisplayResults,collapse=",")
paste(seq(1,(168*100),by=100),collapse=",")






