#!/bin/bash
# Convert single layer EC data to txt
srcdir=$1
outdir=$2

for f in $1/*.grb; do
    echo $f
    fname=$(basename "$f")
    fname="${fname%.*}"
    fname=${fname:0:12}
    outfile="$outdir/$fname.txt"
    #echo $fname
    echo $outfile
    wgrib -s $f -d 1 -text -o $outfile
done

