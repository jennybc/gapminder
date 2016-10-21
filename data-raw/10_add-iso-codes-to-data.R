#' ---
#' date: "`r format(Sys.Date())`"
#' output:
#'   html_document:
#'     keep_md: TRUE
#' ---
#' 

suppressPackageStartupMessages(library(dplyr))
library(countrycode)
load(file = file.path("..", "data", "gapminder.rdata"))


# Modifying `countrycode.rdata`
## Using the `countrycode` package, we can add ISO Alpha-3 and ISO Numeric-3
## country codes for each observation
gapminder <- gapminder %>%
  mutate(isoChar = countrycode(gapminder$country, "country.name", "iso3c"),
         isoNum = countrycode(gapminder$country, "country.name", "iso3n"))

## Is there an ISO code matched to each observation?
(sum(is.na(gapminder$isoNum) == TRUE)) # 0 (No non-matches)
(sum(is.na(gapminder$isoChar) == TRUE)) # 0 (No non-matches)

## Writing data
save(gapminder, file = file.path("..", "data", "gapminder.rdata"))
write.table(gapminder, file = file.path("..", "inst", "gapminder.tsv"), 
            quote=FALSE, sep='\t')

# Modifying `gapminder_unfiltered.rdata`
load(file = file.path("..", "data", "gapminder_unfiltered.rdata"))

## Adding ISO codes
gapminder_unfiltered <- gapminder_unfiltered %>%
  mutate(isoChar = countrycode(gapminder_unfiltered$country,
                                "country.name", "iso3c"),
         isoNum = countrycode(gapminder_unfiltered$country,
                               "country.name", "iso3n"))

## Is there an ISO code matched to each observation?
(sum(is.na(gapminder_unfiltered$isoNum) == TRUE)) # 0 (No non-matches)
(sum(is.na(gapminder_unfiltered$isoChar) == TRUE)) # 0 (No non-matches)

## Writing data
save(gapminder_unfiltered, file = file.path("..", "data",
                                            "gapminder_unfiltered.rdata"))
write.table(gapminder_unfiltered, 
            file= file.path("..", "inst", "gapminder_unfiltered.tsv"), 
            quote=FALSE, sep='\t')