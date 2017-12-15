
# Run this R program from the directory where you executed the git clone commands:
# git clone https://github.com/open-numbers/ddf--gapminder--systema_globalis.git
# git clone https://github.com/mledoze/countries
# These clones are automatically done if these repos re submodules of this directory.

package_names=c("tidyverse","janitor","jsonlite")
need_to_install=setdiff(package_names,installed.packages())
if(length(need_to_install)>0){
  install.packages(need_to_install,repos = "http://cran.case.edu/")  
}
for(package_name in package_names){
  library(package_name,character.only = TRUE)
}

all_indicators<-tibble(geo=character(),time=integer())
for(datapoints in list.files("ddf--gapminder--systema_globalis",pattern=".*datapoints.*")){
  all_indicators<-full_join(all_indicators,read_csv(paste0("ddf--gapminder--systema_globalis/",datapoints),guess_max=100000),by=c("geo","time"))
}
all_indicators %<>% rename(year=time)
all_indicators %<>% clean_names() %>% remove_empty_rows() %>% remove_empty_cols()
all_indicators$geo<-toupper(all_indicators$geo)
geos_json<-read_file("countries/countries.json")

# "Continent" is, for whatever reason, supplanted by "region" and "subregion"
geos<-as_tibble(fromJSON(geos_json,flatten=TRUE)) %>% select(country=name.common,iso_alpha=cca3,iso_num=ccn3,continent=region,subregion=subregion)
for( countryname in c('ATA','ATF','BVT','HMD')){
  geos$subregion[geos$iso_alpha==countryname]<-geos$continent[geos$iso_alpha==countryname]<-geos$country[geos$iso_alpha=='ATA']
}

all_indicators <- filter(all_indicators,geo %in% geos$iso_alpha)
save(all_indicators,file="../data/all_indicators.rdata",compression_level=9)
save(geos,file="../data/country_codes.rdata")