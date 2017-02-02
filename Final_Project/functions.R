#The Script Ladies Nadine Drigo and Amy Gex
# 2 Feb 2017

#libraries
library(leaflet)
library(magrittr)
library(htmlwidgets)
library(ggplot2)

#function to reproject
reproj_wgs84 <- function(var){
  spTransform(var, CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))
}

#function to process fire points
fire.select <- function(shp){
  select <- subset(shp, select = c(1,2,6,10,13))
  return(select)
}

#function to check "is in"
check.inside <- function(point, poly){
  check <- !is.na(over(point, as(poly, "SpatialPolygons")))
  subset <- point[check,]
  return(subset)
}

#function to bind input objects from overlay
combine <- function(var1, var2){
  spRbind(var1, var2)
}

#Temporal Plot function to create .png files
Tserie_plot <- function(reglist, db) {
  for (i in 1:length(reglist)){
    region <- db[which(db$REGIONS == reglist[i]),]
    region_df <- as.data.frame(region)
    region_df$date <- as.Date(region_df$ACQ_DATE)
    #ratio.display <- 4/3
    #ratio.values <- (max(region_df$date)-min(region_df$date))/(max(region_df$FRP)-min(region_df$FRP))
    theme_set(theme_bw())  
    ggplot(aes(x = date, y = FRP), data = region_df) + 
      geom_point(aes(color = LandUse), size = 3) +
      #coord_fixed(ratio.display) +
      #coord_fixed(ratio.values) +
      scale_x_date() + xlab("Years") + ylab("Fire Radiative Power (MW)") +
      scale_color_manual(values = c("Artificial surfaces" = "lavenderblush4", "Agricultural areas" = "chartreuse3","Forest and semi-natural areas" = "green4", "Wetlands" = "seagreen3", "Waterbodies" = "blue3"))
    ggsave(filename = paste0(reglist[i],".png"), plot = last_plot(), device = NULL, scale = 1, width = 6 , height = 6, units = c("in","cm", "mm"), dpi =100, limitsize = TRUE)
  }
}

#Function to create map of fire zones per region
mapplot <- function(poly1, poly3, pnt, apopup){
  leaflet() %>% 
    setView(12.5674, 41.8719, zoom = 5) %>%
    addProviderTiles("CartoDB.Positron") %>%
    addPolygons(data = poly1, weight = 1, fill = TRUE, group = "Regions", popup = apopup) %>%
    #addPolygons(data = poly2, weight = 1, fill = TRUE, color = '#087214', group = "Special Protected Areas") %>%
    addPolygons(data = poly3, weight = 1, fill = TRUE, color ='#31ba06' , group = "Special Conservation Areas" ) %>%
    addCircleMarkers(data = pnt, weight = 1, radius = 2, color = "#f06f04", group = "Fires") %>%
    addLayersControl(
      overlayGroups = c("Regions", "Special Conservation Areas", "Fires"),
      options = layersControlOptions(collapsed = FALSE))
}
 #"Special Protected Areas",



