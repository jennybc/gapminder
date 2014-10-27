library(dplyr)
library(tidyr)
library(ggplot2)

gap_dat <- read.delim("06_gap-merged-with-continent.tsv")
gap_dat %>% str
# 'data.frame':  3312 obs. of  6 variables:
# $ country  : Factor w/ 187 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
# $ pop      : num  8425333 9240934 10267083 11537966 13079460 ...
# $ gdpPercap: num  779 821 853 836 740 ...
# $ lifeExp  : num  28.8 30.3 32 34 36.1 ...
# $ continent: Factor w/ 6 levels "Africa","Americas",..: 3 3 3 3 3 3 3 3 3 3 ...

## During data exploration, I learned that most countries have data every five
## years, e.g. 1952, 1957, 1962, and so on. Let's just make that official.
gap_dat <- gap_dat %>%
  filter(year %% 5 == 2)
gap_dat %>% str # 'data.frame':	2012 obs. of  6 variables:

## number of distinct values for year
(n_years <- n_distinct(gap_dat$year)) # 12

## Does every country contribute data for all years?
country_freq <- gap_dat %>%
  group_by(country) %>%
  tally

ggplot(country_freq, aes(x = n)) + geom_bar(binwidth = 1)
country_freq$n %>% table

## Most countries do contribute data for 12 years
## Who contributes less?
country_freq %>%
  filter(n < 12) %>%
  arrange(n)

## The only thing I see here that I want to fix is to rescue China, which has
## data for 11 of 12 years. Otherwise, I will let these countries go.
keepers <- c(with(country_freq, as.character(country[n == 12])),
             "China") %>% sort
keepers %>% length # 142 countries

## filter gap_dat
gap_dat <- gap_dat %>%
  filter(country %in% keepers) %>%
  droplevels %>%
  arrange(country, year)
gap_dat %>% str
# 'data.frame':  1703 obs. of  6 variables:
# $ country  : Factor w/ 142 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
# $ pop      : num  8425333 9240934 10267083 11537966 13079460 ...
# $ gdpPercap: num  779 821 853 836 740 ...
# $ lifeExp  : num  28.8 30.3 32 34 36.1 ...
# $ continent: Factor w/ 5 levels "Africa","Americas",..: 3 3 3 3 3 3 3 3 3 3 ...

## BEGIN: Fill in missing data for China

## which year is the problem?
(china <- gap_dat %>%
   filter(country == "China"))      # 1952 is missing

## what does the data look like?
china_tidy <- china %>%
  gather(key = "variable", value = "value",
         pop, lifeExp, gdpPercap)
ggplot(china_tidy, aes(x = year, y = value)) +
  facet_wrap(~ variable, scales="free_y") +
  geom_point() + geom_line() +
  scale_x_continuous(breaks = seq(1950, 2011, 15))

## extremely low, low tech imputation for 1952
china_gdp_fit <- lm(gdpPercap ~ year, gap_dat,
                    subset = country == 'China' & year <= 1982)
summary(china_gdp_fit)
(china_gdp_1952 <- predict(china_gdp_fit, data.frame(year = 1952)))
## 400.4486 

china_pop_fit <- lm(pop ~ year, gap_dat, subset = country == 'China')
summary(china_pop_fit)
(china_pop_1952 <- predict(china_pop_fit, data.frame(year = 1952)))
## 556263528

china_lifeExp_1952 <- 44 # fiction, but no simple linear fit seems appropriate

gap_dat <- rbind(gap_dat,
                 data.frame(country = 'China', year = 1952,
                            pop = china_pop_1952, continent = 'Asia',
                            lifeExp = china_lifeExp_1952,
                            gdpPercap = china_gdp_1952))
gap_dat <- gap_dat %>%
  arrange(country, year)
gap_dat %>%
  filter(country == "China")
str(gap_dat)  
# 'data.frame':  1704 obs. of  6 variables:
# $ country  : Factor w/ 142 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ year     : num  1952 1957 1962 1967 1972 ...
# $ pop      : num  8425333 9240934 10267083 11537966 13079460 ...
# $ gdpPercap: num  779 821 853 836 740 ...
# $ lifeExp  : num  28.8 30.3 32 34 36.1 ...
# $ continent: Factor w/ 5 levels "Africa","Americas",..: 3 3 3 3 3 3 3 3 3 3 ...

## revisit the data
china_tidy <- gap_dat %>%
  filter(country == "China") %>%
  gather(key = "variable", value = "value",
         pop, lifeExp, gdpPercap)
ggplot(china_tidy, aes(x = year, y = value)) +
  facet_wrap(~ variable, scales="free_y") +
  geom_point() + geom_line() +
  scale_x_continuous(breaks = seq(1950, 2011, 15))

## END: Fill in missing data for China

write.table(gap_dat,
            "07_gap-every-five-years.tsv",
            quote = FALSE, sep = "\t", row.names = FALSE)

gapminder <- gap_dat

## finally ready to save data for the package
save(gapminder, file = "../data/gapminder.rdata")
