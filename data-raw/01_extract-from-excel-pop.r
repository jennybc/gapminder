library(gdata)     # read.xls()
library(dplyr)
library(ggplot2)

## extract the population data

## this is the Excel file downloaded 2008-10-08 from gapminder.org
pop_xls <- read.xls("xls/gapdata003.xls", verbose = TRUE,
                    fileEncoding =  "ISO-8859-1")
pop_xls %>% str
## 2014: 20455 obs. of  12 variables
## 2010 cleaning code comment: 22903 obs. of  10 variables <-- huh?
## Note: I did not use gdata::read.xls() in 2010; rather, I exported a text file
## from Excel 'by hand'.
pop_xls %>% head

## get rid of vars I will not use; rename vars I keep
pop_raw <- pop_xls %>%
  select(country = Area, year = Year, pop = Population)
pop_raw %>% str
# 'data.frame':  20455 obs. of  3 variables:
# $ country: Factor w/ 253 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ year   : int  1800 1820 1870 1913 1950 1951 1952 1953 1954 1955 ...
# $ pop    : Factor w/ 19155 levels "0","1,000","1,000,000",..: 8705 8705 11243 13767 17502 17579 17652 17722 17793 17873 ...

## focus on the years where most of the data is
summary(pop_raw$year)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1491    1935    1967    1953    1988    2030 
## AHA! In 2010, this also included 2448 NA's.
## 20455 + 2448 = 22903
## Mystery of the rows solved.
year_freq <- pop_raw %>%
  group_by(year) %>%
  tally

(p <- ggplot(year_freq, aes(x = year, y = n)) + geom_bar(stat = "identity"))
p + xlim(c(1800, 2010))
p + xlim(c(1945, 1955)) # huge increase at 1950
p + xlim(c(2000, 2015)) # huge drop at 2009 (data contains some extrapolation)

## keep data from 1950 to 2008
year_min <- 1950
year_max <- 2008
pop_raw <- pop_raw %>%
  filter(year >= year_min & year <= year_max)
str(pop_raw)                             # 14105 obs. of  3 variables:
# 'data.frame':  14105 obs. of  3 variables:
# $ country: Factor w/ 253 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ year   : int  1950 1951 1952 1953 1954 1955 1956 1957 1958 1959 ...
# $ pop    : Factor w/ 19155 levels "0","1,000","1,000,000",..: 17502 17579 17652 17722 17793 17873 18364 18453 18531 18602 ...

## get rid of the commas in pop (which is currently a factor!)
pop_raw <- pop_raw %>%
  mutate(pop = levels(pop)[as.numeric(pop)]) %>%
  mutate(pop = as.numeric(gsub(",","", pop)))
pop_raw %>% str # 14105 obs. of  3 variables
# 'data.frame':  14105 obs. of  3 variables:
# $ country: Factor w/ 253 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ year   : int  1950 1951 1952 1953 1954 1955 1956 1957 1958 1959 ...
# $ pop    : num  8150368 8284473 8425333 8573217 8728408 ...

## save for now
write.table(pop_raw,
            "01_pop.tsv",
            quote = FALSE, sep = "\t", row.names = FALSE)
