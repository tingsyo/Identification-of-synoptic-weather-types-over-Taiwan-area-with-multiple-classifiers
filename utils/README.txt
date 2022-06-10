# File: README.txt
# Author: Ting-Shuo Yo
# Description: 本工具組的概述，使用方法，以及流程
#
# [概述]
# 本工具組初始的開發目的是探索 weather event classification 的可行性，建立由「氣象參數」來辨識「天氣事件」的統計模型。
#
# [流程]
# 1. 資料取得與整理 (data aquisition and data cleaning)
# 2. 網格資料的維度降減 (dimension reduction of grid data)
# 3. 整齊資料集的建立 (establishing tidy data)
# 4. 統計模型的建立與評估 (model building and evaluation)
#
# [步驟]
# (1) 事件記錄（csv 格式），包含「日期」和「事件是否發生」欄位
# (2) 網格資料（grib2 格式），每個時間的所有特性層在一個檔案，以日期為檔名開頭
# (3) 依據 (1) 與 (2) 的檔名與資料夾，修改  run.research.sh / run.application.sh
# (4) 執行 run.research.sh / run.application.sh
