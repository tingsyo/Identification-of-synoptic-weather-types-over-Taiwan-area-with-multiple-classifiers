#=======================================================================
# File: wc05.prediction.r
# Purpose:
#   Predict the event with . 
#=======================================================================
# Parameters
source("wc00.parameters.r")
NEWDIR <- "../workspace/new/"
NEW_REDUCED_DATA <- "new_input.csv"
#=======================================================================
# Functions
#=======================================================================
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

#
project.rpca <- function(datadir, vars, pcs, k=20, verbose=0){
  # 
  newdata <- NULL
  # Read in all text files
  for(i in 1:length(vars)){
    ddir <- paste(datadir, vars[i], sep="/")
    if(verbose>0){
      print(paste("Process diorectory",ddir))
    }
    mtx <- read.cfsr.dir(ddir, verbose=(verbose>1))
    # Project to PCs
    tmp <- predict(pcs[[vars[i]]], data.frame(mtx))
    colnames(tmp) <- paste0(vars[i], "_pc", 1:k)
    newdata <- cbind(newdata, tmp)
  }
  return(newdata)
}
#=======================================================================
# Script commands
#=======================================================================
require(rsvd)
require(caret)
require(e1071)
require(kernlab)
load(RPCA_DATA)
newinput <- project.rpca(NEWDIR, VARS, rpcs, k=K)
#write.csv(newdata, file=NEW_REDUCED_DATA)
load(MODEL_FILE)
pred.glm <- predict(results$model$glm, newdata=newinput)
pred.svm <- predict(results$model$svm, newdata=newinput)
print(paste("Prediction from GLM:", pred.glm, " and SVM:", pred.svm))


