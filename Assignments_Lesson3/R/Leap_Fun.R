
#Function that determines if a year is a leap year

is.leap = function(x) {
  
  if (is.numeric(x)) {
    
    if (x > 1581){
      
      if (x %% 4 != 0) {
        ans = FALSE
        
      }else if (x %% 100 != 0) {
        ans = TRUE
        
      }else if (x %% 400 != 0) {
        ans = FALSE
        
      }else (ans = TRUE) 
      
    }else (ans = paste0(x, " is out of the valid range"))
    
  }else (ans = warning("Error: argument of class numeric expected"))
  
  return(ans)
}




