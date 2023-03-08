#' ---
#' date: "`r format(Sys.Date())`"
#' output:
#'   html_document:
#'     keep_md: TRUE
#' ---

suppressPackageStartupMessages(library(dplyr))
library(tidyr)
library(ggplot2)
library(readr)

gap_dat <- read_tsv("07_gap-merged-with-continent.tsv") %>%
  mutate(
    country = factor(country),
    continent = factor(continent)
  ) %>%
  select(country, year, pop, gdpPercap, lifeExp, continent)
gap_dat %>% str()

#' During data exploration, I learned that most countries have data every five
#' years, e.g. 1952, 1957, 1962, and so on. Let's make that official.
gap_dat <- gap_dat %>%
  filter(year %% 5 == 2)
gap_dat %>% str()

#' Number of distinct values for year.
(n_years <- gap_dat$year %>% n_distinct())

#' Does every country contribute data for all years?
country_freq <- gap_dat %>%
  count(country)
country_freq$n %>% table()
#' No.

ggplot(country_freq, aes(x = n)) +
  geom_histogram(binwidth = 1)

#' Most countries do contribute data for 12 years. Who contributes less?
country_freq %>%
  filter(n < 12) %>%
  arrange(n) %>%
  print(n = nrow(.))

#' I will let these countries go.
gap_dat <- country_freq %>%
  filter(n > 11) %>%
  left_join(gap_dat) %>%
  select(-n) %>%
  droplevels() %>%
  arrange(country, year)
gap_dat %>% str()

## match variable order of the past
gap_dat <- gap_dat %>%
  select(country, continent, year, lifeExp, pop, gdpPercap)

write_tsv(gap_dat, "08_gap-every-five-years.tsv")
