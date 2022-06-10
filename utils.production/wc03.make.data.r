#=======================================================================
# File: wc03.make.data.r
# Purpose:
#   Read in CFSR data in text format and perform Randomized PCA (RPCA). 
#=======================================================================
# Parameters
source("wc00.parameters.r")
#=======================================================================
# Functions
#=======================================================================
createIO <- function(infile, evfile){
  # Read in data
  din <- read.csv(infile, row.names=1)
  dout <- read.csv(evfile, stringsAsFactors=F)
  # Merge with date
  din$date <- substr(row.names(din),1,8)
  row.names(din) <- NULL
  dio <- merge(din, dout)
  # Move "date" to index
  row.names(dio) <- dio$date
  dio <- dio[,colnames(dio) != "date"]
  #
  return(dio)
}
#=======================================================================
# Script commands
#=======================================================================
dio <- createIO(infile=REDUCED_DATA, evfile=eventLog)
write.csv(dio, file=IODATA)
