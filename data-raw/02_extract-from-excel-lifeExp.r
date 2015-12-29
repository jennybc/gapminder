library(readxl)
library(dplyr)
library(ggplot2)
library(readr)

## extract the life expectancy data

## this is the Excel file downloaded 2009-04-21 from gapminder.org
le_xls <-
  read_excel("xls/life-expectancy-reference-spreadsheet-20090204-xls-format.xls",
             sheet = "Data and metadata")
           # verbose = TRUE, quote = "", method = "tab", 
           # fileEncoding =  "ISO-8859-1",
           # colClasses = c(rep("character", 4), rep("NULL", 5)))
le_xls %>% str
# Classes ‘tbl_df’, ‘tbl’ and 'data.frame':	52416 obs. of  9 variables:

## rename vars
le_raw <- le_xls %>%
  select(country = contains("country"), continent = contains("continent"),
         year_raw = contains("year"), lifeExp_raw = contains("expectancy"))
le_raw %>% str
# Classes ‘tbl_df’, ‘tbl’ and 'data.frame':	52416 obs. of  4 variables:
# $ country    : chr  "Abkhazia" "Abkhazia" "Abkhazia" "Abkhazia" ...
# $ continent  : chr  "Asia" "Asia" "Asia" "Asia" ...
# $ year_raw   : num  1800 1801 1802 1803 1804 ...
# $ lifeExp_raw: num  NA NA NA NA NA NA NA NA NA NA ...

## 2015: 52416 obs. of  4 variables (switched to readxl)
## 2014: 52419 obs. of  4 variables:
## 2010 cleaning code comment: # 52416 obs. of  9 variables: <-- huh?
## Note: I did not use gdata::read.xls() in 2010; rather, I exported a text file
## from Excel 'by hand'.
le_raw %>% head()
le_raw %>% tail()

## let's fix year enough to filter on it
n_distinct(le_raw$year_raw) # 208 (2015, readxl) 210 (2014, gdata)
unique(le_raw$year_raw)
## eye-ball-o-metric inspection ...

## convert year to integer
le_raw <- le_raw %>%
  mutate(year = year_raw %>% as.integer())
le_raw$year %>% n_distinct() #208
le_raw$year %>% unique()
all.equal(sort(unique(le_raw$year[!is.na(le_raw$year)])), 1800:2007)
## Integers between 1800 and 2007. Yay.

## drop year_raw, in favor of year
le_raw <- le_raw %>%
  select(-year_raw)

le_raw$year %>% summary()
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#  1800    1852    1904    1904    1955    2007
## NOTE: in 2015 (readxl) and 2010 (exported delimited file),
## this did not includee 3 NA's, which appeared in 2014 (gdata)
## 52419 - 3 = 52416
## Mystery of the rows solved.

## for which years do we have data?
year_freq <- le_raw %>%
  count(year)
table(year_freq$n)
# 252 
# 208 
## this solves nothing, because even when year is present, life expectancy often
## is not
## very different structure from population data :(

## change of plan: let's fix lifeExp enough to filter on it
le_raw$lifeExp_raw %>% head(100)
sum(is.na(le_raw$lifeExp_raw)) # 46507

le_raw <- le_raw %>%
  filter(!is.na(lifeExp_raw))
str(le_raw)
# Classes ‘tbl_df’, ‘tbl’ and 'data.frame':	5909 obs. of  4 variables:
# $ country    : chr  "Afghanistan" "Afghanistan" "Afghanistan" "Afghanistan" ...
# $ continent  : chr  "Asia" "Asia" "Asia" "Asia" ...
# $ lifeExp_raw: num  28.8 28.8 30.3 32 34 ...
# $ year       : int  1800 1952 1957 1962 1967 1972 1977 1982 1987 1992 ...

## rename to lifeExp
le_raw <- le_raw %>% 
  rename(lifeExp = lifeExp_raw)

le_raw$lifeExp %>% summary
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 11.60   45.21   61.17   58.02   70.90   82.67 

## is continent ok as is?
n_distinct(le_raw$continent) # 7
unique(le_raw$continent)
# [1] "Asia"     "Europe"   "Africa"   "Americas" NA         "FSU"      "Oceania" 

## let's look further into empty continent and FSU
(empty_continent <- le_raw %>%
   filter(is.na(continent)) %>%
   select(country) %>%
   unique())
str(empty_continent) ## 30 countries affected, eg Canada, Haiti
## wait to fix these after merging pop + lifeExp + gdpPercap

(fsu_continent <- le_raw %>%
   filter(continent == "FSU") %>%
   select(country) %>%
   unique())
#                country
# 1              Belarus
# 53          Kazakhstan
# 73              Latvia
# 128          Lithuania
# 181 Russian Federation
# 262            Ukraine
## handle this after merging pop + lifeExp + gdpPercap

## is country ok as is?
n_distinct(le_raw$country) # 198
unique(le_raw$country)
## no obvious problems

## return to year
n_distinct(le_raw$year) #208
unique(le_raw$year)
(p <- ggplot(le_raw, aes(x = year)) + geom_histogram(binwidth = 1)) # 1950 -->
p + xlim(c(1945, 2010)) # spikes every five years
p + xlim(c(1950, 1960)) # 1952, 1957, ...
p + xlim(c(2000, 2010)) # ..., 2002, 2007

## keep data from 1950 to 2007
year_min <- 1950
year_max <- 2007
le_raw <- le_raw %>%
  filter(year %>% between(year_min, year_max))
le_raw %>% str()
# Classes ‘tbl_df’, ‘tbl’ and 'data.frame':	3786 obs. of  4 variables:
# $ country  : chr  "Afghanistan" "Afghanistan" "Afghanistan" "Afghanistan" ...
# $ continent: chr  "Asia" "Asia" "Asia" "Asia" ...
# $ lifeExp  : num  28.8 30.3 32 34 36.1 ...
# $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...

## restore variable order from previous cleaning runs
le_raw <- le_raw %>% 
  select(country, continent, year, lifeExp)

## save for now
write_tsv(le_raw, "02_lifeExp.tsv")
