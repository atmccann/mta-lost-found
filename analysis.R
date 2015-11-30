require(extrafont)
require(scales)
require(ggplot2)
library(data.table)
require(plyr)
require(dplyr)
require(tidyr)
library(jsonlite)
library(lubridate)

setwd("~/Documents/interactives/mta-lost-found/data")

fileNames <- Sys.glob("*.json")

allData <- list()
for (fileName in fileNames) {
  data <- as.data.frame(fromJSON(fileName, flatten = TRUE))
  data$date <- gsub(".json", "", fileName)
  allData[[fileName]] <- data
}

#combine all data using plyr
combineData <- rbind.fill(allData)
View(combineData)
data <- combineData
#set NA columns to 0 (electronics activity tracker)
data[is.na(data)] <- 0

View(data)
write.csv(data, file = "all-data.csv")

#CHART RAW VALUES BELOW
newData <- gather(data, items, amount, -date)
head(newData)

#plot raw counts
plot <- ggplot(newData, aes(x = date, y = amount, group = items, col = items)) +
  geom_line()

plot

detach(package:plyr)
#calculate monthly data for wallets
wallets <- select(data, Wallet.Purse.Wallet, date)
wallets$date <- parse_date_time(wallets$date, "%Y-%m-%d")
View(wallets)

wallets$Month <- months(wallets$date)
wallets$Year <- format(wallets$date, format='%y')

monData <- aggregate(Wallet.Purse.Wallet ~ Month + Year, wallets, mean)
View(monData)

#calculate weekly data for all items

View(data)
data$date <- parse_date_time(data$date, "%Y-%m-%d")
df <- data.frame(data)
col_idx <- grep("date", names(df))
df <- df[, c(col_idx, (1:ncol(df))[-col_idx])]
head(df)
View(df)

df$date <- parse_date_time(df$date, "%Y-%m-%d")
month <- month(df$date)

monthData <- df %>% mutate(month = month(date))
View(monthData)
head(monthData)

#CHART CHANGE FROM CSV
changeCSV <- read.csv("change.csv")
View(changeCSV)

changeCSV$date <- parse_date_time(changeCSV$date, "%m/%d/%y")
head(changeCSV)

gatherCSV <- gather(changeCSV, items, change, -date)
head(gatherCSV)

detach(package:plyr)
#filter out items with change less than 10%, but this isn't what i want :/
smallerCSV <- gatherCSV %>% 
  group_by(items) %>% 
  mutate(smallChanger=ifelse(max(change)<0.1, TRUE, FALSE)) %>% 
  filter(smallChanger==FALSE) %>% 
  ungroup()


plot <- ggplot(smallerCSV, aes(x = date, y = change, group = items, col = items)) +
  scale_y_continuous(labels=percent) +
  geom_line()

plot

  
