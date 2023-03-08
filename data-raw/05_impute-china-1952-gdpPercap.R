#' ---
#' date: "`r format(Sys.Date())`"
#' output:
#'   html_document:
#'     keep_md: TRUE
#' ---

library(readr)
suppressPackageStartupMessages(library(dplyr))
library(tidyr)
library(ggplot2)

#' There is no data for China in 1952. I have always had an incredibly low-tech
#' imputation. I put it in its own script at the suggestion of Hilmar Lapp.
#' <https://github.com/jennybc/gapminder/issues/6>

gap_dat_orig <- read_tsv("04_gap-merged.tsv")

#' See? No data for 1952.
(china <- gap_dat_orig %>%
  filter(country == "China"))

#' Why is this problem? Big picture, it's not a problem! But to teach
#' visualization and data exploration, I wanted my final dataset to be extremely
#' clean and balanced. Ultimately, each country has data for 12 years: 1952,
#' 1957, 1962, ..., 2007. And I didn't want to lose a large country like China.
#' So I imputed the data in order to retain it in `gapminder`.
#'
#' In the past,  I imputed the China data after filtering for the years 1952,
#' 1952, etc. so I must do that here as well.
china <- china %>%
  filter(year %% 5 == 2)

#' What does the data look like?
china_tidy <- china %>%
  gather(
    key = "variable", value = "value",
    pop, lifeExp, gdpPercap
  )
ggplot(china_tidy, aes(x = year, y = value)) +
  facet_wrap(~variable, scales = "free_y") +
  geom_point() +
  geom_line() +
  scale_x_continuous(breaks = seq(1950, 2011, 15))

#' Begin extremely low, low tech imputation for 1952. I wouldn't necessarily do
#' it this way again, but I'm committed now to replicating what I did late at
#' night long ago.
#'
#' Linear fit for GDP per capita up to 1982.
china_gdp_fit <- lm(gdpPercap ~ year, china, subset = year <= 1982)
summary(china_gdp_fit)
(china_gdp_1952 <- china_gdp_fit %>%
  predict(data.frame(year = 1952)) %>%
  round(6))
## historically this has given: 400.4486

#' Linear fit for population.
china_pop_fit <- lm(pop ~ year, china)
summary(china_pop_fit)
(china_pop_1952 <- china_pop_fit %>%
  predict(data.frame(year = 1952)) %>%
  as.integer())
## historically this has given: 556263527

#' Pulling a number out of thin air for life expectancy, but no simple linear
#' fit was appropriate.
china_lifeExp_1952 <- 44

#' Append these values to the full data frame.
gap_dat_new <- rbind(
  gap_dat_orig,
  data.frame(
    country = "China", year = 1952,
    pop = china_pop_1952, continent = "Asia",
    lifeExp = china_lifeExp_1952,
    gdpPercap = china_gdp_1952
  )
)
gap_dat_new <- gap_dat_new %>%
  arrange(country, year)

#' Isolate the China data again for some plots.
china_tidy <- gap_dat_new %>%
  filter(country == "China") %>%
  gather(
    key = "variable", value = "value",
    pop, lifeExp, gdpPercap
  )
ggplot(china_tidy, aes(x = year, y = value)) +
  facet_wrap(~variable, scales = "free_y") +
  geom_point() +
  geom_line() +
  scale_x_continuous(breaks = seq(1950, 2011, 15))

#' Save for now.
write_tsv(gap_dat_new, "05_gap-merged-with-china-1952.tsv")

devtools::session_info()
