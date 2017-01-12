#!/bin/bash
echo "TheScriptingLadies Nadine Drigo and Amy Gex"
echo "12 January 2017"
echo "Calculate LandSat NDVI, resample pixel size to 60m, reproject to WGS84"

fn=$(ls *U.tif)
echo "The input file: $fn"
ndvifn="30ndvi.tif"
echo "The output file: $ndvifn"
echo "calculate ndvi"
gdal_calc.py -A $fn --A_band=4 -B $fn --B_band=3 --outfile=$ndvifn --calc="(A.astype(float)-B)/(A.astype(float)+B)" --type='Float32'

echo "look at some histogram statistics of $ndvifn"
gdalinfo -hist -stats $ndvifn


int60fn=¨60m$fn¨
gdalwarp -tr 60 60 $ndvifn $int60fn

echo "look at some histogram statistics of $int60fn"
gdalinfo -hist -stats $int60fn


prjoutfn=¨prj$int60fn¨
gdalwarp -t_srs EPSG:4326 $int60fn $prjoutfn

echo "look at some histogram statistics of $prjoutfn"
gdalinfo -hist -stats $prjoutfn