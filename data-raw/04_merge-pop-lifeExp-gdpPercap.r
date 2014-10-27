library(plyr)  ## revalue()
library(dplyr)
library(ggplot2)

## bring in lightly cleaned datasets extracted from excel spreadsheets

pop_dat <- read.delim("01_pop.tsv")
pop_dat %>% str
# 'data.frame':  14105 obs. of  3 variables:
# $ country: Factor w/ 253 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ year   : int  1950 1951 1952 1953 1954 1955 1956 1957 1958 1959 ...
# $ pop    : num  8150368 8284473 8425333 8573217 8728408 ...
## 2014: only difference with 2010 is pop is numeric now, was integer
pop_dat %>% head
pop_dat %>% tail

le_dat <- read.delim("02_lifeExp.tsv")
le_dat %>% str
# 'data.frame':  3786 obs. of  4 variables:
# $ country  : Factor w/ 198 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ continent: Factor w/ 7 levels "","Africa","Americas",..: 4 4 4 4 4 4 4 4 4 4 ...
# $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
# $ lifeExp  : num  28.8 30.3 32 34 36.1 ...
## 2014: only difference with 2010 is order of the variables
le_dat %>% head
le_dat %>% tail           

gdp_dat <- read.delim("03_gdpPercap.tsv")
gdp_dat %>% str
# 'data.frame':  10911 obs. of  3 variables:
# $ country  : Factor w/ 229 levels "Afghanistan",..: 1 2 3 4 6 9 10 12 13 14 ...
# $ gdpPercap: num  757 1532 2429 4465 3363 ...
# $ year     : int  1950 1950 1950 1950 1950 1950 1950 1950 1950 1950 ...
## 2014: only difference with 2010 is order of the variables
## 'data.frame':	10911 obs. of  3 variables:
gdp_dat %>% head
le_dat %>% tail

## studying the overlap between countries in the different datasets
country_levels <- function(df) levels(df$country)
union_country <- country_levels(pop_dat) %>%
  union(country_levels(le_dat)) %>%
  union(country_levels(gdp_dat)) %>%
  sort
union_country %>% length # 271 (in 2010 and 2014)
union_country
## problems I see by eye
# Bahamas  Bahamas, The
# Central African Rep.	Central African Republic
# Congo, Dem. Rep.	Congo, Rep.
# Cook Is	    Cook Islands
# Czech Rep.  Czech Republic	Czechoslovakia
# Dominican Rep.	  Dominican Republic
# East Germany	  Germany   West Germany
# Egypt		  Egypt, Arab Rep.
# Eritrea		  Eritrea and Ethiopia	Ethiopia
# Falkland Is (Malvinas)	  Falkland Islands (Malvinas)
# Gambia	 Gambia, The
# Iran	 Iran, Islamic Rep.
# Korea, Dem. Rep.       Korea, Rep.	Korea, United
# Kyrgyz Republic	       Kyrgyzstan
# Lao PDR		       Laos
# Russia		       Russian Federation	USSR
# Serbia		       Serbia and Montenegro	Serbia excluding Kosovo
# Saint Kitts and Nevis  St. Kitts and Nevis
# Saint Lucia St. Lucia
# Saint Vincent and the Grenadines	St. Vincent and the Grenadines
# Syria Syrian Arab Republic
# Venezuela    Venezuela, RB
# Yemen Arab Republic (Former)	Yemen Democratic (Former)	Yemen, Rep.
# RECORDED THAT IN country-pain.txt!
c_dat <- data_frame(country = union_country,
                    pop = country %in% levels(pop_dat$country),
                    le = country %in% levels(le_dat$country),
                    gdp = country %in% levels(gdp_dat$country),
                    total = pop + le + gdp)
c_dat$total %>% table
##  1   2   3 
## 40  53 178

## Can I just ignore countries that appear in 1 or 2 datasets?
c_dat %>%
  filter(total < 3)
## No, I cannot.

## these are the ad hoc fixes I decided to make in 2010
## (country-pain.txt contains a more comprehensive collection of problems)
country_subs <- c("Bahamas, The" = "Bahamas",
                  "Central African Rep." = "Central African Republic",
                  "Cook Is" = "Cook Islands",
                  "Czech Rep." = "Czech Republic",
                  "Dominican Rep." = "Dominican Republic",
                  "Egypt, Arab Rep." = "Egypt",
                  "Gambia, The" = "Gambia",
                  "Iran, Islamic Rep." = "Iran",
                  "Russian Federation" = "Russia",
                  "Syrian Arab Republic" = "Syria",
                  "Venezuela, RB" = "Venezuela")
revalue_country <- function(x) revalue(x, country_subs)
pop_dat <- pop_dat %>%
  mutate(country = revalue_country(country))
le_dat <- le_dat %>%
  mutate(country = revalue_country(country))
gdp_dat <- gdp_dat %>%
  mutate(country = revalue_country(country))

## studying the overlap between countries in the different datasets
union_country <- country_levels(pop_dat) %>%
  union(country_levels(le_dat)) %>%
  union(country_levels(gdp_dat)) %>%
  sort
union_country %>% length # 260 (in 2010 and 2014), down from 271
c_dat <- data_frame(country = union_country,
                    pop = country %in% levels(pop_dat$country),
                    le = country %in% levels(le_dat$country),
                    gdp = country %in% levels(gdp_dat$country),
                    total = pop + le + gdp)
c_dat$total %>% table
## BEFORE revalues    AFTER revalues    
##  1   2   3         1   2   3 
## 40  53 178        28  44 188 

## Can I just ignore countries that appear in 1 or 2 datasets?
c_dat %>%
  filter(total < 3)
## Other than USSR, yes I will ignore countries that appear in 1 or 2 datasets.

pop_russia <- pop_dat %>%
  filter(country %in% c("Russia","USSR"))
(ggplot(pop_russia, aes(x = year, y = pop, color = country)) +
   geom_line())
xyplot(pop ~ year, type = "l", 
            groups = country[drop = TRUE], auto.key = TRUE))
## huh?
## pop data present for USSR *and* Russia, 1950 - 2008
## USSR pop >> Russia pop, USSR presumably includes Russia??

le_dat %>%
  filter(country %in% c("Russia","USSR"))
gdp_dat %>%
  filter(country %in% c("Russia","USSR"))
## lifeExp and gdpPercap only have data for Russia
## decision: keep Russia, discard USSR

## decision: keep countries found in all 3 datasets

## merge all three datasets!  then enforce countries to keep
gap_dat <- pop_dat %>%
  inner_join(gdp_dat, by = c("country", "year")) %>%
  inner_join(le_dat, by = c("country", "year")) %>%
  droplevels %>%
  arrange(country, year)
gap_dat %>% str
# 'data.frame':  3312 obs. of  6 variables:
# $ country  : Factor w/ 187 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
# $ pop      : num  8425333 9240934 10267083 11537966 13079460 ...
# $ gdpPercap: num  779 821 853 836 740 ...
# $ continent: Factor w/ 7 levels "","Africa","Americas",..: 4 4 4 4 4 4 4 4 4 4 ...
# $ lifeExp  : num  28.8 30.3 32 34 36.1 ...
## 2014: agrees with merged result in 2010, except for
##   * variable order
##   * pop is numeric now, was integer then
##   * at this point in 2010 cleaning, I had an unused level for the country
##     factor (Tokelau), which has no downstream effects

write.table(gap_dat,
            "04_gap-merged.tsv",
            quote = FALSE, sep = "\t", row.names = FALSE)
