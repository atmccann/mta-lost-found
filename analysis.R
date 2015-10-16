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

data$date <- parse_date_time(data$date, "%Y-%m-%d")
head(data)

newData <- gather(data, items, amount, -date)
View(newData)

plot <- ggplot(newData, aes(x = date, y = amount, group = items, col = items)) +
  geom_line()

plot


