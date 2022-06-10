#!/bin/bash
# extract NCEP-CFSR data
DATASRC=$1
startyear=$2
endyear=$3
outdir1=$DATASRC/"hgt500"
outdir2=$DATASRC/"tmp700"
outdir3=$DATASRC/"rh700"
outdir4=$DATASRC/"tmp800"
outdir5=$DATASRC/"rh800"
outdir6=$DATASRC/"tmp925"
outdir7=$DATASRC/"rh925"
outdir8=$DATASRC/"prmsl"


for i in `seq $startyear $endyear`; do
    srcdir=$DATASRC/$i
    for f in $srcdir/$i*.grb2; do
        fname=$(basename "$f")
        fname="${fname%.*}"
        fname=${fname:0:12}
        outfile1=$outdir1"/$fname.txt"
        outfile2=$outdir2"/$fname.txt"
        outfile3=$outdir3"/$fname.txt"
        outfile4=$outdir4"/$fname.txt"
        outfile5=$outdir5"/$fname.txt"
        outfile6=$outdir6"/$fname.txt"
        outfile7=$outdir7"/$fname.txt"
        outfile8=$outdir8"/$fname.txt"
        wgrib2 $f -d 1 -text $outfile1
        wgrib2 $f -d 2 -text $outfile2
        wgrib2 $f -d 3 -text $outfile3
        wgrib2 $f -d 4 -text $outfile4
        wgrib2 $f -d 5 -text $outfile5
        wgrib2 $f -d 6 -text $outfile6
        wgrib2 $f -d 7 -text $outfile7
        wgrib2 $f -d 8 -text $outfile8
    done
done
