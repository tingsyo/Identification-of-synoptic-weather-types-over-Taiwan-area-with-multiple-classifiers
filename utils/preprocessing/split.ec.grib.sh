#!/bin/bash
#Never go to standby:
powercfg -change -standby-timeout-ac 0
# extract ECMWF data
DATASRC=$1
outdir=$2
# Run through
for f in $DATASRC/*.grib; do
    #echo $f
    nrec=`wgrib $f | wc -l`
    #echo $nrec
    fname=$(basename "$f")
    fname="${fname%.*}"
    fname=`echo $fname | cut -f2 -d_`
    echo $fname
    mkdir $outdir/$fname
    for i in `seq 1 $nrec`; do
        dataDate=`wgrib $f -4yr -d $i| cut -f3 -d:`
        dataDate=${dataDate:2}
        hr=${dataDate: -2}
        if [ "$hr" == "00" ]; then
            outfile=$outdir/$fname/$fname.$dataDate".grb"
            echo $outfile
            wgrib $f -d $i -grib -o $outfile
        fi
    done
done
#Go to standby in 15 minutes:
powercfg -change -standby-timeout-ac 15
