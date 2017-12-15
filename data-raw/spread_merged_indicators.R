# Run this after merge_indicators.R to generate a version that:
# 1) has one column for each (indicator.year) pair 
# 2) has only one row per country,
# 3) is about 20% smaller due to fewer missing values, and
# 4) is more appropriate for causal inference (eg path analysis DAG nodes(.)

package_names=c("tidyverse","janitor")
need_to_install=setdiff(package_names,installed.packages())
if(length(need_to_install)>0){
  install.packages(need_to_install,repos = "http://cran.case.edu/")  
}
for(package_name in package_names){
  library(package_name,character.only = TRUE)
}
load("../data/all_indicators.rdata")
# all_yearly_indicators<-all_indicators %>%
all_indicators %<>%
  gather(key, value, -c(geo, year)) %>%
  unite(key, c(key, year), sep = ".") %>%
  spread(key, value)
yearly_indicators <- all_indicators %>% remove_empty_cols()
rm(all_indicators)
save(yearly_indicators,file="../data/yearly_indicators.rdata",compression_level=9)
