#!/usr/bin/bash
#Never go to standby:
powercfg -change -standby-timeout-ac 0
#
DATASRC="/cygdrive/d/work/atmosphericscience_data/ncep-cfsr/singleLayer/"
TARGET=(h500 t700 rh700 t800 rh800 t925 rh925 mslp pwat u200 v200 u850 v850 u925 v925)
OUTDIR="/cygdrive/d/work/atmosphericscience_data/ncep-cfsr/singleLayerText/"
for j in `seq 1 15`
  do
    SUBDIR=${TARGET[$((j-1))]}
    echo $j $SUBDIR $OUTDIR/$SUBDIR
    for i in $DATASRC/$SUBDIR/*.grb2
    do
        fn="${i##*/}"
        d="${fn%.*}"
        #echo "$OUTDIR/$SUBDIR/$d.txt"
        wgrib2 $i -d 1 -text "$OUTDIR/$SUBDIR/$d.txt"
    done
  done
#
#Go to standby in 15 minutes:
powercfg -change -standby-timeout-ac 15
