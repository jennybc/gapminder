library(gdata)
library(dplyr)
library(ggplot2)

library(help = "gdata")
## total population

## prior to this, opened gapdata003.xls in Excel, changed format of
## Population column to 'general' to suppress embedded commas, saved
## as tab-delimited text file totalPop.txt

pop_raw <- read.xls("xls/gapdata003.xls", verbose = TRUE)
pop_raw %>% str
## 2014: 20455 obs. of  12 variables
## 2010 cleaning code comment: 22903 obs. of  10 variables <-- huh?
## Note: I did not use gdata::read.xls() in 2010; rather, I exported a text file
## from Excel 'by hand'.
pop_raw %>% head

## get rid of vars I will not use; rename vars I keep
pop <- pop_raw %>%
  select(country = Area, year = Year, pop = Population)
pop %>% str

## focus on the years where most of the data is
summary(pop$year)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1491    1935    1967    1953    1988    2030 
## AHA! In 2010, this also included 2448 NA's.
## 20455 + 2448 = 22903
## Mystery of the rows solved.
year_freq <- pop %>%
  group_by(year) %>%
  tally

(p <- ggplot(year_freq, aes(x = year, y = n)) + geom_bar(stat = "identity"))
p + xlim(c(1800, 2010))
p + xlim(c(1945, 1955)) # huge increase at 1950
p + xlim(c(2000, 2009)) # huge drop at 2009

## keep data from 1950 to 2009
year_min <- 1950
year_max <- 2008 # choice I made in 2010 ... why not 2009? who knows
pop <- pop %>%
  filter(year >= year_min & year <= year_max)
str(pop)                             # 14105 obs. of  3 variables:

## get rid of the commas in pop (which is currently a factor!)
pop <- pop %>%
  mutate(pop = levels(pop)[as.numeric(pop)]) %>%
  mutate(pop = as.numeric(gsub(",","", pop)))
pop %>% str # 14105 obs. of  3 variables

## save for now
write.table(pop,
            "pop_raw.tsv",
            quote = FALSE, sep = "\t", row.names = FALSE)
