# !/usr/bin/python3
#
# File: ncep_svd.py
# Purpose: preprocess NCEP-CFSR data at 00Z
#
import sys, os, re, csv, argparse
import numpy as np
import pickle
from sklearn.decomposition import RandomizedPCA
from struct import *
    
def readNcepText(dpath):
    ''' Extract NCEP-CFSR data in text format '''
    #
    recs = []
    index = []
    # Walk through all text files
    for root, dirs, files in os.walk(dpath):
        for file in files:
            if (file.endswith(".txt") and (not file.startswith("~"))):
                furi = os.path.join(root, file)
                index.append(file.replace('.txt',''))
                # Read text file
                #print(file.replace('.txt',''))
                with open(furi, "r") as f:
                    row = f.readlines()
                # Convert to float
                del row[0]
                frow = [float(x) for x in row]
                recs.append(frow)
    # done
    return({"date":index, "records":recs})

def readGrib2(furi):
    # Read GRIB2 file with pygrib
    with pygrib.open(furi) as f:
        raw = f.select()[0]             # Retrieve specified record
        dataDate = raw.dataDate         # Print for testing
        values = list(raw.values.flat)  # Flattern the array into 1D
    # Done
    return({'date':dataDate, 'values':values})

def readGribText(furi):
    ''' Extract grib data in text format '''
    #
    recs = []
    # Read text file
    with open(furi, encoding='utf-8-sig') as f:
        row = f.readlines()
    # Convert to float
    del row[0]
    recs = [float(x) for x in row]
    #
    print(str(len(recs))+" records read.")
    # done
    return({"records":recs})

def writeToCsv(output, fname):
    # Overwrite the output file:
    with open(fname, 'w', newline='', encoding='utf-8-sig') as csvfile:
        writer = csv.writer(csvfile, delimiter=',',quotechar='"', quoting=csv.QUOTE_ALL)
        for r in output:
            writer.writerow(r)
    return(0)

def writeToPickel(obj, fname):
    # Overwrite the output file:
    with open(fname, 'wb') as f:
        pickle.dump(obj, f)
    return(0)


def main():
    # Configure Argument Parser
    parser = argparse.ArgumentParser(description='Read in ECMWF-20C data in grib format.')
    parser.add_argument("datapath", help="the plain text file of ECMWF grib output")
    parser.add_argument("-n", "--ncomponent", help="Maximum number of components to keep", type=int, default=0)
    parser.add_argument("-r", "--randomseed", help="integer as the random seed", type=int, default=12321)
    parser.add_argument("-o", "--output", help="the prefix of output files", default="output.csv")
    args = parser.parse_args()
    # Read data
    #recs = readNcepGrib(args.datapath)
    recs = readNcepText(args.datapath)
    # Perform Randomized SVD if specified
    if (args.ncomponent!=0):
        pca = RandomizedPCA(n_components=args.ncomponent, whiten=True, random_state=args.randomseed)
        projections = pca.fit_transform(np.array(recs['records']))
        # Output PCA components
        #print('Performing RandomizedSVD, the explained variance ratio:')
        #print(pca.explained_variance_ratio_)
        evr = pca.explained_variance_ratio_
        com = pca.components_
        output = []
        for i in range(len(evr)):
            output.append([evr[i]]+com[i])
        writeToPickel(pca, args.output.replace('.csv','.pickle'))
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
