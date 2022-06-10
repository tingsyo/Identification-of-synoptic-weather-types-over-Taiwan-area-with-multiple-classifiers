# !/usr/bin/python3
#
# File: ec20c_svd.py
# Purpose: preprocess ECMWF-20C data at 00Z
#
import sys, os, re, csv, argparse
import numpy as np
#import pygrib
from sklearn.decomposition import RandomizedPCA
from struct import *

def readECGrib(dpath):
    ''' Extract ECMWF data in GRIB format '''
    #
    index = []
    recs = []
    # Walk through all grb files
    for root, dirs, files in os.walk(dpath):
        for file in files:
            if (file.endswith(".grb") and (not file.startswith("~"))):
                full_fname = os.path.join(root, file)
                grb = readGrib(full_fname)
                index.append(grb['date'])
                recs.append(grb['values'])
    # done
    return({"date":index, "records":recs})

def readGrib(furi):
    # Read GRIB2 file with pygrib
    with pygrib.open(furi) as f:
        raw = f.select()[0]             # Retrieve specified record
        dataDate = raw.dataDate         # Print for testing
        values = list(raw.values.flat)  # Flattern the array into 1D
    # Done
    return({'date':dataDate, 'values':values})

def readNcepText(dpath):
    ''' Extract NCEP-CFSR data in text format '''
    #
    recs = []
    index = []
    # Walk through all grb2 files
    for root, dirs, files in os.walk(dpath):
        for file in files:
            if (file.endswith("00.txt") and (not file.startswith("~"))):
                furi = os.path.join(root, file)
                index.append(file.replace('00.txt',''))
                # Read text file
                #print(file.replace('0000.txt',''))
                with open(furi, "r") as f:
                    row = f.readlines()
                # Convert to float
                del row[0]
                #frow = [float(x) for x in row]
                npa = np.array(row)
                npa[npa=='NA\n'] = np.NaN
                frow = npa.astype(np.float)
                recs.append(frow)
    # done
    return({"date":index, "records":recs})

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
    #recs = readECGrib(args.datapath)
    recs = readNcepText(args.datapath)
    print(len(recs['records']))
    # Perform Randomized SVD if specified
    if (args.ncomponent!='0'):
        pca = RandomizedPCA(n_components=int(args.ncomponent), whiten=True, random_state=int(args.randomseed))
        projections = pca.fit_transform(np.array(recs['records']))
        # Output PCA components
        print('Performing RandomizedSVD, the explained variance ratio:')
        print(pca.explained_variance_ratio_)
        evr = pca.explained_variance_ratio_
        com = pca.components_
        writeToCsv(com, args.output.replace('.csv','.components.csv'))
        writeToCsv(evr.reshape(len(evr),1), args.output.replace('.csv','.explained_variance.csv'))
    else:
        projections = recs['records']
    # Append date and projections
    newrecs = []
    for i in range(len(recs['date'])):
        newrecs.append([recs['date'][i]] + list(projections[i]))
    # Output
    writeToCsv(newrecs, args.output)
    return(0)

#==========
# Script
#==========
if __name__=="__main__":
    main()
