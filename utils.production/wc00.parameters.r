#=======================================================================
# File: wc00.parameters.r
# Purpose:
#   A common parameter file
#=======================================================================
# Parameters
DATADIR <- "./workspace/"           # working folder containing the extracted text for training
VARS <- c("h500","mslp","t850")     # layers extracted
K <- 3                              # dimension for each layer after RPCA
REDUCED_DATA <- "rpca_output.csv"   # data after dimension reduction
RPCA_DATA <- "rpcs.RData"           # trained rPCA model
eventLog <- "./front_2008.csv"      # Event log as output data
IODATA <- "iodata.csv"              # Tidy data including Input/Output
METRIC_FILE <- "results.csv"        # File to export evaluation metrics
MODEL_FILE <- "results.RData"       # File to store trained model
verbose <- 1
rseed <- 123454321
