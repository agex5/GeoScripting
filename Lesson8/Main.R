## TSLadies Nadine Drigo and Amy Gex
## 18 Jan 2017



#import libraries
library(raster)

# load data
load("data/GewataB1.rda")
load("data/GewataB2.rda")
load("data/GewataB3.rda")
load("data/GewataB4.rda")
load("data/GewataB5.rda")
load("data/GewataB7.rda")
load("data/vcfGewata.rda")
load("data/trainingPoly.rda")

#Eliminate values over 100 (no related to tree cover)
vcfGewata[vcfGewata > 100] <- NA

#build a brick of the data and assign names to the layers
allbands <- brick(GewataB1, GewataB2, GewataB3, 
                 GewataB4, GewataB5, GewataB7 )

names(allbands) <- c("band1", "band2", "band3", "band4", "band5", "band7")


#Add VCF layer to the dataset and give name
allbands_vcf <- addLayer(allbands, vcfGewata)

names(allbands_vcf) <- c("band1", "band2", "band3", "band4", "band5", "band7", "VCF")

#Transform raster multilayer into DataFrame
bandvcf_df <- as.data.frame(getValues(allbands_vcf))

#scatterplot
scatterplots <- pairs(allbands_vcf)
plot(scatterplots)

#linear regression model all bands and summary check for significant bands
modellmB1_7 <- lm(VCF ~ band1 + band2 + band3 + band4 + band5 +band7, data = bandvcf_df)
summary(modellmB1_7)

#after looking at summary, band 7 is not significant, thus is dropped and model is run again
signbands <- allbands[[1:5]]
modellmB1_5 <- lm(VCF ~ band1 + band2 + band3 + band4 + band5, data = bandvcf_df)
summary(modellmB1_5)

#Tree Cover prediction based on linear regression with bands 1-5
vcfpredic <- predict(signbands, model = modellmB1_5)

#Plot real and predicted tree cover
opar <- par(mfrow=c(1, 2))
plot(vcfGewata, legend=TRUE)
title(main = " VCF Tree Cover")
plot(vcfpredic, legend=TRUE)
title(main = "Predicted Tree Cover" )

#calculation of RMSE
vcfpredic_df <- as.data.frame(vcfpredic)
vcfGewata_df <- as.data.frame(vcfGewata)
rmse <- rmse(vcfpredic_df, vcfGewata_df, na.rm = TRUE)


#rasterize polygons
trainingPoly@data$Code <- as.numeric(trainingPoly@data$Class)
classes <- rasterize(trainingPoly,allbands, field='Code')

TCbrick <- brick(vcfpredic, vcfGewata)
class_matrix <-zonal(TCbrick, classes, fun = 'mean', na.rm = TRUE )

#rename the col and row on the matrix
rownames(class_matrix) <-c("cropland", "forest", "wetland")
colnames(class_matrix) <- c("zone","lr_predic", "VCF")

#calculate the RMSE of the classes
rmse_crop_predic <- rmse(vcfpredic_df, class_matrix[1,2], na.rm = TRUE)
rmse_crop_VCF <- rmse(vcfGewata_df, class_matrix[1,3], na.rm = TRUE)

rmse_forest_predic <- rmse(vcfpredic_df, class_matrix[2,2], na.rm = TRUE)
rmse_forest_VCF <- rmse(vcfGewata_df, class_matrix[2,3], na.rm = TRUE)

rmse_wetland_predic <- rmse(vcfpredic_df, class_matrix[3,2], na.rm = TRUE)
rmse_wetland_VCF <- rmse(vcfGewata_df, class_matrix[3,3], na.rm = TRUE)


#matrix
rmseClasses <- matrix(
  c(rmse_crop_predic, rmse_forest_predic, rmse_wetland_predic,
    rmse_crop_VCF, rmse_forest_VCF, rmse_wetland_VCF ),
  nrow = 3,
  ncol= 2)

rownames(rmseClasses) <-c("cropland", "forest", "wetland")
colnames(rmseClasses) <- c("lr_predic", "VCF")
