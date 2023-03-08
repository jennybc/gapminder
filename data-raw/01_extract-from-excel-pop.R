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

#' Extract the population data from the Excel file downloaded 2008-10-08 from
#' gapminder.org

#+ warning=FALSE
pop_xls <- read_excel("xls/gapdata003.xls")

## the DEFINEDNAME thing is described here
## https://github.com/hadley/readxl/issues/82#issuecomment-166767220
## also hiding a crapton of warnings due to variables seeming to be ... numeric
## and then having text in them --> ignore because I drop those variables

pop_xls %>% str()
## 2015: 20455 obs. of  10 variables
## 2014: 20455 obs. of  12 variables
## 2010: 22903 obs. of  10 variables
pop_xls %>% head()

#' Get rid of vars I will not use; rename vars I keep.
pop_raw <- pop_xls %>%
  select(country = Area, year = Year, pop = Population)
pop_raw %>% str()

#' Focus on the years where most of the data is.
summary(pop_raw$year)
#' AHA! In 2010, this also included 2448 NA's. 20455 + 2448 = 22903. Mystery of
#' the rows solved.

year_freq <- pop_raw %>%
  count(year)

(p <- ggplot(year_freq, aes(x = year, y = n)) +
  geom_bar(stat = "identity"))
p + xlim(c(1800, 2010))
p + xlim(c(1945, 1955)) # huge increase at 1950
p + xlim(c(2000, 2015)) # huge drop at 2009 (data contains some extrapolation)

#' Keep data from 1950 to 2008
year_min <- 1950
year_max <- 2008
pop_raw <- pop_raw %>%
  filter(year %>% between(year_min, year_max))
str(pop_raw)

#' I am the voice from the future: look at India!
pop_raw %>%
  filter(country == "India")
#' These doubles create problems later. GET RID OF THEM NOW.

#' Force the population to be integer.
pop_raw <- pop_raw %>%
  mutate(pop = pop %>% as.integer())

#' Save for now
write_tsv(pop_raw, "01_pop.tsv")

devtools::session_info()
