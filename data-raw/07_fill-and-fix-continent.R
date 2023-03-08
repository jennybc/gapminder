#' ---
#' date: "`r format(Sys.Date())`"
#' output:
#'   html_document:
#'     keep_md: TRUE
#' ---

library(plyr)
suppressPackageStartupMessages(library(dplyr))
library(ggplot2)
library(readr)

gap_dat <- read_tsv("05_gap-merged-with-china-1952.tsv") %>%
  mutate(
    country = factor(country),
    continent = factor(continent)
  )
gap_dat %>% str()
gap_dat$continent %>% summary()

#' Hmmmmm .... I've never heard of the continent of FSU.
tmp <- gap_dat %>%
  filter(continent == "FSU") %>%
  droplevels()
tmp$country %>% levels()
#' Aha. FSU = Former Soviet Union.

#' Which countries do not have continent data?
tmp <- gap_dat %>%
  filter(is.na(continent)) %>%
  droplevels()
tmp$country %>% levels()

#' Populate missing values of continent.
cont_dat <- frame_data(
  ~country, ~continent,
  "Armenia", "FSU",
  "Aruba", "Americas",
  "Australia", "Oceania",
  "Bahamas", "Americas",
  "Barbados", "Americas",
  "Belize", "Americas",
  "Canada", "Americas",
  "French Guiana", "Americas",
  "French Polynesia", "Oceania",
  "Georgia", "FSU",
  "Grenada", "Americas",
  "Guadeloupe", "Americas",
  "Haiti", "Americas",
  "Hong Kong, China", "Asia",
  "Maldives", "Asia",
  "Martinique", "Americas",
  "Micronesia, Fed. Sts.", "Oceania",
  "Netherlands Antilles", "Americas",
  "New Caledonia", "Oceania",
  "Papua New Guinea", "Oceania",
  "Reunion", "Africa",
  "Samoa", "Oceania",
  "Sao Tome and Principe", "Africa",
  "Tonga", "Oceania",
  "Uzbekistan", "FSU",
  "Vanuatu", "Oceania"
)

gap_dat <- gap_dat %>%
  ## 2015-12-29
  ## dplyr bug means we can't use inner_join right now
  ## https://github.com/hadley/dplyr/issues/1559
  # left_join(cont_dat, by = "country") %>%
  merge(cont_dat, by = "country", all = TRUE) %>%
  tbl_df() %>%
  mutate(
    continent = factor(ifelse(is.na(continent.y),
      as.character(continent.x),
      as.character(continent.y)
    )),
    continent.x = NULL,
    continent.y = NULL
  ) %>%
  arrange(country, year)
gap_dat %>% str()
gap_dat$continent %>% summary()

my_vars <- c(
  "country", "continent", "year",
  "lifeExp", "pop", "gdpPercap"
)
gap_dat <- gap_dat[my_vars]

write_tsv(gap_dat, "07_gap-merged-with-continent.tsv")
