#' ---
#' date: "`r format(Sys.Date())`"
#' output:
#'   html_document:
#'     keep_md: TRUE
#' ---

#' Cleaning history
#'
#' * 2010: The first time I documented cleaning this dataset. I started with
#' delimited files I exported from Excel.
#' * 2014: I re-cleaned the data and (mostly) forced myself to pull it straight
#' out of the spreadsheets. Used the gdata package.
#' * 2015: I revisited the cleaning and switched to the readxl and readr
#' packages.

library(readxl)
suppressPackageStartupMessages(library(dplyr))
library(ggplot2)
library(readr)

#' Extract the life expectancy data from the Excel file downloaded 2009-04-21
#' from gapminder.org.

#+ warning=FALSE
le_xls <-
  read_excel("xls/life-expectancy-reference-spreadsheet-20090204-xls-format.xls",
    sheet = "Data and metadata"
  )
## the DEFINEDNAME thing is described here
## https://github.com/hadley/readxl/issues/82#issuecomment-166767220
## I am hiding a crapton of warnings

le_xls %>% str()

#' Select and rename vars.
le_raw <- le_xls %>%
  select(
    country = contains("country"), continent = contains("continent"),
    year = contains("year"), lifeExp = contains("expectancy")
  )
le_raw %>% str()
## 2015: 52416 obs. of 4 variables
## 2014: 52419 obs. of 4 variables
## 2010: 52416 obs. of 9 variables <-- wtf?
le_raw %>% head()
le_raw %>% tail()

#' Let's look at `year`.
n_distinct(le_raw$year)
## 210 unique values in 2014 cleaning
unique(le_raw$year)

#' Eye-ball-o-metric inspection suggests these might all be integers between
#' 1800 and 2007. True?
all(le_raw$year %in% 1800:2007)

#' Great. Convert year to integer.
le_raw <- le_raw %>%
  mutate(year = year %>% as.integer())

le_raw$year %>% summary()

#' Sidebar: In 2014, there were 3 NA's. Perhaps they derived from some
#' diabolically hidden rows in the Excel file. In Excel, mere 'unhide' does NOT
#' reveal these rows. If you look carefully, you can see missing row numbers. To
#' reveal the rows, use 'unset filters'. Regardless, these rows aren't picked up
#' in 2010 or 2015 and get filtered out no matter what.
#'
#' Let's look at `lifeExp`.
le_raw$lifeExp %>% head(100)

#' How many `NA`s are there ?!?
sum(is.na(le_raw$lifeExp))

#' Drop them.
le_raw <- le_raw %>%
  filter(!is.na(lifeExp))
str(le_raw)

le_raw$lifeExp %>% summary()

#' Is `continent` ok as is?
n_distinct(le_raw$continent) # 7
unique(le_raw$continent)

#' Let's look further into empty continent and the novel continent FSU.
(empty_continent <- le_raw %>%
  filter(is.na(continent)) %>%
  select(country) %>%
  unique())
str(empty_continent)
#' Wait to fix these after merging pop + lifeExp + gdpPercap.

(fsu_continent <- le_raw %>%
  filter(continent == "FSU") %>%
  select(country) %>%
  unique())
#' Aha. Former Soviet Union. Handle this after merge.
#'
#' Is `country` ok as is?
n_distinct(le_raw$country) # 198
unique(le_raw$country)
#' No obvious train wrecks.

#' Return to year.
n_distinct(le_raw$year)
(p <- ggplot(le_raw, aes(x = year)) +
  geom_histogram(binwidth = 1))
p + xlim(c(1945, 2010))
p + xlim(c(1950, 1960))
p + xlim(c(2000, 2010))
#' I see spikes every five years after 1950.

#' Keep data from 1950 to 2007.
year_min <- 1950
year_max <- 2007
le_raw <- le_raw %>%
  filter(year %>% between(year_min, year_max))
le_raw %>% str()

#' Restore variable order from previous cleaning runs to minimize silly diffs.
le_raw <- le_raw %>%
  select(country, continent, year, lifeExp)

#' Save for now
write_tsv(le_raw, "02_lifeExp.tsv")

devtools::session_info()
