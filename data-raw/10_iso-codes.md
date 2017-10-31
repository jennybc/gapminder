10\_iso-codes.R
================
jenny
2017-10-31

``` r
library(countrycode)
library(here)
```

    ## here() starts at /Users/jenny/rrr/gapminder

``` r
library(gapminder)
library(tidyverse)
```

    ## + ggplot2 2.2.1             Date: 2017-10-31
    ## + tibble  1.3.4                R: 3.4.1
    ## + tidyr   0.7.1               OS: macOS Sierra 10.12.6
    ## + readr   1.1.1              GUI: X11
    ## + purrr   0.2.3.9000      Locale: en_CA.UTF-8
    ## + dplyr   0.7.4               TZ: America/Vancouver
    ## + stringr 1.2.0.9000      
    ## + forcats 0.2.0

    ## Warning: package 'dplyr' was built under R version 3.4.2

    ## ── Conflicts ────────────────────────────────────────────────────

    ## * filter(),  from dplyr, masks stats::filter()
    ## * lag(),     from dplyr, masks stats::lag()

``` r
country_codes <- tibble(
  country = levels(gapminder_unfiltered$country)
)
country_codes <- country_codes %>% 
  mutate(iso_alpha = countrycode(country, "country.name", "iso3c"),
         iso_num = countrycode(country, "country.name", "iso3n"))

anyNA(country_codes$iso_alpha)
```

    ## [1] FALSE

``` r
anyNA(country_codes$iso_num)
```

    ## [1] FALSE

``` r
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
```

    ## [1] TRUE
