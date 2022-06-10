#!/bin/bash
# Convert single layer NCEP-CFSR data to txt
srcdir=$1
outdir=$2

for f in $1/*.grb2; do
    echo $f
    fname=$(basename "$f")
    fname="${fname%.*}"
    fname=${fname:0:12}
    outfile="$outdir/$fname.txt"
    #echo $fname
    echo $outfile
    wgrib2 $f -text $outfile -v0
done

