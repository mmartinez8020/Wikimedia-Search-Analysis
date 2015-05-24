
setwd('/Users/mmartinez/Desktop/search_task/')
data <- read.table("search_dataset.tsv",sep="\t", header=TRUE)
options(scipen=999)
head(data)
###Convert timestamp to date
data$timestamp <- strptime(data$timestamp,"%Y%m%d%H%M%S")

###Extract weekday and hour from date to create two new columns
data$Weekday <- weekdays(data$timestamp)
data$Hour <- substr(data$timestamp , 12,13)

###Average data by Weekday + Hour for d3 visual
averagedatedata <- aggregate(event_timeToDisplayResults ~ Weekday + Hour, data = results, FUN= "mean" )
averagedatedata$Weekday <-factor(averagedatedata$Weekday, levels= c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday"))


#paste(datedata[order(datedata$Weekday),]$event_timeToDisplayResults,collapse=",")




