#!/usr/bin/bash
DATASRC="/cygdrive/d/work/atmosphericscience_data/ncep-cfsr/byYear"
OUTPUT="/cygdrive/d/work/atmosphericscience_data/ncep-cfsr/singleLayer"
#Never go to standby:
powercfg -change -standby-timeout-ac 0
#
#bash extract.grib2.sh $DATASRC 1979 2010 "HGT:500" $OUTPUT/h500/  > log.h500.log
#bash extract.grib2.sh $DATASRC 1979 2010 "PRMSL:mean" $OUTPUT/mslp/ > log.mslp.log 
#bash extract.grib2.sh $DATASRC 1979 2010 "UGRD:200" $OUTPUT/u200/ > log.u200.log 
#bash extract.grib2.sh $DATASRC 1979 2010 "VGRD:200" $OUTPUT/v200/ > log.v200.log
bash extract.grib2.sh $DATASRC 1979 2010 "TMP:200" $OUTPUT/t200/  > log.t200.log 
#bash extract.grib2.sh $DATASRC 1979 2010 "TMP:700" $OUTPUT/t700/  > log.t700.log 
#bash extract.grib2.sh $DATASRC 1979 2010 "RH:700" $OUTPUT/rh700/  > log.rh700.log 
bash extract.grib2.sh $DATASRC 1979 2010 "UGRD:700" $OUTPUT/u700/ > log.u700.log 
bash extract.grib2.sh $DATASRC 1979 2010 "VGRD:700" $OUTPUT/v700/ > log.v700.log 
bash extract.grib2.sh $DATASRC 1979 2010 "TMP:850" $OUTPUT/t850/  > log.t850.log 
bash extract.grib2.sh $DATASRC 1979 2010 "RH:850" $OUTPUT/rh850/  > log.rh850.log 
#bash extract.grib2.sh $DATASRC 1979 2010 "UGRD:850" $OUTPUT/u850/ > log.u850.log &
#bash extract.grib2.sh $DATASRC 1979 2010 "VGRD:850" $OUTPUT/v850/ > log.v850.log 
#bash extract.grib2.sh $DATASRC 1979 2010 "TMP:925" $OUTPUT/t925/  > log.t925.log
#bash extract.grib2.sh $DATASRC 1979 2010 "RH:925" $OUTPUT/rh925/  > log.rh925.log 
#bash extract.grib2.sh $DATASRC 1979 2010 "UGRD:925" $OUTPUT/u925/ > log.u925.log 
#bash extract.grib2.sh $DATASRC 1979 2010 "VGRD:925" $OUTPUT/v925/ > log.v925.log 
#
#Go to standby in 15 minutes:
powercfg -change -standby-timeout-ac 15
