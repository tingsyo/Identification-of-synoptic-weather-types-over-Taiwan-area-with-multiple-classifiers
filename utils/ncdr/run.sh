# !/bin/bash
#-----------------------------------------------------------------------
# Operation phase script for weather classification
#-----------------------------------------------------------------------
# Argument parser
while [[ $# > 1 ]]
do
key="$1"

case $key in
    -i|--infile)
    INFILE="$2"
    shift # past argument
    ;;
    -w|--workspace)
    WORKSPACE="$2"
    shift # past argument
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done
echo Input File  = "${INFILE}"
echo Workspace   = "${WORKSPACE}"
if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 $1
fi
# Parameters

# (1) Extract desired data layers and range from model output
wgrib2 $INFILE -match "PRMSL:mean" -lola 60:241:0.5 0:121:0.5 tmp.text/mslp.txt text
wgrib2 $INFILE -match "PWAT:entire" -lola 60:241:0.5 0:121:0.5 tmp.text/pwat.txt text
wgrib2 $INFILE -match "TMP:925" -lola 60:241:0.5 0:121:0.5 tmp.text/t925.txt text
wgrib2 $INFILE -match "RH:925" -lola 60:241:0.5 0:121:0.5 tmp.text/rh925.txt text
wgrib2 $INFILE -match "UGRD:925" -lola 60:241:0.5 0:121:0.5 tmp.text/u925.txt text
wgrib2 $INFILE -match "VGRD:925" -lola 60:241:0.5 0:121:0.5 tmp.text/v925.txt text
wgrib2 $INFILE -match "UGRD:850" -lola 60:241:0.5 0:121:0.5 tmp.text/u850.txt text
wgrib2 $INFILE -match "VGRD:850" -lola 60:241:0.5 0:121:0.5 tmp.text/v850.txt text
wgrib2 $INFILE -match "TMP:800" -lola 60:241:0.5 0:121:0.5 tmp.text/t800.txt text
wgrib2 $INFILE -match "RH:800" -lola 60:241:0.5 0:121:0.5 tmp.text/rh800.txt text
wgrib2 $INFILE -match "TMP:700" -lola 60:241:0.5 0:121:0.5 tmp.text/t700.txt text
wgrib2 $INFILE -match "RH:700" -lola 60:241:0.5 0:121:0.5 tmp.text/rh700.txt text
wgrib2 $INFILE -match "HGT:500" -lola 60:241:0.5 0:121:0.5 tmp.text/h500.txt text
wgrib2 $INFILE -match "UGRD:200" -lola 60:241:0.5 0:121:0.5 tmp.text/u200.txt text
wgrib2 $INFILE -match "VGRD:200" -lola 60:241:0.5 0:121:0.5 tmp.text/v200.txt text

# (2) Project extracted data on PCs
python3 utils/projectDataToPCs.py tmp.text/mslp.txt pca.pickle/mslp.svd20.pickle -o tmp.csv/mslp.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/pwat.txt pca.pickle/pwat.svd20.pickle -o tmp.csv/pwat.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/t925.txt pca.pickle/t925.svd20.pickle -o tmp.csv/t925.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/rh925.txt pca.pickle/rh925.svd20.pickle -o tmp.csv/rh925.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/u925.txt pca.pickle/u925.svd20.pickle -o tmp.csv/u925.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/v925.txt pca.pickle/v925.svd20.pickle -o tmp.csv/v925.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/u850.txt pca.pickle/u850.svd20.pickle -o tmp.csv/u850.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/v850.txt pca.pickle/v850.svd20.pickle -o tmp.csv/v850.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/t800.txt pca.pickle/t800.svd20.pickle -o tmp.csv/t800.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/rh800.txt pca.pickle/rh800.svd20.pickle -o tmp.csv/rh800.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/t700.txt pca.pickle/t700.svd20.pickle -o tmp.csv/t700.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/rh700.txt pca.pickle/rh700.svd20.pickle -o tmp.csv/rh700.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/h500.txt pca.pickle/h500.svd20.pickle -o tmp.csv/h500.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/u200.txt pca.pickle/u200.svd20.pickle -o tmp.csv/u200.svd20.csv
python3 utils/projectDataToPCs.py tmp.text/v200.txt pca.pickle/v200.svd20.pickle -o tmp.csv/v200.svd20.csv

# (3) Predict with new projections and the trained SVM model
Rscript --vanilla classifyEvents.r
