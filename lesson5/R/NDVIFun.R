#Function to download the images
down_data = function(x, name){
  filename = paste(name, '.tar.gz', sep = '')
  (download.file(url=x, destfile = filename, method = 'auto'))
  untar(filename)
}

#Function to create a raster stack
list_data = function(image){
  list = list.files(pattern = glob2rx(image))
  liststack = stack(list)
  return(liststack)
}

#Function to calculate the NDVI
ndvi = function(red, NIR){
  ndvi = (NIR - red) / (NIR + red)
  return(ndvi)
}

#Function to mask out clouds
maskCloudsNA = function(image){
  cmask = image[[1]]
  imagedrop = dropLayer(image, 1)
  imagedrop[cmask != 0] = NA
  
  return(imagedrop)
}

#Function to adjust raster extents and detect change
change = function(x,y){
  x2 = intersect (x,y)
  y2 = intersect (y,x)
  changeNDVI = y2 - x2
  return(changeNDVI)
}