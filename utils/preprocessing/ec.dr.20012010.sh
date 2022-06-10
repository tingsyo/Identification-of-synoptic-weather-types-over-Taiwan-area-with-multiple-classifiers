#!/bin/bash
toolpath="./utils/preprocessing/"
datapath="./data/ec.singleLayer/"
outpath="./data/ec.svd50/"

#python3 $toolpath/rpca_ec.py $datapath/mslp -n 50 -o $outpath/mslp.svd50.csv
#python3 $toolpath/rpca_ec.py $datapath/tcrw -n 50 -o $outpath/pwat.svd50.csv
#python3 $toolpath/rpca_ec.py $datapath/u925 -n 50 -o $outpath/u925.svd50.csv
#python3 $toolpath/rpca_ec.py $datapath/v925 -n 50 -o $outpath/v925.svd50.csv
#python3 $toolpath/rpca_ec.py $datapath/RH925 -n 50 -o $outpath/rh925.svd50.csv
#python3 $toolpath/rpca_ec.py $datapath/T925 -n 50 -o $outpath/t925.svd50.csv
#python3 $toolpath/rpca_ec.py $datapath/u850 -n 50 -o $outpath/u850.svd50.csv
#python3 $toolpath/rpca_ec.py $datapath/v850 -n 50 -o $outpath/v850.svd50.csv
python3 $toolpath/rpca_ec.py $datapath/RH850 -n 50 -o $outpath/rh850.svd50.csv
python3 $toolpath/rpca_ec.py $datapath/T850 -n 50 -o $outpath/t850.svd50.csv
python3 $toolpath/rpca_ec.py $datapath/u700 -n 50 -o $outpath/u700.svd50.csv
python3 $toolpath/rpca_ec.py $datapath/v700 -n 50 -o $outpath/v700.svd50.csv
#python3 $toolpath/rpca_ec.py $datapath/RH700 -n 50 -o $outpath/rh700.svd50.csv
#python3 $toolpath/rpca_ec.py $datapath/T700 -n 50 -o $outpath/t700.svd50.csv
#python3 $toolpath/rpca_ec.py $datapath/H500 -n 50 -o $outpath/h500.svd50.csv
#python3 $toolpath/rpca_ec.py $datapath/u200 -n 50 -o $outpath/u200.svd50.csv
#python3 $toolpath/rpca_ec.py $datapath/v200 -n 50 -o $outpath/v200.svd50.csv
python3 $toolpath/rpca_ec.py $datapath/T200 -n 50 -o $outpath/T200.svd50.csv

