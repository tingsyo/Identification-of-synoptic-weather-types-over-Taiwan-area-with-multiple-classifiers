#!/usr/bin/bash
#Never go to standby:
powercfg -change -standby-timeout-ac 0
#
DATASRC="/cygdrive/d/work/atmosphericscience_data/ncep-cfsr/cleaned/"
TARGET=(h500 t700 rh700 t800 rh800 t925 rh925 mslp)
OUTDIR="/cygdrive/d/work/atmosphericscience_data/ncep-cfsr/text"
for j in `seq 2 8`
  do
    SUBDIR=${TARGET[$((j-1))]}
    #echo $j $SUBDIR
    for i in $DATASRC/*/*.grb2
      do fn="${i##*/}"
        d="${fn%.*}"
        #echo "$OUTDIR/$SUBDIR/$d.txt"
        wgrib2 $i -d $j -text "$OUTDIR/$SUBDIR/$d.txt"
      done
  done
#
#Go to standby in 15 minutes:
powercfg -change -standby-timeout-ac 15
