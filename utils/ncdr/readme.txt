#-----------------------------------------------------------------------
# Readme for integrate the weather classification process
#-----------------------------------------------------------------------
# file: readme.txt
# author: Ting-Shuo Yo
# last updated: 2016.05.25
#-----------------------------------------------------------------------
# 0. Prerequisites
# (0) Libraries: blast-devel, lapack-devel,....etc.
# (1) wgrib tools (wgrib, wgrib2)
# (2) python3 with packages: numpy, scipy, and sklearn
# (3) R 3.2 with packages: caret, gbm, and kernlab
#-----------------------------------------------------------------------
# 1. Training phase
# (1) NCEP data 1979 ~ 2010
# (2) Perform randomized PCA, keep PCs and Projections
# (3) Train SVM model with projections, and evaluate performance
# > This part is done before operation
#-----------------------------------------------------------------------
# 2. Operation phase
# (1) Extract desired data layers and range from model output
# (2) Project extracted data on PCs
# (3) Predict with new projections and the trained SVM model
# > Done by execute the script "run.sh -i <input_grib2_data_file> -w <workspace>"
#-----------------------------------------------------------------------
