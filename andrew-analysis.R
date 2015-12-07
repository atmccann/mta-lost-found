
require(readr)
require(ggplot2)
require(dplyr)
require(tidyr)

setwd("~/Documents/interactives/mta-lost-found/")

rawData <- read_csv("./data/all-data.csv")

#see dates
dates <- rawData %>% select(date)

#move date to front, select columns we want
cleanData <- rawData %>% select(222, 2:221, 223:224)  %>%
            filter(date<as.Date("2015-07-01"))

#items tallies, get rid of date
items <- unique(cleanData %>% select(-date) %>% names())

#change over time for one thing, as a count 
umbrellaData <- cleanData %>% select(date, Accessories.Umbrella) %>%
          mutate(change=Accessories.Umbrella-lag(Accessories.Umbrella))

#change over time for one thing, as a percent
umbrellaPerc <- cleanData %>% select(date, Accessories.Umbrella) %>%
  mutate(change=((Accessories.Umbrella-lag(Accessories.Umbrella))/lag(Accessories.Umbrella))*100)


plot <- ggplot(umbrellaPerc, aes(date, change)) + geom_line()
plot

#gather 
cleanData %>% gather(items, total, -date) %>% 
    filter(date %>% c(dates[1], dates[242])) %>% 
    group_by(item)
    summarize
    
    



