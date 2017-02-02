##GeoScripting Project - Time Series (2012-2016) of Active Fires in Italy
## Nadine Drigo and Amy Gex
## 2 Feb 2017


##Import required libraries (install if necessary)
library(rgdal)
library(sp)
library(rgeos)
library(ggplot2)
library(maptools)
library(leaflet)
library(magrittr)
library(htmlwidgets)

#check and set working directories
wd = getwd()
#NOT CREATE if already exists
dir.create("Data")
dir.create("Output")
datadir = paste0(wd, "/Data")
outdir = paste0(wd,"/Output")
setwd(wd)

#Set source files for functions
source('functions.R')

##Download file and unzip
#set directory for file download
setwd(datadir)

##Note active fire data was requested directly from NASA and therefore will be provided along with script
#Natura2000SIC
download.file(url = "ftp://ftp.minambiente.it/PNM/Natura2000/TrasmissioneCE_2016/perimetri%20SIC_ZSC_2016.zip",
              destfile = "Nat2000SIC.zip", method = "wget")
system("unzip Nat2000SIC.zip -d Nat2000SIC")
unlink("Nat2000SIC.zip")

#Natura2000ZPS
download.file(url = "ftp://ftp.minambiente.it/PNM/Natura2000/TrasmissioneCE_2016/perimetri%20ZPS_2016.zip",
              destfile = "Nat2000ZPS.zip", method = "wget")
system("unzip Nat2000ZPS.zip -d Nat2000ZPS")
unlink("Nat2000ZPS.zip")

#CorineLC
download.file(url = "http://www.sinanet.isprambiente.it/it/sia-ispra/download-mais/corine-land-cover/corine-land-cover-2012/at_download/file", 
              destfile = "CLC.rar", method = "wget")
dir.create("CLC")
#Make sure unrar package is installed in the terminal, write "sudo apt install unrar"
system("unrar e CLC.rar CLC")
unlink("CLC.rar")

#Get Italy Regions 
dir.create("Italy")
setwd(paste0(datadir,'/Italy'))
Italy <- raster::getData('GADM',country='ITA', level=1)

##Open and read needed files
setwd(datadir)
fire_arch <- readOGR(dsn ="FirePoints", layer = "fire_archive_M6_5786")
fire_nrt <- readOGR(dsn ="FirePoints", layer = "fire_nrt_M6_5786")
corineLC <- readOGR(dsn = 'CLC', layer ='clc12_3liv' )
n2k_zps <- readOGR(dsn = 'Nat2000ZPS', layer = 'zps_ita_32')
n2k_sic <- readOGR(dsn = 'Nat2000SIC', layer = 'sic_ita_32')

##Reproject datasets to matching projections
fire_arch_rp <- reproj_wgs84(fire_arch)
fire_nrt_rp <- reproj_wgs84(fire_nrt)
n2k_zps_rp <- reproj_wgs84(n2k_zps)
n2k_sic_rp <- reproj_wgs84(n2k_sic)
corineLC_rp <- reproj_wgs84(corineLC)
Italy <- reproj_wgs84(Italy)


#Create column with adjusted region names for future file writing
Italy$FILENAME <- gsub(" ", "", Italy$NAME_1, fixed = TRUE)
Italy$FILENAME <- gsub("'", "", Italy$FILENAME, fixed = TRUE)


### Adjust active fire points to only be in protected areas ###
#Select columns to keep/use from spatial point dataframes
fire_arch_selec <- fire.select(fire_arch_rp)
fire_nrt_selec <- fire.select(fire_nrt_rp)

#Combine archive and near real time fire point data
fire_combi <- spRbind(fire_arch_selec, fire_nrt_selec)

#subtract type C from zps since it overlaps with sic
zps <- n2k_zps_rp[n2k_zps_rp$TIPO_SITO != "C", ]

#Check if points are inside nature zones and select subset
fire_in_zps <- check.inside(fire_combi, zps)
fire_in_sic <- check.inside(fire_combi, n2k_sic_rp)

#Combine subset into one
fire_in_natura <- combine(fire_in_zps, fire_in_sic)

#Add info(LU and Regions) to final points set
fireLC <- check.inside(fire_in_natura, corineLC_rp)
fireLC$LANDCOVER <- over(fireLC, corineLC_rp)$CLC12_3L_2

#since the natura2000 files also include maritime zones, make sure points are only on land
fire_on_land <- check.inside(fireLC, Italy)
fire_on_land$REGIONS <- over(fire_on_land, Italy)$FILENAME

#Select for confidenc
fire_on_land <- fire_on_land[fire_on_land$FRP > 0, ]
fire_on_land <- fire_on_land[fire_on_land$CONFIDENCE >= 50,]

#change directory to output and write to file
setwd(outdir)
writeOGR(fire_on_land, dsn = 'Fire_N2K', layer ='fire_in_natura' , driver = 'ESRI Shapefile', overwrite = TRUE)


setwd(datadir)
fire <- readOGR(dsn = "../Output/Fire_N2K", layer ='fire_in_natura')


### Time series ###

#Transform the CLC code to number
fire$LANDCOVER_N <- as.numeric(substr(fire$LANDCOVER, 0,1))

#Assign the LandUse label to the df
fire$LandUse[fire$LANDCOVER_N==1] <- "Artificial surfaces"
fire$LandUse[fire$LANDCOVER_N==2] <- "Agricultural areas"
fire$LandUse[fire$LANDCOVER_N==3] <- "Forest and semi-natural areas"
fire$LandUse[fire$LANDCOVER_N==4] <- "Wetlands"
fire$LandUse[fire$LANDCOVER_N==5] <- "Waterbodies"

#make LandUse a factor
fire$LandUse = as.factor(fire$LandUse)

#Create a region_list for the Tplot function
region_list = fire$REGIONS
regions_names = unique(region_list)
regions = sort(regions_names)

#Set directory for image output
dir.create(paste0(outdir,'/TSeries'))
imgdir <-paste0(outdir,"/TSeries")
setwd(imgdir)

#Function call
Tserie_plot(regions, fire)


### Visualizing results ###
#set directory for map
setwd(outdir)

#Create variable for popup formatting
file <-paste0(outdir,'/TSeries/')
#Link TSeries files with location
Italy$POPUP <- paste0(Italy$FILENAME,".png")

#Popup formatting
pop1 <- paste0("<style> div.leaflet-popup-content {width:auto !important;}</style>", 
               '<b>Region: </b>', Italy$NAME_1, 
               "<img src = ", file, Italy$POPUP, "/>")


#Call function to plot map
ItalyMap <- mapplot(Italy, n2k_sic_rp, fire, pop1)
saveWidget(ItalyMap, 'ItalyFireEvent_inN2K.html', selfcontained = FALSE)


#overall fire events image
fire_df <- as.data.frame(fire)
fire_df$date <- as.Date(fire_df$ACQ_DATE)
theme_set(theme_bw()) # Change the theme to my preference
theplot = ggplot(aes(x = date, y = FRP), data = fire_df) + 
  geom_point(aes(color = LandUse), size =  0.5) +
  scale_x_date() + xlab("Years") + ylab("Fire Radiative Power (MW)") +
  scale_color_manual(values = c("Artificial surfaces" = "lavenderblush4", "Agricultural areas" = "chartreuse3","Forest and semi-natural areas" = "green4", "Wetlands" = "seagreen3", "Waterbodies" = "blue3"))+
  facet_wrap(~REGIONS)+
  theme(strip.text.x = element_text(size = 6, colour = "black", angle = 0))
ggsave(filename = "Regions_overall.png", plot = last_plot(), device = NULL, scale = 1, width = 20 , height = 10, units = "cm", dpi =200, limitsize = TRUE)

