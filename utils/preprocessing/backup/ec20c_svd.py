#!/usr/bin/python3
#
# File: ec20c_svd.py
# Purpose: preprocess ECMWF-20C data at 00Z
#
from subprocess import call
import sys, os, re, csv, argparse
import numpy as np
from sklearn.decomposition import RandomizedPCA

def readECtext(dpath):
    ''' Parse EC text data files into data rows '''
    #
    recs = []
    # File name: [serial].txt, an odd serial is for 00Z
    for i in range(1, 7304, 2):
        fname = dpath + '/' + str(i) + '.txt'    
        # Read file
        with open(fname, "r") as f:
            row = f.readlines()
        # Replace dimension with the index
        row[0] = i
        # Convert to float
        try:
            newrow = [float(x) for x in row]
        except ValueError(e):
            print(e)
        # Done
        recs.append(newrow)
    # done
    return(recs)

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
    parser.add_argument("-n", "--ncomponent", help="Maximum number of components to keep", default="0")
    parser.add_argument("-r", "--randomseed", help="integer as the random seed", default="12321")
    parser.add_argument("-o", "--output", help="the prefix of output files", default="output.csv")
    args = parser.parse_args()
    # Read data
    recs = readECtext(args.datapath)
    # Perform Randomized SVD if specified
    if (args.ncomponent!="0"):
        pca = RandomizedPCA(n_components=int(args.ncomponent), whiten=True, random_state=int(args.randomseed))
        newrecs = pca.fit_transform(np.array(recs))
        print('Performing RandomizedSVD, the explained variance ratio:')
        print(pca.explained_variance_ratio_)
        writeToCsv(newrecs, args.output)
    else:
        writeToCsv(recs, args.output)
    # done
    return(0)

#==========
# Script
#==========
if __name__=="__main__":
    main()
