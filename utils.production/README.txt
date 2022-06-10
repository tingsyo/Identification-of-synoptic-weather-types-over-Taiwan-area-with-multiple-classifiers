# File: README.txt
# Author: Ting-Shuo Yo
# Description: 本工具組的概述，使用方法，以及流程
#
# [概述]
# 本工具組初始的開發目的是探索 weather event classification 的可行性，建立由「氣象參數」來辨識「天氣事件」的統計模型。
#
# [流程]
# wc01. 資料取得與整理 (data aquisition and data cleaning)
# wc02. 網格資料的維度降減 (dimension reduction of grid data)
# wc03. 整齊資料集的建立 (establishing tidy data)
# wc04. 統計模型的建立與評估 (model building and evaluation)
# wc05. 使用建立的統計模型作預測 (prediction)
#
# [步驟]
# (1) 事件記錄（csv 格式），包含「日期」和「事件是否發生」欄位
# (2) 網格資料（grib2 格式），每個時間的所有特性層在一個檔案，以日期為檔名開頭
# (3) 依據 (1) 與 (2) 的檔名與資料夾，修改  wc00.parameters.r / w01.process.grib2.sh

# 參數 (in wc00.parameters.r)
DATADIR <- "./workspace/"           # 從 grib2 檔抽取出的文字格式資料儲存路徑
VARS <- c("h500","mslp","t850")     # 從 grib2 檔抽取出的特性層名稱
K <- 3                              # 使用 RPCA 降減到的維度（每個特性層）
REDUCED_DATA <- "rpca_output.csv"   # 儲存維度降減後的資料
RPCA_DATA <- "rpcs.RData"           # 儲存 RPCA 模型的 R 物件
eventLog <- "./front_2008.csv"      # 事件記錄檔，包含「日期」和「事件是否發生」欄位（date, event）
IODATA <- "iodata.csv"              # 儲存整齊資料
METRIC_FILE <- "results.csv"        # 儲存模型訓練的指標，confusion matrix
MODEL_FILE <- "results.RData"       # 儲存訓練完成的模型（ R 物件）
