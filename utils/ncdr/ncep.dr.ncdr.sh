#!/bin/bash
toolpath=$1
datapath=$2
outpath=$3
#Never go to standby:
powercfg -change -standby-timeout-ac 0

#python3 $toolpath $datapath/h500 -n 20 -o $outpath/h500.svd20.csv
echo "MSLP"
python3 $toolpath $datapath/mslp -n 20 -o $outpath/mslp.svd20.csv
echo "PWAT"
python3 $toolpath $datapath/pwat -n 20 -o $outpath/pwat.svd20.csv
echo "RH700"
python3 $toolpath $datapath/rh700 -n 20 -o $outpath/rh700.svd20.csv
echo "RH800"
python3 $toolpath $datapath/rh800 -n 20 -o $outpath/rh800.svd20.csv
echo "RH925"
python3 $toolpath $datapath/rh925 -n 20 -o $outpath/rh925.svd20.csv
echo "T700"
python3 $toolpath $datapath/t700 -n 20 -o $outpath/t700.svd20.csv
echo "T800"
python3 $toolpath $datapath/t800 -n 20 -o $outpath/t800.svd20.csv
echo "T925"
python3 $toolpath $datapath/t925 -n 20 -o $outpath/t925.svd20.csv
echo "U200"
python3 $toolpath $datapath/u200 -n 20 -o $outpath/u200.svd20.csv
echo "U850"
python3 $toolpath $datapath/u850 -n 20 -o $outpath/u850.svd20.csv
echo "U925"
python3 $toolpath $datapath/u925 -n 20 -o $outpath/u925.svd20.csv
echo "V200"
python3 $toolpath $datapath/v200 -n 20 -o $outpath/v200.svd20.csv
echo "V850"
python3 $toolpath $datapath/v850 -n 20 -o $outpath/v850.svd20.csv
echo "V925"
python3 $toolpath $datapath/v925 -n 20 -o $outpath/v925.svd20.csv
#
#Go to standby in 15 minutes:
powercfg -change -standby-timeout-ac 15
