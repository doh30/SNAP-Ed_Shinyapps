##Create the geopackage data for the Shiny application and data for the analysis

library(tidyverse)
library(sf)

#Read the store data
stores<-read_csv("data/snap_retailers_usda_ga_ver3.csv")
stores_sf<-st_as_sf(stores,coords=c("X","Y"),crs=4326,remove=FALSE)
stores_sf<-st_write(stores_sf,"data/snap_retailers_usda_ga_ver3.gpkg",delete_layer=TRUE)

# #Write to the github repo
# stores_usda<-stores %>% select(store_name:dup)
# stores_crosswalk<-stores %>% select(store_name,storeid,st_fips:gisjn_puma)
# 
# write_csv(stores_usda,"data/snap_retailers_usda.csv")
# write_csv(stores_crosswalk,"data/snap_retailers_crosswalk.csv")

#County list
# counties<-st_read("data/US_Counties_2012.shp")
# st_geometry(counties)<-NULL

# states<-stores %>% 
#   select(state,st_fips) %>% 
#   mutate(st_fips=substr(st_fips,1,2)) %>%
#   distinct()
# 
# counties_sm<-counties %>% 
#   select(NAMELSAD,STATEFP,COUNTYFP,GEOID) %>%
#   rename("county"=NAMELSAD,
#          "st_fips"=STATEFP,
#          "cty_fips"=COUNTYFP,
#          "stcty_fips"=GEOID) %>%
#   left_join(states) %>%
#   mutate(fullname=paste(county,state,sep=", "))
# 
# write_csv(counties_sm,"data/county_list.csv")

#Read in the biggest five MSAs in each census region
# msa5<-read_csv("shiny/msa5_ranks_2018_07_25.csv") 
# stores_msa5<-stores %>%
#   filter(msa_fips %in% msa5$GEOID)
counties_sm<-read_csv("data/county_list.csv")

stores_ga<-stores %>%
  filter(GEOID %in% counties_sm$stcty_fips)

#Create a function that filters stores by MSA and writes them to the geopackage
cty_write<-function(cty_id){
  stores_select<-stores_ga %>%
    filter(GEOID==cty_id)
  
  stores_select_sf<-st_as_sf(stores_select,coords=c("X","Y"),crs=4326,remove=FALSE)
  filename<-paste("G",cty_id,sep="")
  st_write(stores_select_sf,"data/snap_retailers_usda_ga_ver3.gpkg",layer=filename,delete_layer=TRUE)
}

map(counties_sm$stcty_fips,cty_write)

##Write all files to a geopackage
# state_write<-function(st_id){
#   stores_select<-stores %>%
#     filter(st_fips==st_id)
#   
#   stores_select_sf<-st_as_sf(stores_select,coords=c("X","Y"),crs=4326,remove=FALSE)
#   filename<-paste(st_id,sep="")
#   st_write(stores_select_sf,"data/storepoints_ga.gpkg",layer=filename,delete_layer=TRUE)
# }
# 
# states<-stores %>% 
#   select(st_fips) %>% 
#   filter(is.na(st_fips)==FALSE) %>%
#   distinct()
# 
# map(states$st_fips,state_write)
