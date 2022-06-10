#!/usr/bin/bash
# Define data location
DATASRC="/cygdrive/d/work/atmosphericscience_data/ncep-cfsr/byYear"
OUTPUT="/cygdrive/d/work/atmosphericscience_data/ncep-cfsr/singleLayer"
# Extract data
bash dp01.extract.grib2sh $DATASRC 1979 2010 "HGT:500" $OUTPUT/h500/
