#' ---
#' date: "`r format(Sys.Date())`"
#' output: github_document
#' ---

library(countrycode)
library(here)
library(gapminder)
library(tidyverse)

country_codes <- tibble(
  country = levels(gapminder_unfiltered$country)
)
country_codes <- country_codes %>% 
  mutate(iso_alpha = countrycode(country, "country.name", "iso3c"),
         iso_num = countrycode(country, "country.name", "iso3n"))

anyNA(country_codes$iso_alpha)
anyNA(country_codes$iso_num)

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
