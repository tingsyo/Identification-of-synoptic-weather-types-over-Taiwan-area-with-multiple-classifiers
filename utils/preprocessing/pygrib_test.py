# !/usr/bin/python3
#
# Test pygrib
#-----------------------------------------------------------------------
# Required GRIB data format:
# - All grib data are in the same format, which means they have the same 
#   number of records, and the same index indicates the same type of var.
# - 
#-----------------------------------------------------------------------
import sys, os, re, csv, argparse
import numpy as np
import pygrib
from sklearn.decomposition import RandomizedPCA

def readNcepGrib(dpath, index):
    ''' Extract NCEP-CFSR data in GRIB2 format '''
    #
    recs = []
    # Walk through all grb2 files
    for root, dirs, files in os.walk(dpath):
        for file in files:
            if (file.endswith(".grb2") and (not file.startswith("~"))):
                full_fname = os.path.join(root, file)
                recs.append(readGrib2(full_fname, int(index)-1))
    # done
    return(recs)
    
def readGrib2(furi, index):
    # Read GRIB2 file with pygrib
    with pygrib.open(furi) as f:
        raw = f.select()[index]     # Retrieve specified record
        print(raw.dataDate)         # Print for testing
        row = list(raw.values.flat) # Flattern the array into 1D
    # Done
    return(row)

def writeToCsv(output, fname):
    # Overwrite the output file:
    with open(fname, 'w', newline='', encoding='utf-8-sig') as csvfile:
        writer = csv.writer(csvfile, delimiter=',',quotechar='"', quoting=csv.QUOTE_ALL)
        for r in output:
            writer.writerow(r)
    return(0)

def main():
    # Configure Argument Parser
    parser = argparse.ArgumentParser(description='Read in ECMWF-20C data in grib format.')
    parser.add_argument("datapath", help="the plain text file of ECMWF grib output")
    parser.add_argument("-d", "--datalayer", help="The index of data layer", default="1")
    parser.add_argument("-n", "--ncomponent", help="Maximum number of components to keep", default="0")
    parser.add_argument("-r", "--randomseed", help="integer as the random seed", default="12321")
    parser.add_argument("-o", "--output", help="the prefix of output files", default="output.csv")
    args = parser.parse_args()
    # Read data
    recs = readNcepGrib(args.datapath, args.datalayer)
    # Perform Randomized SVD if specified
    if (args.ncomponent!="0"):
        pca = RandomizedPCA(n_components=int(args.ncomponent), whiten=True, random_state=int(args.randomseed))
        newrecs = pca.fit_transform(np.array(recs))
        print('Performing RandomizedSVD, the explained variance ratio:')
        print(pca.explained_variance_ratio_)
        writeToCsv(newrecs, args.output)
    else:
        newrecs = recs
    # Output
    writeToCsv(newrecs, args.output)
    # done
    return(0)

#==========
# Script
#==========
if __name__=="__main__":
    main()
