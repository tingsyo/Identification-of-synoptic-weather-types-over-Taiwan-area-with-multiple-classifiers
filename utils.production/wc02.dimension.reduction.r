#=======================================================================
# File: wc02.dimension.reduction.r
# Purpose:
#   Read in CFSR data in text format and perform dimension reduction
#   with Randomized PCA (RPCA). 
#=======================================================================
# Parameters
source("wc00.parameters.r")
#=======================================================================
# Functions
#=======================================================================
options(warn=-1)
require(rsvd)
# Read CFSR data in text format
read.cfsr.txt <- function(fname){
  # Open and read file
  f <- file(fname,"r")
  tmp <- readLines(f)
  close(f)
  # Parse file
  dims <- as.numeric(strsplit(tmp[1]," ")[[1]])
  values <- as.numeric(tmp[2:(dims[1]*dims[2]+1)])
  return(values)
}

# Read all CFSR data in text format in specified directory
read.cfsr.dir <- function(ddir, verbose=F){
  # All files in the specified directory
  flist <- list.files(path=ddir, pattern="*.txt")
  # File name as date-time
  dates <- sapply(strsplit(flist,".",fixed = T), function(x){unlist(x[1])})
  # Read all files
  output <- NULL
  for( i in 1:length(flist)){
    fname <- paste(ddir, flist[i], sep="/")
    if(verbose){
      print(paste("Reading CFSR data from:",fname))
    }
    output <- rbind(output, read.cfsr.txt(fname))
  }
  row.names(output) <- dates
  #
  return(output)
}

# Perform randomized PCA
make.rpca <- function(datadir, vars, k=20, rseed=54321, verbose=0){
  # 
  rpcs <- NULL
  newdata <- NULL
  #
  for(i in 1:length(vars)){
    ddir <- paste(datadir, vars[i], sep="/")
    if(verbose>0){
      print(paste("Process diorectory",ddir))
    }
    mtx <- read.cfsr.dir(ddir, verbose=(verbose>1))
    #
    set.seed(rseed)
    mtx.rpca <- rpca(mtx, k=k)
    #
    rpcs <- c(rpcs, list(mtx.rpca))
    tmp <- predict(mtx.rpca, data.frame(mtx))
    colnames(tmp) <- paste0(vars[i], "_pc", 1:k)
    newdata <- cbind(newdata, tmp)
  }
  names(rpcs) <- vars
  return(list("pcs"=rpcs, "data"=newdata))
}

#=======================================================================
# Script commands
#=======================================================================
tmp <- make.rpca(DATADIR, vars=VARS, k=K, verbose=verbose)
write.csv(tmp$data, file=REDUCED_DATA)
rpcs <- tmp$pcs
save(rpcs, file=RPCA_DATA)
options(warn=0)
