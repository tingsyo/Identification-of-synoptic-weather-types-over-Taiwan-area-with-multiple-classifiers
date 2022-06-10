# !/usr/bin/python3
#
# File: read_cwb_station.py
# Purpose: preprocess ECMWF-20C data at 00Z
#
import sys, os, re, csv, argparse, math
HEADERS = ['id','year','month','day','hour','p','t','rh','u','v','precipitation']

def readCwbText(dpath, startYear, endYear, outputdir):
    ''' Extract CWB station data in text format '''
    #
    # Walk through all *_all.txt files
    for root, dirs, files in os.walk(dpath):
        for file in files:
            if (file.endswith("_all.txt") and (not file.startswith("~"))):
                full_fname = os.path.join(root, file)
                cwb = readCwbs(full_fname, startYear, endYear)
                writeToCsv(cwb, outputdir+'/'+file+'.csv')
    # done
    return(0)

def readCwbs(furi, sy, ey):
    recs = []
    # Read text file
    with open(furi) as f:
        lines = f.readlines()
    # Parse records
    for line in lines:
        year = int(line[7:11])
        if (year>=sy and year<=ey) :
            rec = parseCwbsLine(line)
            recs.append(rec)
    #
    print(furi + ':' + str(len(lines)) + ' records in total, ' + str(len(recs)) + ' records kept.' )
    # Done
    return(recs)

def parseCwbsLine(rec):
    # Split line into elements
    items = list(filter(None, rec.split(' ')))
    # Retrieve wanted data
    id = items[0]
    year = items[1][0:4]
    month = items[1][4:6]
    day = items[1][6:8]
    hour = items[1][8:10]
    p = float(items[3])
    t = float(items[4])
    rh = float(items[7]) 
    ws = float(items[9]) 
    wd = float(items[10]) 
    precip = float(items[15])
    # Convert ws/wd to u/v
    uv = convertWindToUv(ws, wd)
    #
    results = [id, year, month, day, hour, p, t, rh, uv[0], uv[1], precip]
    # Done
    return(results)

def convertWindToUv(ws, wd):
    ''' Converting wind-speed / wind-direction to U/V '''
    rad = math.pi/180.0
    u = -1*ws*math.sin(rad*wd) 
    v = -1*ws*math.cos(rad*wd)
    return([u,v])

def writeToCsv(output, fname):
    # Overwrite the output file:
    with open(fname, 'w', newline='', encoding='utf-8-sig') as csvfile:
        writer = csv.writer(csvfile, delimiter=',',quotechar='"', quoting=csv.QUOTE_ALL)
        writer.writerow(HEADERS)
        for r in output:
            writer.writerow(r)
    return(0)

def main():
    # Configure Argument Parser
    parser = argparse.ArgumentParser(description='Read in ECMWF-20C data in grib format.')
    parser.add_argument("datapath", help="the plain text file of ECMWF grib output")
    parser.add_argument("-s", "--startYear", help="the starting year of output data", type=int, default=-1)
    parser.add_argument("-e", "--endYear", help="the ending year of output data", type=int, default=-1)
    parser.add_argument("-o", "--output", help="the prefix of output files", default="output.csv")
    args = parser.parse_args()
    # Read data
    recs = readCwbText(args.datapath, args.startYear, args.endYear, args.output)
    # Output
    #writeToCsv(recs, args.output)
    return(0)

#==========
# Script
#==========
if __name__=="__main__":
    main()
