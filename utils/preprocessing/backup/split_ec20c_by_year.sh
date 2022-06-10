#!/bin/bash
# Split the 110 year record into one record per year
startyear=$2
endyear=$3
infile=$1

for i in `seq $startyear $endyear`; do
    wgrib $infile -s -4yr | grep "d=$i" | wgrib -i -o $i.grb -grib $infile 
done
