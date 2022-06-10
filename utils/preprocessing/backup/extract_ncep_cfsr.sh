#!/bin/bash
# extract NCEP-CFSR data
export DATASRC="/cygdrive/d/work/atmosphericscience_data/ncep-cfsr/pgb/"
startyear=$1
endyear=$2
outdir=$3


for i in `seq $startyear $endyear`; do
    mkdir -p $outdir/$i
    srcdir=$DATASRC
    for f in $srcdir/$i*.grb2; do
        fname=$(basename "$f")
        fname="${fname%.*}"
        fname=${fname:0:12}
        outfile=$outdir/$i"/$fname.grb2"
        wgrib2 $f -match '^(85|102|103|114|115|134|135|149):' -grib $outfile
    done
done
