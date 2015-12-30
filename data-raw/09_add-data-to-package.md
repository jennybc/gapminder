`r format(Sys.Date())`  


```r
suppressPackageStartupMessages(library(dplyr))
library(readr)
```

Copy datasets to `inst/`.


```r
file.copy(from =  "07_gap-merged-with-continent.tsv",
          to = file.path("..", "inst", "gapminder-unfiltered.tsv"),
          overwrite = TRUE)
```

```
## [1] TRUE
```

```r
file.copy(from =  "08_gap-every-five-years.tsv",
          to = file.path("..", "inst", "gapminder.tsv"),
          overwrite = TRUE)
```

```
## [1] TRUE
```

Put `.Rdata` packages in `data/`.


```r
gapminder_unfiltered <- read_tsv("07_gap-merged-with-continent.tsv") %>% 
  mutate(country = factor(country),
         continent = factor(continent)) %>% 
  select(country, year, pop, gdpPercap, lifeExp, continent)
save(gapminder_unfiltered,
     file = file.path("..", "data", "gapminder_unfiltered.rdata"))
gapminder <- read_tsv("08_gap-every-five-years.tsv") %>% 
  mutate(country = factor(country),
         continent = factor(continent)) %>% 
  select(country, year, pop, gdpPercap, lifeExp, continent)
save(gapminder, file = file.path("..", "data", "gapminder.rdata"))
```


---
title: "09_add-data-to-package.R"
author: "jenny"
date: "Wed Dec 30 08:30:17 2015"
---
