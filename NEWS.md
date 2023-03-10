# gapminder (development version)

# gapminder 1.0.0

* The 3-letter and numeric country codes for "Korea, Dem. Rep." (Democratic People's Republic of Korea, a.k.a. North Korea) have been corrected to "PRK" (was "KOR") and 408 (was 410). Previously, this country was erroneously getting the codes for "Korea, Rep." (Republic of Korea, a.k.a. South Korea).

* The release of version 1.0.0 formalizes the fact that this data package is unlikely to see much (or any) change in the future.

# gapminder 0.3.0

* `country_codes` is a new data frame that contains ISO 3166-1 country codes (#16 @jrebane).

* Import `tibble::tibble()`, so tibble printing is used out of the box.

* Moved delimited files for practicing data import into `inst/extdata/`. Therefore, these are now accessible after installation at, e.g., `system.file("extdata", "gapminder.tsv", package = "gapminder")`.

* Clarify that this package is not maintained as a definitive data source, rather it's for making code examples and teaching. Stability is now very important.

* Improved citability, e.g. added the "concept" DOI that links to a list of all version to DESCRIPTION and README. README also shows the use of `citation()`.

# gapminder 0.2.0

  * Added the `tbl_df` class to the `gapminder` data frame, which is advantageous for users of the `dplyr` package.
  * Changed (corrected?) the `population` variable from numeric to integer. Affected India (all years) and China (1952).
  * Moved imputation of 1952 China data earlier in the data cleaning process, which added a row to `inst/gapminder-unfiltered.tsv`.
  * Added the  `gapminder_unfiltered` data frame. It's the data frame `gapminder` came from, but is less heavily filtered (previously available only in `inst/gapminder-unfiltered.tsv`).
  * Added tab-delimited files for the country and continent colors, `inst/continent-colors.tsv` and `inst/country-colors.tsv`.
  * Added description of the "international dollars" in which GDP per capita is reported (thanks @aammd, #5).

# gapminder 0.1.0

  * Initial CRAN release
