#!/usr/bin/bash
#Never go to standby:
powercfg -change -standby-timeout-ac 0
#
cd ~/work.db/workspace/weatherClassification
python3 utils/ncep_svd.py raw_data/ncep-cfsr/text/h500/ -n 20 -o data/ncepcfsr/svd20.h500.csv
python3 utils/ncep_svd.py raw_data/ncep-cfsr/text/t700/ -n 20 -o data/ncepcfsr/svd20.t700.csv
python3 utils/ncep_svd.py raw_data/ncep-cfsr/text/t800/ -n 20 -o data/ncepcfsr/svd20.t800.csv
python3 utils/ncep_svd.py raw_data/ncep-cfsr/text/t925/ -n 20 -o data/ncepcfsr/svd20.t925.csv
python3 utils/ncep_svd.py raw_data/ncep-cfsr/text/rh700/ -n 20 -o data/ncepcfsr/svd20.rh700.csv
python3 utils/ncep_svd.py raw_data/ncep-cfsr/text/rh800/ -n 20 -o data/ncepcfsr/svd20.rh800.csv
python3 utils/ncep_svd.py raw_data/ncep-cfsr/text/rh925/ -n 20 -o data/ncepcfsr/svd20.rh925.csv
python3 utils/ncep_svd.py raw_data/ncep-cfsr/text/mslp/ -n 20 -o data/ncepcfsr/svd20.mslp.csv
#
#Go to standby in 15 minutes:
powercfg -change -standby-timeout-ac 15
