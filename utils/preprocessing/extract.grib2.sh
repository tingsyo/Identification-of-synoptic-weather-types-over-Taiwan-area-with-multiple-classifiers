#!/bin/bash
# extract NCEP-CFSR data
#DATASRC="/cygdrive/d/work/atmosphericscience_data/ncep-cfsr/1979/"
DATASRC=$1
startyear=$2
endyear=$3
matchpat=$4
outdir=$5


for i in `seq $startyear $endyear`; do
    mkdir -p $outdir/$i
    srcdir=$DATASRC
    for f in $srcdir/$i/*0000.pgbhnl.*.grb2; do
        #echo $f
        fname=$(basename "$f")
        fname="${fname%.*}"
        fname=${fname:0:12}
        outfile=$outdir/$i"/$fname.grb2"
        #echo $fname
        #echo $outfile
        wgrib2 $f -match $matchpat -grib $outfile -v0
    done
done
