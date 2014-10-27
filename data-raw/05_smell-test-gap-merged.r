library(plyr)
library(dplyr)
library(ggplot2)

gap_dat <- read.delim("04_gap-merged.tsv")
gap_dat %>% str
# 'data.frame':  3312 obs. of  6 variables:
# $ country  : Factor w/ 187 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
# $ pop      : num  8425333 9240934 10267083 11537966 13079460 ...
# $ gdpPercap: num  779 821 853 836 740 ...
# $ continent: Factor w/ 7 levels "","Africa","Americas",..: 4 4 4 4 4 4 4 4 4 4 ...
# $ lifeExp  : num  28.8 30.3 32 34 36.1 ...

## do we have NAs?
aaply(gap_dat, 2, function(x) sum(is.na(x)))
# continent   country gdpPercap   lifeExp       pop      year 
#         0         0         0         0         0         0 
## no NAs ... good!

## year
gap_dat$year %>% summary
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##    1950    1967    1982    1980    1996    2007 

## confirming we have 1950, 1951, ..., 2007
all.equal(gap_dat$year %>% unique %>% sort, 1950:2007)

## how much data do we have for each year?
ggplot(gap_dat, aes(x = year)) + geom_bar(binwidth = 1)
## most countries have data every five years, e.g. 1952, 1957, 1962,
## and so on

## country
gap_dat$country %>% str  # Factor w/ 187 levels
country_freq <- gap_dat %>%
  group_by(country) %>%
  tally
ggplot(country_freq, aes(x = country, y = n)) +
  geom_bar(stat = "identity")  # ugly but worth seeing
(p <- ggplot(country_freq, aes(x = n)) + geom_bar(binwidth = 1))
p + xlim(c(1, 16))
country_freq$n %>% table
## Most countries have data for 12 years, i.e. the years highlighted
## above.  Some have data for 58 years, which I assume is the maximum.
## Otherwise, there's a little bit of everything between 1 and 58.

## continent
gap_dat$continent %>% levels   # 7 levels for continent, including ""
gap_dat$continent %>% summary
#          Africa Americas     Asia   Europe      FSU  Oceania 
#    301      613      343      557     1302      122       74 

## 301 rows have no continent data :(

## Is continent data uniform for all rows pertaining to one country?
tmp <- gap_dat %>%
  group_by(country) %>%
  summarize(n_continent = n_distinct(continent))
tmp$n_continent %>% table
## yes, all 187 countries have exactly 1 associated value of continent

## fixing the continent data is a separate task
## to be completed in with a new script

## population
gap_dat$pop %>% summary(digits = 10)
##       Min.    1st Qu.     Median       Mean    3rd Qu.       Max. 
##     59412    2678572    7557218   31614891   19585222 1318683096 

gap_dat[which.min(gap_dat$pop),]              # we have little countries
## like Aruba w/ 60K people
gap_dat[which.max(gap_dat$pop),]              # ... and big countries
## like China w/ 1.3B people

ggplot(gap_dat,aes(x = pop)) + geom_density() + scale_x_log10()

## life expectancy
gap_dat$lifeExp %>% summary                       # 23 to 83 years
ggplot(gap_dat,aes(x = lifeExp)) + geom_density() # looks plausible             
## note bimodality
## modes ~ 42 and 72

gap_dat$gdpPercap %>% summary                # $240 to $114K
#  Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 241.2   2515.0   7839.0  11320.0  17360.0 113500.0 
## $113K???? really?
gap_dat[which.max(gap_dat$gdpPercap),]        # OIL!  Kuwait, 1957.
ggplot(gap_dat,aes(x = gdpPercap)) + geom_density() # looks plausible
## loooong right tail

## satisfied all is well so far
## next step: populate empty continents