meanCalc <- function(x) {
  mean <- (sum(x[[1:12]])/12)
  return(mean)
}
  
reproject = function(x, y){
  xrp <- spTransform(x, CRS(proj4string(y)))
  return(xrp)
}
