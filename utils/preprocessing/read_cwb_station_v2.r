#=======================================================================
# File: read_cwb_station.v2.r
# Purpose:
#   Read in CWB station data in csv format (pre-processed with python). 
#   Columns: id, year, month, day, hour, p, t, rh, u, v, precipitation
#=======================================================================
# List all .dat files in the given directory
all.raw <- list.files("D:\\/work/atmosphericscience_data/cwb_station/raw_20160505/", pattern="*all.txt", full.names=T)
all.csv <- list.files("D:\\/work/atmosphericscience_data/cwb_station/clean_20160505/", pattern="*.csv", full.names=T)

# Read in files in raw text format
read.raw.cwbs <- function(dfile) {
    x <- read.fwf(file = dfile, 
                  widths = c(7,4,2,2,2,rep(7,46)),
                  colClass = "character", #c("character","integer","integer","integer","integer","numeric","numeric","numeric","numeric","numeric","numeric","numeric"),                  
                  na.strings=c("-9999","-9998","-9997","-9996","-9991"),
                  stringsAsFactors=F,
                  strip.white=T)
    # Convert wind to U/V
    uv <- t(apply(x[,c(13,14)],1,convertWindToUV))
    # Selecting variables
    #newx <- cbind(x,uv)
    newx <- cbind(x[,c(1,2,3,4,5,7,8,11)], uv, x[,19])
    colnames(newx) <- c("id","year","month","day","hour","p","t","rh","u","v","precipitation")
    return(newx)
}

# Read in files in csv format (filtered with python script)
read.csv.cwbs <- function(dfile){
  x <- read.csv(file=dfile,
                fileEncoding = "UTF-8-BOM",
                colClass="character",
                na.strings=c("-9999.0","-9998.0","-9997.0","-9996.0","-9991.0"),
                stringsAsFactors=F,
                strip.white=T)
  # Convert to numeric
  x$p <- as.numeric(x$p)
  x$t <- as.numeric(x$t)
  x$rh <- as.numeric(x$rh)
  x$u <- as.numeric(x$u)
  x$v <- as.numeric(x$v)
  x$precipitation <- as.numeric(x$precipitation)
  #
  return(x)
}

# Scan through the folders for all files and generate summary
summarize.cwbs <- function(files, keepData=FALSE){
  require(stringr)
  # Customized summary function
  mySummary <- function(x){
    if(!any(is.na(x))){
      res <- c(summary(x),"NA's"=0)
    } else {
      res <- summary(x)
    }
    return(res)
  }
  # Get all file names
  #files <- list.files(destDir, pattern="*.dat", full.names=T)
  output <- NULL
  tmpdata <- NULL
  #
  for(i in 1:length(files)){
    #
    cat('\n', files[i])
    tmp <- read.csv.cwbs(files[i])
    flush.console()
    # Check record length
    recl <- dim(tmp)[1]
    # Stop parsing if there is no records
    if(recl==0){
      ssumm <- rep("NA",54)
    } else {
      # Generate summary
      ## General
      station.id <- str_trim(tmp$ID[1])
      dateStrings <- paste(tmp$year, str_pad(tmp$month,2,pad="0"), str_pad(tmp$day,2,pad="0"), sep="-")
      startDate <- dateStrings[1]
      endDate <- dateStrings[nrow(tmp)]
      completeRec <- sum(complete.cases(tmp)*1)
      ssumm <- c("id"=station.id, "start"=startDate, "end"=endDate, "total"=recl, "complete"=completeRec)
      ## Loop through variables
      for(i in 6:ncol(tmp)){
        vname <- names(tmp)[i]
        vsumm <- mySummary(as.numeric(tmp[,i]))
        names(vsumm) <- paste(vname,names(vsumm),sep=".")
        ssumm <- c(ssumm, vsumm)
      }
    }
    # Aggregate data
    tmpdata <- c(tmpdata, list(tmp))
    # Aggregate summary
    output <- cbind(output, ssumm)
  }
  # Use filename as column name
  colnames(output) <- unlist(lapply(str_split(files,"/"), function(x){return(x[length(x)])}))
  if(keepData){
    return(list(summary=output, data=tmpdata))
  } else {
    return(output)
  }
}

# Data imputation
imputeHourlyData <- function(x, radius=50, slope=10){
  ncol <- ncol(x)
  # Use weighted mean for all variables except precipitation
  for(i in 1:(ncol-1)){
    naidx <- which(is.na(x[,i]))
    if(length(naidx)>0){
      for(j in 1:length(naidx)){
        x[naidx[j],i] <- weighted.mean(x[(naidx[j]-radius):(naidx[j]+radius),i], 
                                       pnorm(1:(2*radius+1), mean=(radius+1), sd=slope),na.rm=T)
      }
    }
  }
  # For precipitation, just put 0
  x[which(is.na(x[,6])),6] <- 0.0
  # Done
  return(x)
}


# Keep mean, sd, max and min
convertToDailyStat <- function(x){
  # Check record length
  if(!(nrow(x)%%24==0)){
    stop("Record length is not divisible by 24, please check.")
  }
  #
  output <- NULL
  # For every 24 hours
  for(i in 1:(nrow(x)/24)){
    #
    idx1 <- (i-1)*24+1
    idx2 <- i*24
    tmp <- x[idx1:idx2,]
    # 
    sid <- tmp[1,1]
    year <- tmp[1,2]
    month <- tmp[1,3]
    day <- tmp[1,4]
    # Compute daily summary: mean, sd, max, min
    means <- apply(tmp[,6:11], 2, function(x){mean(as.numeric(x), na.rm=T)})
    sds <- apply(tmp[,6:11], 2, function(x){sd(as.numeric(x), na.rm=T)})
    maxs <- apply(tmp[,6:11], 2, function(x){max(as.numeric(x), na.rm=T)})
    mins <- apply(tmp[,6:11], 2, function(x){min(as.numeric(x), na.rm=T)})
    #
    daily <- c(tmp[1,1], tmp[1,2], tmp[1,3], tmp[1,4],
               means[1], sds[1], maxs[1], mins[1],
               means[2], sds[2], maxs[2], mins[2],
               means[3], sds[3], maxs[3], mins[3],
               means[4], sds[4], maxs[4], mins[4],
               means[5], sds[5], maxs[5], mins[5],
               means[6], sds[6], maxs[6], mins[6])
    #
    rname <- as.character(as.Date(paste(daily[2:4], collapse="-")))
    output <- rbind(output, daily)
    rownames(output)[nrow(output)] <- rname
  }
  colnames(output) <- c("id","year","month","day",
                        "p.mean","p.sd","p.max","p.min",
                        "t.mean","t.sd","t.max","t.min",
                        "rh.mean","rh.sd","rh.max","rh.min",
                        "u.mean","u.sd","u.max","u.min",
                        "v.mean","v.sd","v.max","v.min",
                        "prec.mean","prec.sd","prec.max","prec.min")
  # Make data frame
  output <- data.frame(output)
  output[,5:28] <- apply(output[,5:28],2,as.numeric)
  return(output)
}

# convertToDaily
convertAllToDailyStat <- function(xlist){
  output <- NULL
  #
  for(i in 1:length(xlist)){
    id <- paste("stn", xlist[[i]][1,1], sep=".")
    tmp <- convertToDailyStat(xlist[[i]])
    output <- c(output, list(tmp))
    names(output)[length(output)] = id
  }
  return(output)
}


# 
combineStations <- function(dlist){
  output <- NULL
  vnames <- c("p.mean","p.sd","p.max","p.min",
              "t.mean","t.sd","t.max","t.min",
              "rh.mean","rh.sd","rh.max","rh.min",
              "u.mean","u.sd","u.max","u.min",
              "v.mean","v.sd","v.max","v.min",
              "precipitation.mean","precipitation.sd","precipitation.max","precipitation.min")
  for(i in 1:length(dlist)){
    id <- dlist[[i]][1,1]
    print(paste("Processing", id))
    tmp <- dlist[[i]][,5:28]
    colnames(tmp) <- paste(vnames, id, sep=".")
    if(is.null(output)){
      output <- tmp
    } else {
      output <- cbind(output, tmp)
    }
  }
  return(data.frame(output))
}

#cwbs.dailyStat.imputed <- convertAllToDailyStat(cwbs.imputed)
#cwbs.25dailyStat.imputed <- combineStations(cwbs.dailyStat.imputed)
