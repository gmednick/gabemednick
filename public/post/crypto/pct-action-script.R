#!/usr/bin/env Rscript
#Rscript /Users/gmednick/Documents/crypto-pct-change-15m/pct-action-script.R 
#/Users/gmednick/Documents/crypto-pct-change-15m/
library(tidyverse)
library(tidyr)
library(plotly)
library(lubridate)
library(httr)
library(jsonlite)
library(viridis)
library(scales)
library(rvest)
library(cronR)
theme_set(theme_light())

scale_colour_discrete <- scale_colour_viridis_d

url_cg1 <- "https://www.coingecko.com/en"
url_cg2 <- "https://www.coingecko.com/en?page=2"

names <- read_html(url_cg1) %>%
  html_nodes('.font-bold.tw-justify-between') %>%
  html_text() %>%
  as_tibble()

names2 <- read_html(url_cg2) %>%
  html_nodes('.font-bold.tw-justify-between') %>%
  html_text() %>%
  as_tibble() %>% 
  filter(value != "USDP Stablecoin")

hourly <- read_html(url_cg1) %>%
  html_nodes('.change1h span') %>%
  html_text() %>%
  as_tibble() 

hourly2 <- read_html(url_cg2) %>%
  html_nodes('.change1h span') %>%
  html_text() %>%
  as_tibble()

hourly_df <- bind_cols(names, hourly) %>%
  rename("coin" = `value...1`, "hourly" = `value...2`) %>%
  mutate(coin = str_remove_all(coin, "\n"),
         hourly = parse_number(hourly))

# hourly_df2 <- bind_cols(names2, hourly2) %>%
#   rename("coin" = `value...1`, "hourly" = `value...2`) %>%
#   mutate(coin = str_remove_all(coin, "\n"),
#          hourly = parse_number(hourly))

#hourly_df200 <- bind_rows(hourly_df, hourly_df2)

granular_hourly <- hourly_df %>%
  mutate(change = case_when(hourly > 0 ~ "positive",
                            hourly <= 0 ~ "negative"),
         granular = case_when((hourly > 6) ~ "hot (>6%)",
                              (hourly > 4) & (hourly <= 6) ~ "toasty (4-6%)",
                              (hourly > 2) & (hourly <= 4) ~ "warm (2-4%)",
                              (hourly > 0) & (hourly <= 2) ~ "luke warm (0-2%)",
                              (hourly == 0) ~ "neutral (0%)",
                              (hourly <= 0) & (hourly >= -2)  ~ "chilly (-0-2%)",
                              (hourly <= -2) & (hourly > -4) ~ "cold (-2-4%)",
                              (hourly <= -4) &(hourly > -6) ~ "freezing (-4-6%)",
                              TRUE ~ "ice age (< -6%)"),
         granular = factor(granular,
                           levels = c("ice age (< -6%)", "freezing (-4-6%)", "cold (-2-4%)",
                                      "chilly (-0-2%)", "neutral (0%)", "luke warm (0-2%)", "warm (2-4%)",
                                      "toasty (4-6%)", "hot (>6%)")),
         time_stamp =  as_datetime(Sys.time()))


write_tsv(
  granular_hourly,
  '/Users/gmednick/Documents/crypto-pct-change-15m/granular_15min.tsv',
  na = "NA",
  col_names = TRUE,
  append = TRUE)
