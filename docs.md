---
title: "Wikimedia Analysis"
author: "Mark Martinez"
date: "May 24, 2015"
output: html_document
---
# Data Exploration and Cleaning
In this analysis I will be looking over requests made on Wikimedia. The data set contains 1 million rows of requests made between November 25, 2014 and May 15, 2015.
The purpose of this analysis is going to try and better understand user behavior on Wikimedia over time. In order to facilitate my time based analysis the following data has been added using the `timestamp`.



```r
head(data[,c(4,6,7)])
```

```
##    Weekday TimeOfDay    Month
## 1 Saturday   Morning    March
## 2  Tuesday   Evening    March
## 3 Thursday   Evening February
## 4   Sunday   Morning    April
## 5 Saturday   Morning February
## 6 Saturday   Evening    April
```


First and foremost I want to get a general idea of the data I will examing by getting a general summary of my quantitative variables, which in this case are `event_timeToDisplayResults` and `timestampe`. 



```r
summary(data[ ,c(1,3)])
```

```
##    timestamp                   event_timeToDisplayResults
##  Min.   :2014-11-25 21:17:51   Min.   : -17501.0         
##  1st Qu.:2015-01-19 15:32:04   1st Qu.:    333.0         
##  Median :2015-02-28 05:14:06   Median :    446.0         
##  Mean   :2015-02-27 07:01:12   Mean   :    755.7         
##  3rd Qu.:2015-04-07 21:33:47   3rd Qu.:    620.0         
##  Max.   :2015-05-15 11:34:39   Max.   :1715767.0         
##  NA's   :204                   NA's   :306277
```

Our `event_timeToDisplayResults` has negative values, which is implausible and seems to be an error in how this data was recorded and there are `timestamp` that are equal to zero. In an attempt to maintain the integrity of the data, I will be remove rows where `event_timeToDisplayResults` $< 0$ and `timesamp` $= 0$.   


In addition to understanding our quantitative variables, I would also like to examine the frequency of our qualitative variables.

```r
library(knitr)

x <- data.frame(table(data$event_action))
y <- data.frame(table(data$TimeOfDay))

t1 = kable(x, format='html', output = FALSE)
t2 = kable(y, format='html', output = FALSE)
cat(c('<table><tr valign="top"><td>', t1, '</td><td>', t2, '</td><tr></table>'),
    sep = '')
```

<table><tr valign="top"><td><table>
 <thead>
  <tr>
   <th style="text-align:left;"> Var1 </th>
   <th style="text-align:right;"> Freq </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> start </td>
   <td style="text-align:right;"> 163943 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> results </td>
   <td style="text-align:right;"> 693723 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> click </td>
   <td style="text-align:right;"> 142334 </td>
  </tr>
</tbody>
</table></td><td><table>
 <thead>
  <tr>
   <th style="text-align:left;"> Var1 </th>
   <th style="text-align:right;"> Freq </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Early Morning </td>
   <td style="text-align:right;"> 218562 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Morning </td>
   <td style="text-align:right;"> 209191 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Afternoon </td>
   <td style="text-align:right;"> 294165 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Evening </td>
   <td style="text-align:right;"> 278082 </td>
  </tr>
</tbody>
</table></td><tr></table>
