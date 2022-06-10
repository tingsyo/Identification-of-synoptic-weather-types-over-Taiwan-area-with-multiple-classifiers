# R function to calculate Td (Dew point temperature) using formula in
# Buck, A. L. 1981
calculateTd <- function(TK, RH){
  # Check RH
  if(RH < 1){
    print("The RH is less than 1%, returns NA.")
    return(NA)
  }
  # Convert Kelvin to Celsius 
  K0 = 273.15
  Tc = TK - K0
  # Basic parameters
  d = 234.5
  a = 6.1121
  # Conditional parameters
  if(Tc>=0. & Tc<=50.){
    b = 17.368
    c = 238.88
  } else if(Tc>=-40.){
    b = 17.966
    c = 247.15
  } else {
    print("The temperature is not in range of (-40, 50) degree C, returns NA.")
    return(NA)
  }
  # Calculation
  g = log(RH/100 * exp((b - Tc/d)*(Tc/(c+Tc))))
  Td = c*g / (b-g) + K0
  return(Td)
}

# R function to calculate Td (Dew point temperature) using formula in
# Buck, A. L. 1981
calculateTd.v2 <- function(TK, RH){
  # Check RH
  if(RH < 1){
    print("The RH is less than 1%, set to 1%.")
    RH = 1
  }
  # Convert Kelvin to Celsius 
  K0 = 273.15
  Tc = TK - K0
  # Basic parameters
  d = 234.5
  a = 6.1121
  # Conditional parameters
  if(Tc>=0.){
    b = 17.368
    c = 238.88
  } else {
    b = 17.966
    c = 247.15
  }
  # Calculation
  g = log(RH/100 * exp((b - Tc/d)*(Tc/(c+Tc))))
  Td = c*g / (b-g) + K0
  return(Td)
}



# Batch process Td
createTdLayers <- function(srcdir){
  subdir <- matrix(c("rh700/", "t700/", "td700v2/",
                     "rh850/", "t850/", "td850v2/",
                     "rh925/", "t925/", "td925v2/"), ncol=3, byrow=T)
  #
  for(i in 1:nrow(subdir)){
    print(subdir[i,])
    #
    rhdir <- paste(srcdir, subdir[i,1],sep="/")
    tdir <- paste(srcdir, subdir[i,2],sep="/")
    tddir <- paste(srcdir, subdir[i,3],sep="/")
    if(!dir.exists(tddir)){
      dir.create(tddir)
    }
    #
    flist <- list.files(rhdir)
    for(f in flist){
      print(f)
      # Read RH and Temperature
      rhdata <- readLines(paste0(rhdir,f))
      tdata <- readLines(paste0(tdir,f))
      # Calculate Td
      tddata <- tdata
      for(j in 2:length(tddata)){
        tddata[j] <- calculateTd.v2(as.numeric(tdata[j]), as.numeric(rhdata[j]))
      }
      # Write Td
      writeLines(tddata, paste0(tddir,f))
    }
  }
  # Done
  return(0)
}
