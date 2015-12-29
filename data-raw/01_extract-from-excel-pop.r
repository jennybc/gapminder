library(readxl)
library(dplyr)
library(ggplot2)
library(readr)

## extract the population data

## this is the Excel file downloaded 2008-10-08 from gapminder.org
pop_xls <- read_excel("xls/gapdata003.xls")
## I get the DEFINEDNAME THING described here
## https://github.com/hadley/readxl/issues/82#issuecomment-166767220
## and also a crapton of warnings due to variables seeming to be ... numeric and
## then having text in them --> ignore because I drop those variables

pop_xls %>% str()
## 2015: 20455 obs. of  10 variables (switched to readxl)
## 2014: 20455 obs. of  12 variables
## 2010 cleaning code comment: 22903 obs. of  10 variables <-- huh?
## Note: I did not use gdata::read.xls() in 2010; rather, I exported a text file
## from Excel 'by hand'.
pop_xls %>% head()

## get rid of vars I will not use; rename vars I keep
pop_raw <- pop_xls %>%
  select(country = Area, year = Year, pop = Population)
pop_raw %>% str()
# Classes ‘tbl_df’, ‘tbl’ and 'data.frame':	20455 obs. of  3 variables:
# $ country: chr  "Afghanistan" "Afghanistan" "Afghanistan" "Afghanistan" ...
# $ year   : num  1800 1820 1870 1913 1950 ...
# $ pop    : num  3280000 3280000 4207000 5730000 8150368 ...

## focus on the years where most of the data is
summary(pop_raw$year)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1491    1935    1967    1953    1988    2030 
## AHA! In 2010, this also included 2448 NA's.
## 20455 + 2448 = 22903
## Mystery of the rows solved.
year_freq <- pop_raw %>%
  count(year)

(p <- ggplot(year_freq, aes(x = year, y = n)) +
   geom_bar(stat = "identity"))
p + xlim(c(1800, 2010))
p + xlim(c(1945, 1955)) # huge increase at 1950
p + xlim(c(2000, 2015)) # huge drop at 2009 (data contains some extrapolation)

## keep data from 1950 to 2008
year_min <- 1950
year_max <- 2008
pop_raw <- pop_raw %>%
  filter(year %>% between(year_min, year_max))
str(pop_raw)                             # 14105 obs. of  3 variables:
# Classes ‘tbl_df’, ‘tbl’ and 'data.frame':	14105 obs. of  3 variables:
# $ country: chr  "Afghanistan" "Afghanistan" "Afghanistan" "Afghanistan" ...
# $ year   : num  1950 1951 1952 1953 1954 ...
# $ pop    : num  8150368 8284473 8425333 8573217 8728408 ...

## voice from the future: look at India
pop_raw %>% 
  filter(country == "India")
## these large, doubles create problems later
## GET RID OF THEM HERE

## force the population to be integer
pop_raw <- pop_raw %>% 
  mutate(pop = pop %>% as.integer())

## save for now
write_tsv(pop_raw, "01_pop.tsv")
