library(dashboardthemes)
library(DT)
library(lubridate)
library(plotly)
library(quantmod)
library(robotstxt)
library(rvest)
library(shiny)
library(shinydashboard)
library(tidyverse)
library(zoo)
library(renv)

# Check if web scraping is legal
paths_allowed("https://en.wikipedia.org/")
paths_allowed("https://uk.finance.yahoo.com/")

# Ticker Symbols of Dow 30 Companies
# Scrape Ticker Symbols of Dow30 from Wikipedia
url <- "https://en.wikipedia.org/wiki/Dow_Jones_Industrial_Average"

# Read the HTML code from website
webpage <- read_html(url)

# Scrape tables from website
table_wiki <- webpage %>%
  html_table(fill = TRUE)

# subset and wrangle table of interest
table_wiki <- as.data.frame(table_wiki[[2]]) %>%
  select(
    -Exchange,
    -`Date added`,
    -Notes,
    -`Index weighting`
  )

# Create web scraping tool for scraping stock data from yahoo finance
scraper_get_symbols <- function(tkr, timespan) {
  df <- as.data.frame(getSymbols(tkr,
    src = "yahoo",
    from = timespan,
    to = Sys.Date(),
    auto.assign = FALSE
  ))

  # Convert dates from being row names to having their own column
  df$date <- row.names(df)
  row.names(df) <- seq(1:dim(df)[1])

  # Clean data
  df <- df %>%
    rename(
      Open = 1,
      High = 2,
      Low = 3,
      Close = 4,
      Volume = 5,
      Adjusted = 6
    ) %>%
    select(date, everything()) %>%
    mutate(
      date = ymd(date),
      roll_avg = rollmean(Close, k = 7, fill = NA)
    )

  # Calculate log returns
  df$log_returns <- c(
    NA,
    sapply(2:dim(df)[1], function(i) {
      log(df$Close[i] / df$Close[i - 1])
    })
  )

  return(df)
}

# Create data frame for time span
timespan <- data.frame(
  names = c(
    "6 month",
    "12 month",
    "24 month"
  ),
  values = c(
    Sys.Date() - months(6),
    Sys.Date() - years(1),
    Sys.Date() - years(2)
  )
)
