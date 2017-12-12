
# Run this R program from the directory where you executed the git clone commands:
# git clone https://github.com/open-numbers/ddf--gapminder--systema_globalis.git
# git clone https://github.com/mledoze/countries
# These clones are automatically done if these repos re submodules of this directory.

library(tidyverse)
all_datapoints<-tibble(geo=character(),time=integer())
for(datapoints in list.files("ddf--gapminder--systema_globalis",pattern=".*datapoints.*")){
  all_datapoints<-full_join(all_datapoints,read_csv(paste0("ddf--gapminder--systema_globalis/",datapoints),guess_max=100000),by=c("geo","time"))
}
all_datapoints$geo<-toupper(all_datapoints$geo)
geos_json<-read_file("countries/countries.json")
library(jsonlite)
# "Continent" is, for whatever reason, supplanted by "region" and "subregion"
geos<-as_tibble(fromJSON(geos_json,flatten=TRUE)) %>% select(country=name.common,iso_alpha=cca3,iso_num=ccn3,continent=region,subregion=subregion)
for( countryname in c('ATA','ATF','BVT','HMD')){
  geos$subregion[geos$iso_alpha==countryname]<-geos$continent[geos$iso_alpha==countryname]<-geos$country[geos$iso_alpha=='ATA']
}

all_datapoints <- filter(all_datapoints,geo %in% geos$iso_alpha)
save(all_datapoints,file="../data/all_indicators.rdata",compression_level=9)
save(geos,file="../data/country_codes.rdata")