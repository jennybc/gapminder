#' ---
#' date: "`r format(Sys.Date())`"
#' output: github_document
#' ---

library(countrycode)
library(here)
library(gapminder)
library(tidyverse)

conflicted::conflict_prefer("filter", "dplyr")

packageVersion("countrycode")

country_codes <- tibble(
  country = levels(gapminder_unfiltered$country)
)
country_codes <- country_codes %>%
  mutate(
    iso_alpha = countrycode(country, "country.name", "iso3c"),
    iso_num = countrycode(country, "country.name", "iso3n")
  )

country_codes %>%
  filter(is.na(iso_alpha) | is.na(iso_num))

## Netherlands Antilles is no longer a country and, apparently, countrycode
## v1.0.0 now reflects that
## Add it back to reflect reality during the years spanned by gapminder
netherlands_antilles <- country_codes$country == "Netherlands Antilles"
country_codes$iso_alpha[netherlands_antilles] <- "ANT"
country_codes$iso_num[netherlands_antilles] <- 530L

## Sudan's numeric country code changed when South Sudan split off in 2011
## apparently, countrycode v1.0.0 now reflects that
## Add it back to reflect reality during the years spanned by gapminder
sudan <- country_codes$country == "Sudan"
country_codes$iso_num[sudan] <- 736L

## manually correct codes for North Korea (Korea, Dem. Rep.)
north_korea <- country_codes$country == "Korea, Dem. Rep."
country_codes$iso_alpha[north_korea] <- "PRK"
country_codes$iso_num[north_korea] <- 408L

save(
  country_codes,
  file = here("data", "country_codes.rdata")
)
write_tsv(
  country_codes,
  path = here("data-raw", "10_iso-codes.tsv")
)
file.copy(
  from = here("data-raw", "10_iso-codes.tsv"),
  to = here("inst", "extdata", "country-codes.tsv"),
  overwrite = TRUE
)
