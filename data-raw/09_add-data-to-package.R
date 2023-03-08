#' ---
#' date: "`r format(Sys.Date())`"
#' output:
#'   html_document:
#'     keep_md: TRUE
#' ---

suppressPackageStartupMessages(library(dplyr))
library(readr)

#' Copy datasets to `inst/`.
file.copy(
  from = "07_gap-merged-with-continent.tsv",
  to = file.path("..", "inst", "gapminder-unfiltered.tsv"),
  overwrite = TRUE
)
file.copy(
  from = "08_gap-every-five-years.tsv",
  to = file.path("..", "inst", "gapminder.tsv"),
  overwrite = TRUE
)

#' Put `.Rdata` packages in `data/`.
gapminder_unfiltered <- read_tsv("07_gap-merged-with-continent.tsv") %>%
  mutate(
    country = factor(country),
    continent = factor(continent)
  )
save(gapminder_unfiltered,
  file = file.path("..", "data", "gapminder_unfiltered.rdata")
)
gapminder <- read_tsv("08_gap-every-five-years.tsv") %>%
  mutate(
    country = factor(country),
    continent = factor(continent)
  )
save(gapminder, file = file.path("..", "data", "gapminder.rdata"))
