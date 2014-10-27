library(dplyr)
library(tidyr)
library(ggplot2)

## extract the GDP per capita data

## 2014-10-26 NOTE:
## I am punting here for the moment and basing intake on manually exported 
## delimited text. For population and life expectancy, I have re-implemented the
## Excel extraction programmatically using gdata::read.xls(), which I plan to 
## try here as well. But I expect GDP per capita will be challenging because the
## spreadsheet is transposed relative to the other two.

## this is the Excel file downloaded 2009-04-30 from gapminder.org:
## gapdata001-1.xlsx

## in Excel, I ruthlessly deleted tons of
## columns at front and up to 1950, then saved as tab-delimited text file
## gdpPercap.txt

gdp_xls <-
  read.delim("xls-manual-extract/gdpPercap.txt",fileEncoding =  "ISO-8859-1")
gdp_xls %>% str(list.len = 4)  # 259 obs. of  59 variables:
gdp_xls %>% head
## Sadly, this file is transposed relative to population and life expectancy.
## Each row is a country and the columns give the GDP data for different years. 
## What a mess.

## reshape the data by gathering all the year variables
gdp_tidy <- gdp_xls %>%
  gather(key = "Xyear", value = "gdpPercap", -Area)
gdp_tidy %>% str

## rename Area --> country and fix the years
gdp_tidy <- gdp_tidy %>%
  rename(country = Area) %>%
  mutate(Xyear = levels(Xyear)[as.numeric(Xyear)],
         year = gsub("X", "", Xyear) %>% as.integer,
         Xyear = NULL)
gdp_tidy %>% str

## filter rows where gdpPercap is NA
gdp_tidy <- gdp_tidy %>%
  filter(!is.na(gdpPercap))
gdp_tidy %>% str

## look into the coverage by year
summary(gdp_tidy$year)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1950    1967    1981    1981    1995    2007 

(p <- ggplot(gdp_tidy, aes(x = year)) + geom_bar(binwidth = 1))
## unlike population and life expectancy, there's no obvious reason to filter on
## year at this point

## is country ok as is?
n_distinct(gdp_tidy$country) # 229
unique(gdp_tidy$country)
## no obvious problems

## save for now
write.table(gdp_tidy,
            "03_gdpPercap.tsv",
            quote = FALSE, sep = "\t", row.names = FALSE)
