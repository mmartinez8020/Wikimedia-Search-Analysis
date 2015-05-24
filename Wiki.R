setwd('/Users/mmartinez/Desktop/Wikimedia Analysis//')
library("ggplot2")
library(ggplot2)
options(scipen=999)

data <- read.table("search_dataset.tsv", sep="\t", header=TRUE)

###Convert timestamp to date
data$timestamp <- strptime(data$timestamp,"%Y%m%d%H%M%S")

###Extract weekday and hour from date to create two new columns
data$Weekday <- weekdays(data$timestamp)
data$Weekday <- factor(data$Weekday, levels= c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday"))
data$Hour <- substr(data$timestamp , 12,13)
data$TimeOfDay <- cut(as.numeric(data$Hour), 
                      breaks=c(0,6,12,18,24), 
                      labels=c("Early Morning","Morning","Afternoon","Evening"),
                      include.lowest=T)
head(data)
###Average data by Weekday + Hour for d3 visual
results <- data[data$event_action == "results", ]
head(results)
averagedatedata <- aggregate(event_timeToDisplayResults ~ Weekday + Hour, data = results, FUN= "median" )

##Heat map 
p <- ggplot(averagedatedata,aes(x = Hour, y = Weekday, fill = event_timeToDisplayResults )) 
p <- p + geom_tile(aes(fill=event_timeToDisplayResults), colour="white") 
p <- p + scale_fill_gradient(low = "white",high = "steelblue")
p

weekday_freq <- data.frame(table(data$Weekday))
weekday_freq <- weekday_freq[sort(weekday_freq$Var1), ]

##Bar plot of freq of different weekdays
ggplot(weekday_freq, aes(factor(Var1), y = as.numeric(Freq))) + 
  geom_bar(colour = "black", fill = "#DD8888", width = .8, stat = "identity") + 
  coord_flip()
