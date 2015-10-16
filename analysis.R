require(extrafont)
require(scales)
require(ggplot2)
library(data.table)
require(dplyr)
require(tidyr)
library(jsonlite)
library(lubridate)

setwd("~/Documents/FiveThirtyEight/interactives/mta-lost-found/data")

fileNames <- Sys.glob("*.json")
View(fileNames)

allData <- list()
for (fileName in fileNames) {
  data <- as.data.frame(fromJSON(fileName, flatten = TRUE))
  data$date <- gsub(".json", "", fileName)
  allData[[fileName]] <- data
}

#combine all data 
combineData <- rbind.fill(allData)
data <- combineData
#set NA columns to 0 (electronics activity tracker)
data[is.na(data)] <- 0

#trying to calc percent change, but doesn't work because of files without certain columns? 
change <- cbind(date=data$date,apply(data[c(-which(names(data)=="date"))],2,function(x)x/x[1]-1))
View(change)
head(change)
tail(change)

#force date
change$date <- parse_date_time(change$date, "%Y-%m-%d")
head(change)

#try to gather change data
changeData <- gather(change, items, change, -date)
View(changeData)

#gather on raw value data
newData <- gather(data, items, amount, -date)

#plot raw counts
plot <- ggplot(newData, aes(x = date, y = amount, group = items, col = items)) +
  geom_line()

plot


