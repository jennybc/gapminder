library(gdata)     # read.xls()
library(dplyr)
library(ggplot2)
library(stringr)   # str_detect()

## extract the life expectancy data

## this is the Excel file downloaded 2009-04-21 from gapminder.org
## Yes, it was painful coming up with all the argument values necessary to
## successfully import this data. See comments at end of file.
le_xls <-
  read.xls("xls/life-expectancy-reference-spreadsheet-20090204-xls-format.xls",
           sheet = "Data and metadata",
           verbose = TRUE, quote = "", method = "tab", 
           fileEncoding =  "ISO-8859-1",
           colClasses = c(rep("character", 4), rep("NULL", 5)))
## many instances of this warning:
#Wide character in print at /Users/jenny/resources/R/libraryCRAN/gdata/perl/xls2tab.pl line 270.
le_xls %>% str
# 'data.frame':  52419 obs. of  4 variables:
# $ X.Continent.average.used..see.documentation..                                                    : chr  "\"Asia\"" "\"Asia\"" "\"Asia\"" "\"Asia\"" ...
# $ X.Country.                                                                                       : chr  "\"Abkhazia\"" "\"Abkhazia\"" "\"Abkhazia\"" "\"Abkhazia\"" ...
# $ X.Year.                                                                                          : chr  "\"1800\"" "\"1801\"" "\"1802\"" "\"1803\"" ...
# $ X.Life.expectancy.at.birth..including.Gapminder.model...not.to.be.used.for.statistical.analysis..: chr  "" "" "" "" ...

## rename vars
le_raw <- le_xls %>%
  select(country = contains("country"), continent = contains("continent"),
         year_raw = contains("year"), lifeExp_raw = contains("life.expectancy"))
le_raw %>% str
# 'data.frame':  52419 obs. of  4 variables:
# $ country    : chr  "\"Abkhazia\"" "\"Abkhazia\"" "\"Abkhazia\"" "\"Abkhazia\"" ...
# $ continent  : chr  "\"Asia\"" "\"Asia\"" "\"Asia\"" "\"Asia\"" ...
# $ year_raw   : chr  "\"1800\"" "\"1801\"" "\"1802\"" "\"1803\"" ...
# $ lifeExp_raw: chr  "" "" "" "" ...

## 2014: 52419 obs. of  4 variables:
## 2010 cleaning code comment: # 52416 obs. of  9 variables: <-- huh?
## Note: I did not use gdata::read.xls() in 2010; rather, I exported a text file
## from Excel 'by hand'.
le_raw %>% head
le_raw %>% tail

## get rid of the escaped double quotes
remove_quotes <- function(x) gsub("\"", "", x)
le_raw <- le_raw %>%
  mutate_each(funs(remove_quotes))
le_raw %>% str
# 'data.frame':  52419 obs. of  4 variables:
# $ country    : chr  "Abkhazia" "Abkhazia" "Abkhazia" "Abkhazia" ...
# $ continent  : chr  "Asia" "Asia" "Asia" "Asia" ...
# $ year_raw   : chr  "1800" "1801" "1802" "1803" ...
# $ lifeExp_raw: chr  "" "" "" "" ...

## let's fix year enough to filter on it
n_distinct(le_raw$year_raw) #210
unique(le_raw$year_raw)
## eye-ball-o-metric inspection ...

## must investigate obviously invalid values for year
(needs_a_look <- which(le_raw$year_raw %in% c("", "5")))
le_raw[(min(needs_a_look) - 4):(max(needs_a_look) + 4), ]
## early 1800s, Pakistan
## this will never survive my year filter so just make this go away
## BTW nothing visible in Excel; I can see gaps in row numbers but 'unhide' does
## nothing ... Google tell me to "unset filters" from data menu, which does
## indeed reveal the hidden rows
le_raw$year_raw[needs_a_look] <- NA_character_

le_raw$year_raw %>% n_distinct #209
le_raw$year_raw %>% unique
## nothing obviously crazy remains

## convert year to integer
le_raw <- le_raw %>%
  mutate(year = year_raw %>% as.integer)
le_raw$year %>% n_distinct #209
le_raw$year %>% unique
all.equal(sort(unique(le_raw$year[!is.na(le_raw$year)])), 1800:2007)
## Integers between 1800 and 2007. Yay.

## drop year_raw, in favor of year
le_raw <- le_raw %>%
  mutate(year_raw = NULL)

le_raw$year %>% summary
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#  1800    1852    1904    1904    1955    2007       3 
## AHA! In 2010, this did not includee 3 NA's.
## 52419 - 3 = 52416
## Mystery of the rows solved.

## for which years do we have data?
year_freq <- le_raw %>%
  group_by(year) %>%
  tally
table(year_freq$n)
# 3 252 
# 1 208 
## this solves nothing, because even when year is present, life expectancy often
## is not
## very different structure from population data :(

## change of plan: let's fix lifeExp enough to filter on it
le_raw$lifeExp_raw %>% head(100)
sum(le_raw$lifeExp_raw == "") # 46510
# 'data.frame':  5909 obs. of  5 variables:
# $ country  : chr  "\"Afghanistan\"" "\"Afghanistan\"" "\"Afghanistan\"" "\"Afghanistan\"" ...
# $ continent: chr  "\"Asia\"" "\"Asia\"" "\"Asia\"" "\"Asia\"" ...
# $ year_raw : chr  "\"1800\"" "\"1952\"" "\"1957\"" "\"1962\"" ...
# $ lifeExp  : chr  "\"28.801\"" "\"28.801\"" "\"30.332\"" "\"31.997\"" ...
# $ year     : num  1800 1952 1957 1962 1967 ...

le_raw <- le_raw %>%
  filter(lifeExp_raw != "")
str(le_raw)
# 'data.frame':  5909 obs. of  4 variables:
# $ country    : chr  "Afghanistan" "Afghanistan" "Afghanistan" "Afghanistan" ...
# $ continent  : chr  "Asia" "Asia" "Asia" "Asia" ...
# $ lifeExp_raw: chr  "28.801" "28.801" "30.332" "31.997" ...
# $ year       : num  1800 1952 1957 1962 1967 ...

## while lifeExp_raw is still character, check to see if it contains only digits
## and the decimal sign
le_seems_ok <- le_raw$lifeExp_raw %>% str_detect("[0-9\\.]")
le_seems_ok %>% table
# TRUE 
# 5909 
## I am pleasantly shocked

## convert lifeExp to numeric
le_raw <- le_raw %>%
  mutate(lifeExp = lifeExp_raw %>% as.numeric)

le_raw$lifeExp %>% summary
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 11.60   45.21   61.17   58.02   70.90   82.67 

## drop lifeExp_raw, in favor of lifeExp
le_raw <- le_raw %>%
  mutate(lifeExp_raw = NULL)

## is continent ok as is?
n_distinct(le_raw$continent) # 7
unique(le_raw$continent)
# [1] "Asia"     "Europe"   "Africa"   "Americas" ""         "FSU"      "Oceania" 

## let's look further into empty continent and FSU
(empty_continent <- le_raw %>%
   filter(continent == "") %>%
   select(country) %>%
   unique)
str(empty_continent) ## 30 countries affected, eg Canada, Haiti
## wait to fix these after merging pop + lifeExp + gdpPercap

(fsu_continent <- le_raw %>%
   filter(continent == "FSU") %>%
   select(country) %>%
   unique)
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
(p <- ggplot(le_raw, aes(x = year)) + geom_bar(binwidth = 1)) # 1950 -->
p + xlim(c(1945, 2010)) # spikes every five years
p + xlim(c(1950, 1960)) # 1952, 1957, ...
p + xlim(c(2000, 2010)) # ..., 2002, 2007

## keep data from 1950 to 2007
year_min <- 1950
year_max <- 2007
le_raw <- le_raw %>%
  filter(year >= year_min & year <= year_max)
le_raw %>% str
# 'data.frame':  3786 obs. of  4 variables:
# $ country  : chr  "Afghanistan" "Afghanistan" "Afghanistan" "Afghanistan" ...
# $ continent: chr  "Asia" "Asia" "Asia" "Asia" ...
# $ year     : num  1952 1957 1962 1967 1972 ...
# $ lifeExp  : num  28.8 30.3 32 34 36.1 ...

## save for now
write.table(le_raw,
            "02_lifeExp.tsv",
            quote = FALSE, sep = "\t", row.names = FALSE)


## EVERYTHING BELOW HERE IS COMMENTED OUT!
## NOTES ON HOW I WAS ABLE TO WRITE THE ABOVE CODE

## saving this saga for possible later demo and write-up

## initially tried a much simpler read.xls() call
# le_xls <-
#   read.xls("xls/life-expectancy-reference-spreadsheet-20090204-xls-format.xls",
#            verbose = TRUE, sheet = "Data and metadata",
#            stringsAsFactors = FALSE, fileEncoding =  "macintosh")

## technically it was successful but got these warnings:
## many instances of this:
# Wide character in print at /Users/jenny/resources/R/libraryCRAN/gdata/perl/xls2csv.pl line 270.
## and then also this:
# Warning message:
#   In scan(file, what, nmax, sep, dec, quote, skip, nlines, na.strings,  :
#             EOF within quoted string

## the default intermediate file for read.xls() is comma delimited
## in the docs:
## "Caution: In the conversion to csv, strings will be quoted"

## ultimately, I followed more advice in the docs:

# If you have quotes in your data which confuse the process you may wish to use
# read.xls(..., quote = ''). This will cause the quotes to be regarded as data
# and you will have to then handle the quotes yourself after reading the file in

# http://stackoverflow.com/questions/17414776/read-csv-warning-eof-within-quoted-string-prevents-complete-reading-of-file

## initial read.xls() import created quotes within quotes, deriving from the
## extra fields I'm not using

## this created some very strange entries for cells and screwed around with the
## number of rows

# le_xls %>% str
## 41865 obs. of  9 variables:

## these next commands almost hung R/RStudio but I did eventually get the
## command prompt back.
# levels(le_raw$year)
# nlevels(le_raw$year) # 295
# summary(le_raw$year)

## I wrote that object to file for inspection
# write.table(le_raw,
#             "01_le.tsv",
#             sep = "\t", row.names = FALSE)

## and determined that I needed to figure out this file's encoding and deal with
## the embedded quotes problem --> that meant I should switch to tab-delimited
## as the intermediate file format

## so I tried making the intermediate file explicitly and then importing it with
## read.table()

## note: at this point, I was still confused about the encoding because
## TextWrangler had indicated the encoding was Western (Mac OS Roman)

# con <-
#   xls2tab("xls/life-expectancy-reference-spreadsheet-20090204-xls-format.xls",
#           verbose = TRUE, sheet = "Data and metadata",
#           fileEncoding =  "MACROMAN")

## usual warnings about "wide character" and "EOF within quoted string"

# (temp_file <- summary(con)$description)

## here is where I decide that I want to only read the first four
## columns/variables, since it's the other columns/variables causing all the
## problems

# http://stackoverflow.com/questions/2193742/ways-to-read-only-select-columns-from-a-file-into-r-a-happy-medium-between-re
# http://stackoverflow.com/questions/5788117/only-read-limited-number-of-columns-in-r

## trying and failing to learn the number columns programmatically
# max(count.fields(temp_file, sep = "\t"))
## NA ... never seems to work

## experimenting with only reading (or retaining?) the first 4 columns

## around now is where I also figure out the correct encoding: realized a
## curly equals sign or \305 was appearing instead of capital A with a circle on
## top, which I then googled
## the country affected: Åland
## http://www.ic.unicamp.br/~stolfi/EXPORT/www/ISO-8859-1-Encoding.html
## look into how to determine encoding more automatically?
# foo <- read.delim(temp_file, quote = "",
#                   fileEncoding =  "ISO-8859-1",
#                   colClasses = c(rep("character", 4), rep("NULL", 5)))

## lines where you can see evidence of encoding problems when using read.xls()
## ineptly:

## L12068
# " 2002; Andreev"  " and 1984; Johansen"	" 2002)"	" Denmark‚Äôs health transition began in the 1770s when"
# L37785 and beyond
# " Vladimir and Ilie Hristache. 1986. Demografia teritoriala a Rom√¢niei. Bucharest.,
# Europe,Romania,1933,,,,,,
# Europe,Romania,1934,,,,,,
# ...
# Europe,Romania,2007,72.476,UN:WPP,,medium variant projection,,
# FSU,Russian Federation,1800,31.9,Riley file extrapolation,,,,5

## lessons learned going in these circles eventually led to the functional
## read.xls() call used in the live code here