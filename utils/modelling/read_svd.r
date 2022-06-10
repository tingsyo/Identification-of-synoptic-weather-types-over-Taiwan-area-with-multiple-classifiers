#=======================================================================
# File: read_svd.r
# Purpose:
#   Read in SVDs of grid data in csv format (pre-processed with python). 
#   Variables: h500, mslp, pwat, rh700, rh800, rh925, t700, t800, t925,
#              u200, u850, u925, v200, v850, v925 (15 in total)
#=======================================================================
vars <- c("mslp","pwat"
            ,"u925","v925","rh925","t925"
            ,"u850","v850","rh850","t850"
            ,"u700","v700","rh700","t700"
            ,"h500"
            ,"u200","v200","t200"
            )

read.csv.svd <- function(dpath, suffix=".csv", nsvd=50){
  output <- NULL
  #
  for(i in 1:length(vars)){
    fname <- paste(dpath, vars[i], suffix, sep="")
    print(fname)
    tmp <- read.csv(fname, header=F, colClasses="character", stringsAsFactors=F, fileEncoding="UTF-8-BOM")
    # Prepare names
    rnames <- tmp[,1]
    ncol.output <- nsvd
    if(nsvd > (ncol(tmp)-1)){
      ncol.output <- ncol(tmp)-1
    }
    cnames <- paste(vars[i], "svd", 1:ncol.output, sep=".")
    # Clean up
    tmp <- tmp[,-1]
    tmp <- tmp[,1:ncol.output]
    tmp <- sapply(tmp, as.numeric)
    rownames(tmp) <- rnames
    colnames(tmp) <- cnames
    #
    output <- cbind(output,tmp)
    #print(dim(tmp))
    #print(dim(output))
  }
  return(data.frame(output))
}

