# GLOBAL FILE

library(shiny)
library(quantmod)
library(TTR)
library(tidyverse)
library(timetk)
library(lubridate)
library(rvest)
library(robotstxt)
library(plotly)
library(zoo)
library(DT)
library(shinythemes)
library(shinydashboard)
library(dashboardthemes)


# Checking if webscraping is legal for those websites
paths_allowed("https://en.wikipedia.org/")
paths_allowed("https://uk.finance.yahoo.com/") 


# Ticker Symbols of Dow 30 Companies
# Scraping Ticker Symbols of Dow30 from Wikipedia
url <- "https://en.wikipedia.org/wiki/Dow_Jones_Industrial_Average"

webpage <- read_html(url) #Reading the HTML code from the website

table_wiki <- webpage %>% # scraping tables from website
  html_table(fill = TRUE)


# subsetting and wrangling table of interest
table_wiki <- as.data.frame(table_wiki[[2]]) %>% 
  select(- Exchange,
         - `Date added`,
         - Notes,
         - `Index weighting`)


# web scraping tool, scraping stock data from yahoo finance
scraper_getsymbols <- function(tkr, timespan) {
  
  df <- as.data.frame(getSymbols(tkr,
                                 src='yahoo',
                                 from = timespan,
                                 to = Sys.Date(),
                                 auto.assign=FALSE)) 
  
  # date are initially row names -> converting  into own column
  df$date <- row.names(df)
  row.names(df) <- seq(1 : dim(df)[1])
  
  # data cleaning
  df <- df %>% 
    rename(Open = 1,
           High = 2,
           Low = 3,
           Close = 4,
           Volume = 5, 
           Adjusted = 6) %>% 
    select(date, everything()) %>% 
    mutate(date = ymd(date),
           roll_avg = rollmean(Close, k = 7, fill = NA)) # rolling average 
  
  # calculating log returns
  df$log_returns <- c(NA,
                      sapply(2 : dim(df)[1], function(i){
                        log(df$Close[i]/df$Close[i-1])
                      }))
  
  return(df)
}


# data frame for time span
timespan <- data.frame(names = c("6 month",
                                 "12 month",
                                 "24 month"),
                       values = c(Sys.Date() - months(6),
                                  Sys.Date() - years(1),
                                  Sys.Date() - years(2)))

