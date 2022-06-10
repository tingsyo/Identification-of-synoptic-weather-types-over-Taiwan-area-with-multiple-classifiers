#!/bin/bash
toolpath="./utils/preprocessing/"
datapath="./data/ncep.singleLayer/"
outpath="./data/ncep.svd50.2001/"

#python3 $toolpath/rpca_ncep_2001a.py $datapath/mslp -n 50 -o $outpath/mslp.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/pwat -n 50 -o $outpath/pwat.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/rh700 -n 50 -o $outpath/rh700.svd50.csv
python3 $toolpath/rpca_ncep_2001a.py $datapath/rh850 -n 50 -o $outpath/rh850.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/rh925 -n 50 -o $outpath/rh925.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/t700 -n 50 -o $outpath/t700.svd50.csv
python3 $toolpath/rpca_ncep_2001a.py $datapath/t850 -n 50 -o $outpath/t850.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/t925 -n 50 -o $outpath/t925.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/h500 -n 50 -o $outpath/h500.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/u200 -n 50 -o $outpath/u200.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/u700 -n 50 -o $outpath/u700.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/u850 -n 50 -o $outpath/u850.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/u925 -n 50 -o $outpath/u925.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/v200 -n 50 -o $outpath/v200.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/v700 -n 50 -o $outpath/v700.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/v850 -n 50 -o $outpath/v850.svd50.csv
#python3 $toolpath/rpca_ncep_2001a.py $datapath/v925 -n 50 -o $outpath/v925.svd50.csv
