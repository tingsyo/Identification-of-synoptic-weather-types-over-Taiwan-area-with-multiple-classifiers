# !/usr/bin/python3
#
# File: getProjection.py
# Purpose: Compute the projection of data on PCs
#
import sys, os, re, csv, argparse
import numpy as np
import pickle
from sklearn.decomposition import RandomizedPCA
 
def readPCs(furi):
    ''' Read PCs '''
    # Read PCA object from pickle binary
    with open(furi, 'rb') as f:
        pca = pickle.load(f)
    # Done
    return(pca)
    
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
    return(recs)

def calProjection(row, pca):
    newdata = np.array(row).reshape((1,len(row)))
    proj = pca.transform(newdata)
    return(proj)


def writeToCsv(output, fname):
    # Overwrite the output file:
    with open(fname, 'w', newline='', encoding='utf-8-sig') as csvfile:
        writer = csv.writer(csvfile, delimiter=',',quotechar='"', quoting=csv.QUOTE_ALL)
        for r in output:
            writer.writerow(r)
    return(0)

def main():
    # Configure Argument Parser
    parser = argparse.ArgumentParser(description='Convert Principle Components from GRIB order to TEXT order (Y:60:0 -> Y:0:60)')
    parser.add_argument("datafile", help="the plain text file of grib output")
    parser.add_argument("pcfile", help="the csv file for PCs")
    parser.add_argument("-o", "--output", help="the name of output files", default="output.csv")
    args = parser.parse_args()
    # Read grib text file
    grb = readGribText(args.datafile)
    pca = readPCs(args.pcfile)
    # Calculate projection
    loadings = calProjection(grb, pca)
    # Output
    #print(loadings)
    writeToCsv(loadings, args.output)
    # done
    return(0)

#==========
# Script
#==========
if __name__=="__main__":
    main()
