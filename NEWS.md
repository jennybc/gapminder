# gapminder 0.2.0.9000

# gapminder 0.2.0

  * Added the `tbl_df` class to the `gapminder` data frame, which is advantageous for users of the `dplyr` package.
  * Changed (corrected?) the `population` variable from numeric to integer. Affected India (all years) and China (1952).
  * Moved imputation of 1952 China data earlier in the data cleaning process, which added a row to `inst/gapminder-unfiltered.tsv`.
  * Added the  `gapminder_unfiltered` data frame. It's the data frame `gapminder` came from, but is less heavily filtered (previously available only in `inst/gapminder-unfiltered.tsv`).
  * Added tab-delimited files for the country and continent colors, `inst/continent-colors.tsv` and `inst/country-colors.tsv`.
  * Added description of the "international dollars" in which GDP per capita is reported (thanks @aammd, #5).

# gapminder 0.1.0

  * Initial CRAN release
