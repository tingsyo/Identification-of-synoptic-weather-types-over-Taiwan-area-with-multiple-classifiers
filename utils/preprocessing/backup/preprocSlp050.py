# !/Library/Frameworks/Python.framework/Versions/3.4/bin/python3
#
# File: preprocSlp050.py
# Purpose: preprocess NCEP SLP 2014 0.5 degree at 00Z
#
import sys, os, re, csv

def parseMapToRow(furi, fname):
    ''' Parse a NCEP text data file into a data row '''
    # Read file
    with open(furi, "r") as f:
        data = f.readlines()
    f.close()
    # Replace line breaks
    d2 = [d.replace("\n","") for d in data]
    row = [fname] + d2[0].split(" ") + d2[1:]
    # done
    return(row)

def writeToCsv(output, fname):
    # Overwrite the output file:
    with open(fname, 'w', newline='', encoding='utf-8-sig') as csvfile:
        writer = csv.writer(csvfile, delimiter=";",quotechar="'", quoting=csv.QUOTE_ALL)
        for r in output:
            writer.writerow(r)
    return(0)

def main():
    datadir = "./"
    try:
        # 1st argument: target directory
        datadir = sys.argv[1]
        # 2nd argument: output file-name (optional)
        if(len(sys.argv)>=3):
            outfile = sys.argv[2]
        else:
            print("Use default output name: output.csv")
            outfile = "output.csv"
        # Walk through the targe directory for *.xlsx or *.xls
        recs = []
        for root, dirs, files in os.walk(datadir):
            for file in files:
                if (file.endswith("00_00.txt") and (not file.startswith("~"))):
                    full_fname = os.path.join(root, file)
                    recs.append(parseMapToRow(full_fname, file))
        # Write output to csv
        writeToCsv(recs, outfile)
    except BaseException:
        tb = sys.exc_info()[2]
        raise Exception(...).with_traceback(tb)        
    # Write closing
    # with open(outfile, 'a+', newline='', encoding='utf-8-sig') as ofile:
    #     ofile.write("{}]")
    # return(0)

#==========
# Script
#==========
if __name__=="__main__":
    main()
