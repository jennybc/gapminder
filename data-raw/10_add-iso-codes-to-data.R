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

anyNA(code_df$iso_alpha)
anyNA(code_df$iso_num)

save(
  country_codes,
  file = here("data", "country_codes.rdata")
)
write_tsv(
  country_codes,
  path = here("inst", "extdata", "country-codes.tsv")
)
