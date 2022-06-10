#!/usr/bin/bash
for i in `seq 1 7304`; do wgrib ec20c_RH700_2001_2010.grib -d $i -text -o rh700/$i.txt; done
for i in `seq 1 7304`; do wgrib ec20c_RH800_2001_2010.grib -d $i -text -o rh800/$i.txt; done
for i in `seq 1 7304`; do wgrib ec20c_RH925_2001_2010.grib -d $i -text -o rh925/$i.txt; done
for i in `seq 1 7304`; do wgrib ec20c_T700_2001_2010.grib -d $i -text -o t700/$i.txt; done
for i in `seq 1 7304`; do wgrib ec20c_T800_2001_2010.grib -d $i -text -o t800/$i.txt; done
for i in `seq 1 7304`; do wgrib ec20c_T925_2001_2010.grib -d $i -text -o t925/$i.txt; done
