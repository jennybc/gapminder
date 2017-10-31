Data cleaning
================

I explicitly use this package to teach data cleaning, so have refactored my old cleaning code into several scripts. I also include them as compiled Markdown reports. Caveat: these are realistic cleaning scripts! Not the highly polished ones people write with 20/20 hindsight :) I wouldn't necessarily clean it the same way again (and I would download more recent data!), but at this point there is great value in reproducing the data I've been using for ~5 years.

Cleaning history

-   2010: The first time I documented cleaning this dataset. I started with delimited files I exported from Excel. Not present in this repo.
-   2014: I re-cleaned the data and (mostly) forced myself to pull it straight out of the spreadsheets. Used the `gdata` package. It was kind of painful, due to encoding and other issues. See the scripts in this state in [v0.1.0](https://github.com/jennybc/gapminder/tree/v0.1.0/data-raw).
-   2015: I revisited the cleaning and switched to `readxl`. This was much less painful. Present day.

<!-- -->

    ## + ggplot2 2.2.1             Date: 2017-10-31
    ## + tibble  1.3.4                R: 3.4.1
    ## + tidyr   0.7.1               OS: macOS Sierra 10.12.6
    ## + readr   1.1.1              GUI: X11
    ## + purrr   0.2.3.9000      Locale: en_CA.UTF-8
    ## + dplyr   0.7.4               TZ: America/Vancouver
    ## + stringr 1.2.0.9000      
    ## + forcats 0.2.0

    ## ── Conflicts ────────────────────────────────────────────────────

    ## * filter(),  from dplyr, masks stats::filter()
    ## * lag(),     from dplyr, masks stats::lag()

    ## here() starts at /Users/jenny/rrr/gapminder

| r\_script                                                               | notebook                                                                  | tsv                                                                                                  |
|:------------------------------------------------------------------------|:--------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------|
| [01\_extract-from-excel-pop.R](01_extract-from-excel-pop.R)             | [01\_extract-from-excel-pop.md](01_extract-from-excel-pop.md)             | [01\_pop.tsv](01_pop.tsv)                                                                            |
| [02\_extract-from-excel-lifeExp.R](02_extract-from-excel-lifeExp.R)     | [02\_extract-from-excel-lifeExp.md](02_extract-from-excel-lifeExp.md)     | [02\_lifeExp.tsv](02_lifeExp.tsv)                                                                    |
| [03\_extract-from-excel-gdpPercap.R](03_extract-from-excel-gdpPercap.R) | [03\_extract-from-excel-gdpPercap.md](03_extract-from-excel-gdpPercap.md) | [03\_gdpPercap.tsv](03_gdpPercap.tsv)                                                                |
| [04\_merge-pop-lifeExp-gdpPercap.R](04_merge-pop-lifeExp-gdpPercap.R)   | [04\_merge-pop-lifeExp-gdpPercap.md](04_merge-pop-lifeExp-gdpPercap.md)   | [04\_gap-merged.tsv](04_gap-merged.tsv)                                                              |
| [05\_impute-china-1952-gdpPercap.R](05_impute-china-1952-gdpPercap.R)   | [05\_impute-china-1952-gdpPercap.md](05_impute-china-1952-gdpPercap.md)   | [05\_gap-merged-with-china-1952.tsv](05_gap-merged-with-china-1952.tsv)                              |
| [06\_smell-test-gap-merged.R](06_smell-test-gap-merged.R)               | [06\_smell-test-gap-merged.md](06_smell-test-gap-merged.md)               | []()                                                                                                 |
| [07\_fill-and-fix-continent.R](07_fill-and-fix-continent.R)             | [07\_fill-and-fix-continent.md](07_fill-and-fix-continent.md)             | [07\_gap-merged-with-continent.tsv](07_gap-merged-with-continent.tsv)                                |
| [08\_filter-every-five-years.R](08_filter-every-five-years.R)           | [08\_filter-every-five-years.md](08_filter-every-five-years.md)           | [08\_gap-every-five-years.tsv](08_gap-every-five-years.tsv)                                          |
| [09\_add-data-to-package.R](09_add-data-to-package.R)                   | [09\_add-data-to-package.md](09_add-data-to-package.md)                   | []()                                                                                                 |
| [10\_iso-codes.R](10_iso-codes.R)                                       | [10\_iso-codes.md](10_iso-codes.md)                                       | [10\_iso-codes.tsv](10_iso-codes.tsv)                                                                |
| [40\_make-color-scheme.R](40_make-color-scheme.R)                       | [40\_make-color-scheme.md](40_make-color-scheme.md)                       | [40\_continent-colors.tsv](40_continent-colors.tsv), [40\_country-colors.tsv](40_country-colors.tsv) |
| [80\_custom-spelling.R](80_custom-spelling.R)                           | []()                                                                      | []()                                                                                                 |
