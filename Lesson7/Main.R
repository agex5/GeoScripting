#TheScriptLadies - Nadine Drigo and Amy Gex
# 17 Jan 2017



#set working directory
setwd()

#source
source("R/functions.R")


#Import Libraries
library(raster)
library(rgdal)

#download file and get boundary data
dir.create("data")
download.file(url= "https://raw.githubusercontent.com/GeoScripting-WUR/VectorRaster/gh-pages/data/MODIS.zip", 
              destfile = "data/MODIS.zip", method = 'auto')
unzip('data/MODIS.zip', exdir = "data")
nlMunicipality <- getData('GADM', country = 'NLD', level=2, path = "data")

#Create baselayer for map
nlplot <- getData('GADM', country = 'NLD', level=1, path = "data")

#Identify MODIS file and brick
modispath <- list.files(path ="data", pattern = glob2rx('MOD1*.grd'), full.names = TRUE)
modis <- brick(modispath)

#reproject municipality to the raster CRS
nlMunReproject <- spTransform(nlMunicipality, CRS(proj4string(modis)))

#Mask the MODIS with the municipality vector
modis_mask <- mask(modis,nlMunReproject)

#call function to calculate average NDVI on all the year
meanyear <- meanCalc(modis_mask)

#extract NDVI information from raster and add to SpatialPolygonDataFrame
greenValues <- extract(modis_mask, nlMunReproject, sp=TRUE, fun = mean, na.rm = TRUE)
greenValues_yearMean <- extract(meanyear, nlMunReproject, sp=TRUE, fun = mean, na.rm = TRUE)

#selection of the max values (jan, aug, year_mean)
max_jan <- greenValues[which.max(greenValues$January),]
max_august <- greenValues[which.max(greenValues$August),]
max_year_mean <- greenValues_yearMean[which.max(greenValues_yearMean$layer),]


jan <- reproject(max_jan, nlMunicipality)
aug <- reproject(max_august, nlMunicipality)
year <- reproject(max_year_mean, nlMunicipality)



plot(nlplot, col = "lightgrey")
plot(jan, add = TRUE, col = "orange")
plot(aug, add = TRUE, col = "green")
plot(year, add = TRUE, col = "purple")
title(main = "Greenest Municipalities in the Netherlands")
legend("bottomleft", title = "Legend", 
       legend = c("January","August", "Mean Year"), 
       col = c("orange", "green", "purple"),
       cex = 0.9, pch = 15)
text(x=jan, labels = jan$NAME_2, cex = 0.9, pch = 15)
text(x=aug, labels = aug$NAME_2, cex = 0.9, pch = 15)
text(x=year, labels = year$NAME_2, cex = 0.9, pch = 15)
box()






