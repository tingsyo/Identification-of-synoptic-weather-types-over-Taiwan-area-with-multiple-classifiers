#!/bin/bash
# extract NCEP-CFSR data
DATASRC=$1
startyear=$2
endyear=$3
matchpat=$4
outdir=$5

for i in `seq $startyear $endyear`; do
    mkdir -p $outdir/
    for f in `ls $DATASRC/$i*0000.pgbhnl.*.grb2`; do
        #echo $f
        fname=$(basename "$f")
        fname="${fname%.*}"
        fname=${fname:0:12}
        outfile=$outdir/"$fname.txt"
        #echo $fname
        #echo $outfile
        wgrib2 $f -match $matchpat -text $outfile -v0
    done
done
