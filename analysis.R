require(extrafont)
require(scales)
require(ggplot2)
library(data.table)
require(dplyr)
library(jsonlite)
library(lubridate)

setwd("~/Documents/FiveThirtyEight/interactives/mta-lost-found/data")

fileNames <- Sys.glob("*.json")
head(fileNames)

#get dates
date <- gsub(".json", "", fileNames)
View(date)

allData <- list()
for (fileName in fileNames) {
  data <- as.data.frame(fromJSON(fileName, flatten = TRUE))
  data$Date <- gsub(".json", "", fileName)
  allData[[fileName]] <- data
}

#combine all data 
combineData <- rbind.fill(allData)
data <- combineData
View(data)

#ONE BY ONE
aug17 <- as.data.frame(fromJSON("2014-08-17.json", flatten = TRUE))
aug17$Date <- c("2014-08-17")
View(aug17)
head(aug17)

aug18 <- as.data.frame(fromJSON("2014-08-18.json", flatten = TRUE))
View(aug18)

combined <-rbind.fill(aug17, aug18)
View(combined)
head(combined)


