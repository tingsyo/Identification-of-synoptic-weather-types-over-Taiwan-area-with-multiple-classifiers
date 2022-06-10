# !/usr/bin/python3
#
# File: ec20c_svd.py
# Purpose: preprocess ECMWF-20C data at 00Z
#
import sys, os, re, csv, argparse
import numpy as np
from sklearn.decomposition import RandomizedPCA
from struct import *

def readNcepGrib(dpath, index):
    ''' Extract NCEP-CFSR data in GRIB2 format '''
    #
    recs = []
    # Walk through all grb2 files
    for root, dirs, files in os.walk(dpath):
        for file in files:
            if (file.endswith(".grb2") and (not file.startswith("~"))):
                full_fname = os.path.join(root, file)
                recs.append(readGrib2(full_fname, index))
    # done
    return(recs)
    
def readGrib2(furi, index):
    # Call external wgrib binary to convert the GRB2 to text
    from subprocess import call
    call(["wgrib2", furi, "-d", index, "-ieee","tmp.bin"])
    # Read text file
    with open(furi, "rb", encoding='utf-8') as f:
        row = f.read(4)
    # Convert to float
    del row[0]
    frow = unpack('f',row)
    # Done
    return(frow)
    
def readNcepText(dpath):
    ''' Extract NCEP-CFSR data in text format '''
    #
    recs = []
    index = []
    # Walk through all grb2 files
    for root, dirs, files in os.walk(dpath):
        for file in files:
            if (file.endswith("0000.txt") and (not file.startswith("~"))):
                furi = os.path.join(root, file)
                index.append(file.replace('0000.txt',''))
                # Read text file
                #print(file.replace('0000.txt',''))
                with open(furi, "r") as f:
                    row = f.readlines()
                # Convert to float
                del row[0]
                frow = [float(x) for x in row]
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
    #recs = readNcepGrib(args.datapath, args.datalayer)
    recs = readNcepText(args.datapath)
    # Perform Randomized SVD if specified
    if (args.ncomponent!="0"):
        pca = RandomizedPCA(n_components=int(args.ncomponent), whiten=True, random_state=int(args.randomseed))
        newrecs = pca.fit_transform(np.array(recs["records"]))
        print('Performing RandomizedSVD, the explained variance ratio:')
        print(pca.explained_variance_ratio_)
        writeToCsv(newrecs, args.output)
    else:
        newrecs = recs["records"]
    # Output
    writeToCsv(newrecs, args.output)
    with open("ncepsvd.log","w") as f:
        for d in recs["date"]:
            f.write(d+'\n')
    # done
    return(0)

#==========
# Script
#==========
if __name__=="__main__":
    main()
