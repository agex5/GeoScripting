#TSLadies Nadine Drigo and Amy Gex
# 16 Jan 2016

#set working directory if needed
#setwd()
#download and unzip the data in a directory called data

#Import libraries
library(raster)
library(rgdal)
library(rgeos)

#source
source("R/Functions.R")

#reading the data
railways <- readOGR(dsn = "data", layer="railways")
places <- readOGR(dsn = "data", layer = "places")

#selection of the type == industrial
indust_rail <- railways[railways@data$type == "industrial", ]

#change projection to RD
indust_railRD <- RD_proj(indust_rail)
placesRD <- RD_proj(places)

#Buffer the railway 
buffer_rail <- gBuffer(indust_railRD, width = 1000, byid = TRUE)

#Intersect the railway buffer with the placesRD SpatialPointsdataframe
railplaces_intersect <- gIntersection(placesRD, buffer_rail, 
                                  id=as.character(placesRD$osm_id), byid= TRUE)

#we manually found the osm_id of the point 
##if you have any solution...
id = railplaces_intersect@coords

#Get data about intersected city (info was lost from the intersection) and population
point_data= placesRD[ which(placesRD$osm_id=="235861650"),]
population = point_data$population

#Plotting everything together
plot(buffer_rail, col = "green" )
plot(railplaces_intersect, add = TRUE, col = "red")
plot(placesRD@data$name, add=TRUE, col = "blue")
text(point_data, labels = point_data$name)
title(main = "Intersection of City and Industrial Railway Buffered to 1000m", cex.main = 1, font.main = 2 )
box()

# The population of Utrecht is 100000
population