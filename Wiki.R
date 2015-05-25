setwd('/Users/mmartinez/Desktop/Wikimedia_Analysis/')
library(ggplot2)
library(dplyr)
library(markdown)
library(reshape2)
require(knitr) # required for knitting from rmd to md
require(markdown) # required for md to html 
options(scipen=999)

data <- read.table("search_dataset.tsv", sep="\t", header=TRUE)

###Convert timestamp to date
data$timestamp <- strptime(data$timestamp,"%Y%m%d%H%M%S")

data$event_action <- factor(data$event_action, levels = c("start","results","click"))
###Extract weekday and hour from date to create two new columns and date formatting
data$Weekday <- weekdays(data$timestamp)
data$Weekday <- factor(data$Weekday, levels= c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday"))

data$Hour <- substr(data$timestamp , 12,13)

data$TimeOfDay <- cut(as.numeric(data$Hour), 
                      breaks=c(0,6,12,18,24), 
                      labels=c("Early Morning","Morning","Afternoon","Evening"),
                      include.lowest=T)

data$Month <- months(data$timestamp)
data$Month <- factor(data$Month, levels= c("November","December","January","February","March","April","May"))




###Time Series by Month
overMonths <- data.frame(table(data$event_action, data$Month))
colnames(overMonths)[3] <- "counts"

ggplot(overMonths[!overMonths$Var2 == "November", ], aes(x=Var2, y=counts, colour=Var1,group=Var1)) +
  geom_line()

ggplot(df,aes(x=weeks,y=Freq,colour=event_action,group=event_action)) + geom_line()


##Bar plots

plottingfunction <- function(data, xlabel){
  newDf <- data.frame(table(data))
  orders <- newDf[order(newDf$Freq, decreasing = FALSE), ]$data
  newDf$data <- factor(newDf$data, orders)
  
  plot <- ggplot(newDf, aes(x = data, y = Freq)) +
    geom_bar(fill="lightblue", colour="black",stat = "identity") +
    xlab(xlabel) +
    ylab("Frequency") +
    coord_flip()
  
  return(plot)
}


plottingfunction(data$event_action,"Event Action")
plottingfunction(data$Weekday,"Weekday")
plottingfunction(data$Weekday,"Month")


#####Histogram by Month

resulthist <- data[data$event_action == "results" & (data$event_timeToDisplayResults < 1500), ]
resulthist <- resulthist[resulthist$event_timeToDisplayResults > 0, ]
ggplot(resulthist, aes(x=event_timeToDisplayResults)) + geom_histogram(fill="white", colour="black") 


###Average data by Weekday + Hour for d3 heatmap

results <- data[data$event_action == "results", ]
averagedatedata <- aggregate(event_timeToDisplayResults ~ Weekday + Hour, data = results, FUN= "median" )

##Heat map 
p <- ggplot(averagedatedata,aes(x = Hour, y = Weekday, fill = event_timeToDisplayResults )) 
p <- p + geom_tile(aes(fill=event_timeToDisplayResults), colour="white") 
p <- p + scale_fill_gradient(low = "white",high = "steelblue")
p


##Bar plot of freq of actions
df <- data[ ,c(4,5)] %>% group_by(Weekday,Hour)  %>%
  summarize(Count = n())

p <- ggplot(df,aes(x = Hour, y = Weekday, fill = Count )) 
p <- p + geom_tile(aes(fill=Count), colour="white") 
p <- p + scale_fill_gradient(low = "white",high = "steelblue")
p

require(knitr) # required for knitting from rmd to md
require(markdown) # required for md to html 
knit('markup.rmd', 'docs.md')
markdownToHTML('docs.md', 'test.html')
