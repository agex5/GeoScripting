# TScriptLadies Nadine Drigo and Amy Gex
# 13 January 2017

#import libraries
library(raster)
library(rgdal)

#Source to run fuctions
source('R/NDVIFun.R')
#

#import datasets, both urls are defined as variables to be used as arguments in the following function
#if needed to change urls, make sure you change the last number to 1. not 0
A1990 = 'https://www.dropbox.com/s/akb9oyye3ee92h3/LT51980241990098-SC20150107121947.tar.gz?dl=1'
B2014 = 'https://www.dropbox.com/s/i1ylsft80ox6a32/LC81970242014109-SC20141230042441.tar.gz?dl=1'

#download datasets using defined variables above and the string to be used to create file names based on year
down_data(A1990,'1990')
down_data(B2014,'2014')

#Create stacks for both images
lt5 = list_data('LT5*.tif')
lc8 = list_data('LC8*.tif')

#Mask out clouds (NA) for both images
masked5 = maskCloudsNA(lt5)
masked8 = maskCloudsNA(lc8)

#calculate the NDVI
ndvi5 = overlay(masked5[[5]], masked5[[6]],fun=ndvi)
ndvi8 = overlay(masked8[[4]], masked8[[5]],fun=ndvi)

#Adjust the extent of the two images to be the same and calculate the difference of NDVI between the years
changeNDVI = change(ndvi5,ndvi8)
plot(changeNDVI)
