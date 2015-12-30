`r format(Sys.Date())`  
Cleaning history

* 2010: The first time I documented cleaning this dataset. I started with
delimited files I exported from Excel.
* 2014: I re-cleaned the data and (mostly) forced myself to pull it straight
out of the spreadsheets. Used the gdata package.
* 2015: I revisited the cleaning and switched to the readxl and readr
packages.


```r
suppressPackageStartupMessages(library(dplyr))
library(tidyr)
library(ggplot2)
library(readr)
```

Extract the GDP per capita data from the Excel file downloaded 2009-04-30 
from gapminder.org.

2015-12-29 NOTE: I am punting here for the moment and basing intake on 
manually exported delimited text. For population and life expectancy, I have 
re-implemented the Excel extraction programmatically using gdata::read.xls() 
(2014) and then readxl (2015), which I plan to try here as well. But I dread
doing GDP per capita because the spreadsheet is transposed relative to the
other two. In Excel, I ruthlessly deleted tons of columns at front and up to
1950, then saved as tab-delimited text file gdpPercap.txt.


```r
gdp_xls <- read_tsv("xls-manual-extract/gdpPercap.txt")
gdp_xls %>% str(list.len = 4)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	259 obs. of  59 variables:
##  $ Area: chr  "Abkhazia" "Afghanistan" "Akrotiri and Dhekelia" "Albania" ...
##  $ 1950: num  NA 757 NA 1532 2429 ...
##  $ 1951: num  NA 767 NA 1598 2398 ...
##  $ 1952: num  NA 779 NA 1601 2449 ...
##   [list output truncated]
```

```r
gdp_xls %>% head()
```

```
## Source: local data frame [6 x 59]
## 
##                    Area      1950      1951      1952      1953      1954
##                   (chr)     (dbl)     (dbl)     (dbl)     (dbl)     (dbl)
## 1              Abkhazia        NA        NA        NA        NA        NA
## 2           Afghanistan  757.3188  766.7522  779.4453  812.8563  815.3595
## 3 Akrotiri and Dhekelia        NA        NA        NA        NA        NA
## 4               Albania 1532.3539 1598.4927 1601.0561 1665.7947 1714.6888
## 5               Algeria 2429.2137 2397.5311 2449.0082 2436.3400 2557.8185
## 6        American Samoa 4465.1447        NA        NA        NA        NA
## Variables not shown: 1955 (dbl), 1956 (dbl), 1957 (dbl), 1958 (dbl), 1959
##   (dbl), 1960 (dbl), 1961 (dbl), 1962 (dbl), 1963 (dbl), 1964 (dbl), 1965
##   (dbl), 1966 (dbl), 1967 (dbl), 1968 (dbl), 1969 (dbl), 1970 (dbl), 1971
##   (dbl), 1972 (dbl), 1973 (dbl), 1974 (dbl), 1975 (dbl), 1976 (dbl), 1977
##   (dbl), 1978 (dbl), 1979 (dbl), 1980 (dbl), 1981 (dbl), 1982 (dbl), 1983
##   (dbl), 1984 (dbl), 1985 (dbl), 1986 (dbl), 1987 (dbl), 1988 (dbl), 1989
##   (dbl), 1990 (dbl), 1991 (dbl), 1992 (dbl), 1993 (dbl), 1994 (dbl), 1995
##   (dbl), 1996 (dbl), 1997 (dbl), 1998 (dbl), 1999 (dbl), 2000 (dbl), 2001
##   (dbl), 2002 (dbl), 2003 (dbl), 2004 (dbl), 2005 (dbl), 2006 (dbl), 2007
##   (dbl).
```

Sadly, this file is transposed relative to population and life expectancy. 
Each row is a country and the columns give the GDP data for different years. 
WHY?!?

Reshape the data by gathering all the year variables.


```r
gdp_tidy <- gdp_xls %>%
  gather(key = "Xyear", value = "gdpPercap", -Area)
gdp_tidy %>% str()
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	15022 obs. of  3 variables:
##  $ Area     : chr  "Abkhazia" "Afghanistan" "Akrotiri and Dhekelia" "Albania" ...
##  $ Xyear    : Factor w/ 58 levels "1950","1951",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ gdpPercap: num  NA 757 NA 1532 2429 ...
```

Rename Area --> country and fix the years.


```r
gdp_tidy <- gdp_tidy %>%
  rename(country = Area) %>%
  mutate(Xyear = levels(Xyear)[as.numeric(Xyear)],
         year = gsub("X", "", Xyear) %>% as.integer(),
         Xyear = NULL)
gdp_tidy %>% str()
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	15022 obs. of  3 variables:
##  $ country  : chr  "Abkhazia" "Afghanistan" "Akrotiri and Dhekelia" "Albania" ...
##  $ gdpPercap: num  NA 757 NA 1532 2429 ...
##  $ year     : int  1950 1950 1950 1950 1950 1950 1950 1950 1950 1950 ...
```

Filter rows where gdpPercap is `NA`.


```r
gdp_tidy <- gdp_tidy %>%
  filter(!is.na(gdpPercap))
gdp_tidy %>% str()
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	10911 obs. of  3 variables:
##  $ country  : chr  "Afghanistan" "Albania" "Algeria" "American Samoa" ...
##  $ gdpPercap: num  757 1532 2429 4465 3363 ...
##  $ year     : int  1950 1950 1950 1950 1950 1950 1950 1950 1950 1950 ...
```

Look into the coverage by year.


```r
summary(gdp_tidy$year)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##    1950    1967    1981    1981    1995    2007
```

```r
(p <- ggplot(gdp_tidy, aes(x = year)) + geom_histogram(binwidth = 1))
```

![](03_extract-from-excel-gdpPercap_files/figure-html/unnamed-chunk-6-1.png)\ 

Unlike population and life expectancy, there's no obvious reason to filter on
year at this point.

Is country ok as is?


```r
n_distinct(gdp_tidy$country)
```

```
## [1] 229
```

```r
unique(gdp_tidy$country)
```

```
##   [1] "Afghanistan"                      "Albania"                         
##   [3] "Algeria"                          "American Samoa"                  
##   [5] "Angola"                           "Argentina"                       
##   [7] "Armenia"                          "Australia"                       
##   [9] "Austria"                          "Azerbaijan"                      
##  [11] "Bahamas"                          "Bahrain"                         
##  [13] "Bangladesh"                       "Barbados"                        
##  [15] "Belarus"                          "Belgium"                         
##  [17] "Belize"                           "Benin"                           
##  [19] "Bermuda"                          "Bhutan"                          
##  [21] "Bolivia"                          "Bosnia and Herzegovina"          
##  [23] "Botswana"                         "Brazil"                          
##  [25] "Brunei"                           "Bulgaria"                        
##  [27] "Burkina Faso"                     "Burundi"                         
##  [29] "Cambodia"                         "Cameroon"                        
##  [31] "Canada"                           "Cape Verde"                      
##  [33] "Central African Rep."             "Chad"                            
##  [35] "Chile"                            "China"                           
##  [37] "Colombia"                         "Comoros"                         
##  [39] "Congo, Dem. Rep."                 "Congo, Rep."                     
##  [41] "Costa Rica"                       "Cote d'Ivoire"                   
##  [43] "Croatia"                          "Cuba"                            
##  [45] "Cyprus"                           "Czech Rep."                      
##  [47] "Denmark"                          "Djibouti"                        
##  [49] "Dominica"                         "Dominican Rep."                  
##  [51] "Ecuador"                          "Egypt"                           
##  [53] "El Salvador"                      "Equatorial Guinea"               
##  [55] "Eritrea"                          "Estonia"                         
##  [57] "Ethiopia"                         "Finland"                         
##  [59] "France"                           "French Guiana"                   
##  [61] "French Polynesia"                 "Gabon"                           
##  [63] "Gambia"                           "Germany"                         
##  [65] "Ghana"                            "Greece"                          
##  [67] "Grenada"                          "Guadeloupe"                      
##  [69] "Guatemala"                        "Guinea"                          
##  [71] "Guinea-Bissau"                    "Guyana"                          
##  [73] "Haiti"                            "Honduras"                        
##  [75] "Hong Kong, China"                 "Hungary"                         
##  [77] "Iceland"                          "India"                           
##  [79] "Indonesia"                        "Iran"                            
##  [81] "Iraq"                             "Ireland"                         
##  [83] "Isle of Man"                      "Israel"                          
##  [85] "Italy"                            "Jamaica"                         
##  [87] "Japan"                            "Jordan"                          
##  [89] "Kazakhstan"                       "Kenya"                           
##  [91] "Korea, Dem. Rep."                 "Korea, Rep."                     
##  [93] "Kuwait"                           "Kyrgyzstan"                      
##  [95] "Laos"                             "Lebanon"                         
##  [97] "Lesotho"                          "Liberia"                         
##  [99] "Libya"                            "Lithuania"                       
## [101] "Luxembourg"                       "Macao, China"                    
## [103] "Macedonia, FYR"                   "Madagascar"                      
## [105] "Malawi"                           "Malaysia"                        
## [107] "Maldives"                         "Mali"                            
## [109] "Malta"                            "Martinique"                      
## [111] "Mauritania"                       "Mauritius"                       
## [113] "Mexico"                           "Moldova"                         
## [115] "Mongolia"                         "Montenegro"                      
## [117] "Morocco"                          "Mozambique"                      
## [119] "Myanmar"                          "Namibia"                         
## [121] "Nepal"                            "Netherlands"                     
## [123] "New Caledonia"                    "New Zealand"                     
## [125] "Nicaragua"                        "Niger"                           
## [127] "Nigeria"                          "Northern Mariana Islands"        
## [129] "Norway"                           "Oman"                            
## [131] "Pakistan"                         "Panama"                          
## [133] "Papua New Guinea"                 "Paraguay"                        
## [135] "Peru"                             "Philippines"                     
## [137] "Poland"                           "Portugal"                        
## [139] "Puerto Rico"                      "Reunion"                         
## [141] "Romania"                          "Russia"                          
## [143] "Rwanda"                           "Saint Lucia"                     
## [145] "Saint Vincent and the Grenadines" "Sao Tome and Principe"           
## [147] "Saudi Arabia"                     "Senegal"                         
## [149] "Serbia"                           "Seychelles"                      
## [151] "Sierra Leone"                     "Singapore"                       
## [153] "Slovak Republic"                  "Slovenia"                        
## [155] "Somalia"                          "South Africa"                    
## [157] "Spain"                            "Sri Lanka"                       
## [159] "Sudan"                            "Suriname"                        
## [161] "Swaziland"                        "Sweden"                          
## [163] "Switzerland"                      "Syria"                           
## [165] "Taiwan"                           "Tajikistan"                      
## [167] "Tanzania"                         "Thailand"                        
## [169] "Timor-Leste"                      "Togo"                            
## [171] "Trinidad and Tobago"              "Tunisia"                         
## [173] "Turkey"                           "Turkmenistan"                    
## [175] "Uganda"                           "Ukraine"                         
## [177] "United Kingdom"                   "United States"                   
## [179] "Uruguay"                          "Uzbekistan"                      
## [181] "Wallis et Futuna"                 "Venezuela"                       
## [183] "West Bank and Gaza"               "Vietnam"                         
## [185] "Yemen, Rep."                      "Zambia"                          
## [187] "Zimbabwe"                         "United Arab Emirates"            
## [189] "Fiji"                             "Georgia"                         
## [191] "Latvia"                           "Solomon Islands"                 
## [193] "Andorra"                          "Anguilla"                        
## [195] "Antigua and Barbuda"              "Aruba"                           
## [197] "British Virgin Islands"           "Cayman Islands"                  
## [199] "Cook Islands"                     "Greenland"                       
## [201] "Kiribati"                         "Liechtenstein"                   
## [203] "Micronesia, Fed. Sts."            "Monaco"                          
## [205] "Montserrat"                       "Nauru"                           
## [207] "Netherlands Antilles"             "Palau"                           
## [209] "Qatar"                            "Saint Kitts and Nevis"           
## [211] "San Marino"                       "Turks and Caicos Islands"        
## [213] "Tuvalu"                           "Guernsey"                        
## [215] "Marshall Islands"                 "Samoa"                           
## [217] "Tonga"                            "Vanuatu"                         
## [219] "Saint Helena"                     "Faeroe Islands"                  
## [221] "Falkland Islands (Malvinas)"      "Gibraltar"                       
## [223] "Jersey"                           "Kosovo"                          
## [225] "Mayotte"                          "Niue"                            
## [227] "Northern Cyprus"                  "Saint-Pierre-et-Miquelon"        
## [229] "Tokelau"
```

No obvious train wrecks.
Save for now.


```r
write_tsv(gdp_tidy, "03_gdpPercap.tsv")

devtools::session_info()
```

```
## Session info --------------------------------------------------------------
```

```
##  setting  value                       
##  version  R version 3.2.3 (2015-12-10)
##  system   x86_64, darwin13.4.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_CA.UTF-8                 
##  tz       America/Vancouver           
##  date     2015-12-29
```

```
## Packages ------------------------------------------------------------------
```

```
##  package    * version    date       source                          
##  assertthat   0.1        2013-12-06 CRAN (R 3.2.0)                  
##  colorspace   1.2-6      2015-03-11 CRAN (R 3.2.0)                  
##  DBI          0.3.1      2014-09-24 CRAN (R 3.2.0)                  
##  devtools     1.9.1.9000 2015-12-18 Github (hadley/devtools@9aaa3af)
##  digest       0.6.8      2014-12-31 CRAN (R 3.2.0)                  
##  dplyr      * 0.4.3.9000 2015-11-24 Github (hadley/dplyr@4f2d7f8)   
##  evaluate     0.8        2015-09-18 CRAN (R 3.2.0)                  
##  formatR      1.2.1      2015-09-18 CRAN (R 3.2.0)                  
##  ggplot2    * 2.0.0      2015-12-18 CRAN (R 3.2.3)                  
##  gtable       0.1.2      2012-12-05 CRAN (R 3.2.0)                  
##  htmltools    0.2.6      2014-09-08 CRAN (R 3.2.0)                  
##  knitr        1.11.16    2015-11-23 Github (yihui/knitr@6e8ce0c)    
##  labeling     0.3        2014-08-23 CRAN (R 3.2.0)                  
##  lazyeval     0.1.10     2015-01-02 CRAN (R 3.2.0)                  
##  magrittr     1.5        2014-11-22 CRAN (R 3.2.0)                  
##  memoise      0.2.1      2014-04-22 CRAN (R 3.2.0)                  
##  munsell      0.4.2      2013-07-11 CRAN (R 3.2.0)                  
##  plyr         1.8.3      2015-06-12 CRAN (R 3.2.0)                  
##  R6           2.1.1      2015-08-19 CRAN (R 3.2.0)                  
##  Rcpp         0.12.2     2015-11-15 CRAN (R 3.2.2)                  
##  readr      * 0.2.2      2015-10-22 CRAN (R 3.2.0)                  
##  rmarkdown    0.9        2015-12-22 CRAN (R 3.2.3)                  
##  scales       0.3.0      2015-08-25 CRAN (R 3.2.0)                  
##  stringi      1.0-1      2015-10-22 CRAN (R 3.2.0)                  
##  stringr      1.0.0      2015-04-30 CRAN (R 3.2.0)                  
##  tidyr      * 0.3.1.9000 2015-12-29 Github (hadley/tidyr@d534fc7)   
##  yaml         2.1.13     2014-06-12 CRAN (R 3.2.0)
```


---
title: "03_extract-from-excel-gdpPercap.R"
author: "jenny"
date: "Tue Dec 29 21:51:53 2015"
---
