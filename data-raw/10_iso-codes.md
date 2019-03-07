10\_iso-codes.R
================
jenny
2019-03-06

``` r
library(countrycode)
library(here)
```

    ## here() starts at /Users/jenny/rrr/gapminder

``` r
library(gapminder)
library(tidyverse)
```

    ## ── Attaching packages ────────────────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 3.1.0          ✔ purrr   0.3.0     
    ## ✔ tibble  2.0.1.9001     ✔ dplyr   0.8.0.9000
    ## ✔ tidyr   0.8.3.9000     ✔ stringr 1.4.0     
    ## ✔ readr   1.3.1          ✔ forcats 0.4.0

    ## ── Conflicts ───────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
conflicted::conflict_prefer("filter", "dplyr")
```

    ## [conflicted] Will prefer dplyr::filter over any other package

``` r
packageVersion("countrycode")
```

    ## [1] '1.1.0'

``` r
country_codes <- tibble(
  country = levels(gapminder_unfiltered$country)
)
country_codes <- country_codes %>% 
  mutate(iso_alpha = countrycode(country, "country.name", "iso3c"),
         iso_num = countrycode(country, "country.name", "iso3n"))
```

    ## Warning in countrycode(country, "country.name", "iso3c"): Some values were not matched unambiguously: Netherlands Antilles

    ## Warning in countrycode(country, "country.name", "iso3n"): Some values were not matched unambiguously: Netherlands Antilles

``` r
country_codes %>% 
  filter(is.na(iso_alpha) | is.na(iso_num))
```

    ## # A tibble: 1 x 3
    ##   country              iso_alpha iso_num
    ##   <chr>                <chr>       <int>
    ## 1 Netherlands Antilles <NA>           NA

``` r
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
```

    ## [1] TRUE
