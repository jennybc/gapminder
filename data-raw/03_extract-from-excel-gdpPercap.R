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

suppressPackageStartupMessages(library(dplyr))
library(tidyr)
library(ggplot2)
library(readr)

#' Extract the GDP per capita data from the Excel file downloaded 2009-04-30
#' from gapminder.org.
#'
#' 2015-12-29 NOTE: I am punting here for the moment and basing intake on
#' manually exported delimited text. For population and life expectancy, I have
#' re-implemented the Excel extraction programmatically using gdata::read.xls()
#' (2014) and then readxl (2015), which I plan to try here as well. But I dread
#' doing GDP per capita because the spreadsheet is transposed relative to the
#' other two. In Excel, I ruthlessly deleted tons of columns at front and up to
#' 1950, then saved as tab-delimited text file gdpPercap.txt.
gdp_xls <- read_tsv("xls-manual-extract/gdpPercap.txt")
gdp_xls %>% str(list.len = 4)
gdp_xls %>% head()
#' Sadly, this file is transposed relative to population and life expectancy.
#' Each row is a country and the columns give the GDP data for different years.
#' WHY?!?
#'
#' Reshape the data by gathering all the year variables.
gdp_tidy <- gdp_xls %>%
  gather(key = "Xyear", value = "gdpPercap", -Area)
gdp_tidy %>% str()

#' Rename Area --> country and fix the years.
gdp_tidy <- gdp_tidy %>%
  rename(country = Area) %>%
  mutate(
    Xyear = levels(Xyear)[as.numeric(Xyear)],
    year = gsub("X", "", Xyear) %>% as.integer(),
    Xyear = NULL
  )
gdp_tidy %>% str()

#' Filter rows where gdpPercap is `NA`.
gdp_tidy <- gdp_tidy %>%
  filter(!is.na(gdpPercap))
gdp_tidy %>% str()

#' Look into the coverage by year.
summary(gdp_tidy$year)

(p <- ggplot(gdp_tidy, aes(x = year)) +
  geom_histogram(binwidth = 1))
#' Unlike population and life expectancy, there's no obvious reason to filter on
#' year at this point.
#'
#' Is country ok as is?
n_distinct(gdp_tidy$country)
unique(gdp_tidy$country)
#' No obvious train wrecks.

#' Save for now.
write_tsv(gdp_tidy, "03_gdpPercap.tsv")

devtools::session_info()
