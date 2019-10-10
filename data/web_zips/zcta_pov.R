rm(list=ls(all=TRUE))
library(sf)
library(tidyverse)

setwd("c:/Project/SNAP-Ed")

zcta<-st_read("Data/SHP/Area boundary/tl_2018_us_zcta510_500k_ga.shp") %>%
  st_transform(4326) %>%
  mutate(gisjn_zcta=as.character(GEOID10)) %>%
  select(gisjn_zcta)

ggplot(zcta)+geom_sf()

povdata<-read_csv("ACS_17_5YR_S1701_with_ann.csv") %>%
  mutate(gisjn_zcta=as.character(gisjn_zcta))

zcta_pov<-zcta %>%
  left_join(povdata) %>%
  filter(is.na(povpop)==FALSE) %>%
  mutate(pov185_rt=round(pov185pop/totpop*100,0),
         elig=if_else(pov185_rt>=50,1,0),
         elig45=if_else(pov185_rt>=45,1,0),
         elig40=if_else(pov185_rt>=40,1,0))
zcta_pov$row.id<-1:nrow(zcta_pov)
zcta_pov$col.id<-1:nrow(zcta_pov)

zcta_buff<-zcta_pov %>%
  filter(elig==1) %>%
  summarise()

ggplot(zcta_buff)+geom_sf()

# zcta_buff<-zcta_pov %>%
#   filter(elig==1) %>%
#   summarise() %>%
#   st_buffer(.005) %>%
#   st_difference(zcta_pov %>%
#                     filter(elig==1))

zcta_contig<-zcta %>%
  st_touches(zcta_buff)

zcta_contig1<-as.tibble(zcta_contig) %>%
  left_join(zcta_pov %>% select(row.id),by="row.id") %>%  
  left_join(zcta_pov,by="row.id")

zcta1<-st_drop_geometry(zcta)
zcta_contig2<-zcta_contig1 %>%
  select(-geometry.x,-geometry.y)

zcta_contig3<-merge(zcta1,zcta_contig2,by.x = "gisjn_zcta",by.y = "gisjn_zcta", all = T)
write_csv(zcta_contig3,"zcta_contig.csv")


#  library(tmap)
# tmap_mode("view")
# tm_shape(zcta_buff)+
#   tm_polygons() 
# 
# tm_shape(zcta_pov %>% filter(elig==1))+
#   tm_polygons()


