#!/bin/bash
# extract NCEP-CFSR data into text format
#=======================================================================
# Parameters
LIBPATH="./"
DATASRC="../cfsr"
OUTPUT="./workspace"
#=======================================================================
# Extract 500hPa Geopotential Height
bash $LIBPATH/extract.grib2.sh $DATASRC 2008 2008 "HGT:500" $OUTPUT/h500/
bash $LIBPATH/extract.grib2.sh $DATASRC 2008 2008 "PRMSL:mean" $OUTPUT/mslp/
bash $LIBPATH/extract.grib2.sh $DATASRC 2008 2008 "TMP:850" $OUTPUT/t850/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "HGT:500" $OUTPUT/h500/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "PRMSL:mean" $OUTPUT/mslp/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "UGRD:200" $OUTPUT/u200/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "VGRD:200" $OUTPUT/v200/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "TMP:200" $OUTPUT/t200/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "TMP:700" $OUTPUT/t700/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "RH:700" $OUTPUT/rh700/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "UGRD:700" $OUTPUT/u700/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "VGRD:700" $OUTPUT/v700/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "TMP:850" $OUTPUT/t850/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "RH:850" $OUTPUT/rh850/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "UGRD:850" $OUTPUT/u850/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "VGRD:850" $OUTPUT/v850/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "TMP:925" $OUTPUT/t925/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "RH:925" $OUTPUT/rh925/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "UGRD:925" $OUTPUT/u925/
#bash $LIBPATH/extract.grib2.sh $DATASRC 1979 2010 "VGRD:925" $OUTPUT/v925/
