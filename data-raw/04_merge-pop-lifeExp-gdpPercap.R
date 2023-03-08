#' ---
#' date: "`r format(Sys.Date())`"
#' output:
#'   html_document:
#'     keep_md: TRUE
#' ---

library(plyr) ## revalue()
suppressPackageStartupMessages(library(dplyr))
library(ggplot2)
library(readr)

#' Bring in lightly cleaned datasets extracted from Excel spreadsheets.
pop_dat <- read_tsv("01_pop.tsv") %>%
  mutate(country = factor(country))
pop_dat %>% str()
pop_dat %>% head()
pop_dat %>% tail()

le_dat <- read_tsv("02_lifeExp.tsv") %>%
  mutate(
    country = factor(country),
    continent = factor(continent)
  )
le_dat %>% str()
le_dat %>% head()
le_dat %>% tail()

gdp_dat <- read_tsv("03_gdpPercap.tsv") %>%
  mutate(country = factor(country))
gdp_dat %>% str()
gdp_dat %>% head()
gdp_dat %>% tail()

#' Overlap between countries in the different datasets
country_levels <- function(df) levels(df$country)
union_country <- country_levels(pop_dat) %>%
  union(country_levels(le_dat)) %>%
  union(country_levels(gdp_dat)) %>%
  sort()
union_country %>% length()
union_country
#' I see lots of problems. Recorded in the file country-pain.txt. Which
#' countries appear in which dataset?
c_dat <- data_frame(
  country = union_country,
  pop = country %in% levels(pop_dat$country),
  le = country %in% levels(le_dat$country),
  gdp = country %in% levels(gdp_dat$country),
  total = pop + le + gdp
)
c_dat$total %>% table()

#' Can I just ignore countries that appear in 1 or 2 datasets?
c_dat %>%
  filter(total < 3)
#' No, I cannot. That is sad.

#' These are the ad hoc fixes I decided to make in 2010. country-pain.txt
#' contains a more comprehensive collection of problems.
country_subs <- c(
  "Bahamas, The" = "Bahamas",
  "Central African Rep." = "Central African Republic",
  "Cook Is" = "Cook Islands",
  "Czech Rep." = "Czech Republic",
  "Dominican Rep." = "Dominican Republic",
  "Egypt, Arab Rep." = "Egypt",
  "Gambia, The" = "Gambia",
  "Iran, Islamic Rep." = "Iran",
  "Russian Federation" = "Russia",
  "Syrian Arab Republic" = "Syria",
  "Venezuela, RB" = "Venezuela"
)
revalue_country <- function(x) revalue(x, country_subs)
pop_dat <- pop_dat %>%
  mutate(country = revalue_country(country))
le_dat <- le_dat %>%
  mutate(country = revalue_country(country))
gdp_dat <- gdp_dat %>%
  mutate(country = revalue_country(country))

#' Studying the overlap between countries in the different datasets. Again.
union_country <- country_levels(pop_dat) %>%
  union(country_levels(le_dat)) %>%
  union(country_levels(gdp_dat)) %>%
  sort()
union_country %>% length()
c_dat <- data_frame(
  country = union_country,
  pop = country %in% levels(pop_dat$country),
  le = country %in% levels(le_dat$country),
  gdp = country %in% levels(gdp_dat$country),
  total = pop + le + gdp
)
c_dat$total %>% table()

#' Now can I just ignore countries that appear in 1 or 2 datasets?
c_dat %>%
  filter(total < 3)
#' Other than USSR, yes I will ignore countries that appear in 1 or 2 datasets.

pop_russia <- pop_dat %>%
  filter(country %in% c("Russia", "USSR"))
(ggplot(pop_russia, aes(x = year, y = pop, color = country)) +
  geom_line())
#' Huh? Pop data present for USSR *and* Russia, 1950 - 2008. USSR pop >> Russia
#' pop. USSR presumably includes Russia??

le_dat %>%
  filter(country %in% c("Russia", "USSR"))
gdp_dat %>%
  filter(country %in% c("Russia", "USSR"))
#' `lifeExp` and `gdpPercap` only have data for Russia. Executive decision: keep
#' Russia, discard USSR.
#'
#' Decision: keep countries found in all 3 datasets.
#'
#' Merge all three datasets! Then enforce countries to keep.
## 2015-12-29 note:
## dplyr bug means we can't use inner_join right now
## https://github.com/hadley/dplyr/issues/1559
gap_dat <- pop_dat %>%
  #  inner_join(gdp_dat, by = c("country", "year")) %>%
  #  inner_join(le_dat, by = c("country", "year")) %>%
  merge(gdp_dat, by = c("country", "year")) %>%
  merge(le_dat, by = c("country", "year")) %>%
  droplevels() %>%
  arrange(country, year)

gap_dat %>% str()
## 2015: agrees with merged result in 2014, except for
##   * pop is int now (as it should be and as it was in 2010)
##   * continent used to have 7 levels because we had "" instead of NA (I think)
## 2014: agreed with merged result in 2010, except for
##   * variable order
##   * pop is numeric now, was integer then
##   * at this point in 2010 cleaning, I had an unused level for the country
##     factor (Tokelau), which has no downstream effects

my_vars <- c("country", "continent", "year", "lifeExp", "pop", "gdpPercap")
gap_dat <- gap_dat[my_vars]

write_tsv(gap_dat, "04_gap-merged.tsv")
