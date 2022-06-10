# !/usr/bin/python3
#
# File: convertPC.py
# Purpose: Convert Principle Components from GRIB order to TEXT order (Y:60:0 -> Y:0:60)
#
import sys, os, re, csv, argparse
import numpy as np

def convertPCs(furi, nx, ny):
    ''' For each PC, inverse the order of Y with nx*ny records '''
    print("Processing "+furi)
    recs = []
    # Read PCs
    with open(furi, encoding='utf-8-sig') as f:
        cr = csv.reader(f, delimiter=',', quotechar='"')
        for rec in cr:
            recs.append(inverseY(rec,nx,ny))
    # Done
    return(recs)
    
def inverseY(row, nx, ny):
    ''' Inverse the order of Y in a row of nx*ny records '''
    # Check record length
    if (len(row)!=nx*ny):
        print("Data dimension error, return original records. NX: "+str(nx)+" NY: "+str(ny)+" length: "+str(len(row)))
        return(row)
    # Split row
    xs = []
    for i in range(ny):
        xs.append(row[i*nx:(i+1)*nx])
    # Reverse order of xs
    newrow = []
    for i in range(ny,0,-1):
        newrow += xs[i-1]
    # Done
    #print(row)
    #print(newrow)
    return(newrow)
    
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
    parser.add_argument("datapath", help="the plain text file of ECMWF grib output")
    parser.add_argument("-x", "--nx", help="The number of grid in x (lon)", type=int, default=241)
    parser.add_argument("-y", "--ny", help="The number of grid in y (lat)",type=int,  default=121)
    parser.add_argument("-o", "--outputPath", help="the path of output files", default="./")
    args = parser.parse_args()
    # Walk through all grb2 files
    for root, dirs, files in os.walk(args.datapath):
        for file in files:
            if (file.endswith(".csv") and (not file.startswith("~"))):
                furi = os.path.join(root, file)
                # Read and convert csv file
                newPC = convertPCs(furi, args.nx, args.ny)
                # output
                ofile = args.outputPath + file.replace(".csv",".SN.csv")
                writeToCsv(newPC, ofile)
    # done
    return(0)

#==========
# Script
#==========
if __name__=="__main__":
    main()
