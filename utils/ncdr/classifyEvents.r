#=======================================================================
# File: classifyEvents.r
# Purpose:
#   Read in input data, and predict output with pre-trained classifier.
#=======================================================================
vars <- c("h500","mslp","pwat","rh700","rh800","rh925","t700","t800","t925",
            "u200","u850","u925","v200","v850","v925")

read.csv.ncdr <- function(dpath, suffix=".csv", nsvd=20){
#=======================================================================
# function: read.csv.svd.r
# Purpose:
#   Read in SVDs of grid data in csv format (pre-processed with python). 
#   Variables: h500, mslp, pwat, rh700, rh800, rh925, t700, t800, t925,
#              u200, u850, u925, v200, v850, v925 (15 in total)
#=======================================================================
  output <- NULL
  #
  for(i in 1:length(vars)){
    fname <- paste(dpath, vars[i], suffix, sep="")
    print(fname)
    tmp <- read.csv(fname, header=F, colClasses="character", stringsAsFactors=F, fileEncoding="UTF-8-BOM")
    # Prepare names
    ncol.output <- nsvd
    if(nsvd > (ncol(tmp))){
      ncol.output <- ncol(tmp)
    }
    cnames <- paste(vars[i], "svd", 1:ncol.output, sep=".")
    # Clean up
    tmp <- tmp[,1:ncol.output]
    tmp <- sapply(tmp, as.numeric)
    tmp <- matrix(tmp, ncol=ncol.output)
    colnames(tmp) <- cnames
    #
    output <- cbind(output,tmp)
    #print(dim(tmp))
    #print(dim(output))
  }
  return(data.frame(output))
}

# Script
require(caret)
require(kernlab)
# Load pre-trained classifiers
load("ncdr.fits.RData")
# Read new data
newRec <- read.csv.ncdr("tmp.csv/",".svd20.csv")
# Predict output
results <- NULL
for(i in 1:nrow(newRec)){
  p1 <- as.numeric(predict(fits$front, newdata=newRec))-1
  p2 <- as.numeric(predict(fits$typhoon, newdata=newRec))-1
  p3 <- as.numeric(predict(fits$hr, newdata=newRec))-1
  results <- rbind(results,c("front"=p1,"typhoon"=p2,"hr"=p3))
}
rm(p1,p2,p3,i)
print(results)