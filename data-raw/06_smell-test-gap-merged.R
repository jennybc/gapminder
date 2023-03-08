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

#' Do we have NAs?
gap_dat %>%
  sapply(function(x) {
    x %>%
      is.na() %>%
      sum()
  })

#' year
gap_dat$year %>% summary()

#' Confirming we have 1950, 1951, ..., 2007
all.equal(gap_dat$year %>% unique() %>% sort(), 1950:2007)

#' How much data do we have for each year?
ggplot(gap_dat, aes(x = year)) +
  geom_histogram(binwidth = 1)
#' Most countries have data every five years, e.g. 1952, 1957, 1962, and so on.

#' country
gap_dat$country %>% str()
country_freq <- gap_dat %>%
  count(country)
ggplot(country_freq, aes(x = country, y = n)) +
  geom_bar(stat = "identity") # ugly but worth seeing
(p <- ggplot(country_freq, aes(x = n)) +
  geom_histogram(binwidth = 1))
p + xlim(c(1, 16))
country_freq$n %>% table()
#' Most countries have data for 12 years, i.e. the years highlighted above. Some
#' have data for 58 years, which I assume is the maximum. Otherwise, there's a
#' little bit of everything between 1 and 58.

#' continent
gap_dat$continent %>% levels()
gap_dat$continent %>% summary()
#' 301 rows have no continent data :( but we already knew that.

#' Is continent data uniform for all rows pertaining to one country?
tmp <- gap_dat %>%
  group_by(country) %>%
  summarize(n_continent = n_distinct(continent))
tmp$n_continent %>% table()
#' Yes, a minor miracle. All 187 countries have exactly 1 associated value of
#' continent.
#'
#' Fixing the continent data is a separate task to be tackled in the next
#' script.

#' population
gap_dat$pop %>% summary(digits = 10)

#' We have little countries
gap_dat[which.min(gap_dat$pop), ]
#' like Aruba w/ 60K people
#'
#' and big countries
gap_dat[which.max(gap_dat$pop), ]
#' like China w/ 1.3B people

ggplot(gap_dat, aes(x = pop)) +
  geom_density() +
  scale_x_log10()

#' life expectancy
gap_dat$lifeExp %>% summary()
#' This is comptible with normal human life span. Yay.
ggplot(gap_dat, aes(x = lifeExp)) +
  geom_density()
#' Note bimodality. Modes ~ 42 and 72.

gap_dat$gdpPercap %>% summary()
#' $113K???? really?
gap_dat[which.max(gap_dat$gdpPercap), ]
#' OIL!  Kuwait, 1957. Or maybe a data quality problem.
#' <https://github.com/jennybc/gapminder/issues/9>
ggplot(gap_dat, aes(x = gdpPercap)) +
  geom_density()
#' Looks plausible. Loooong right tail.
#'
#' Nothing looks completely insane. Done.
