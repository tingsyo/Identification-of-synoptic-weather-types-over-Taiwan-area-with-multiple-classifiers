#=======================================================================
# File: read_cwb_station.r
# Purpose:
#   Read in CWB station data in fixed-width format. Example:
#-----------------------------------------------------------------------
# ID     YearMoDaHr Press    Temp    RH%    WS    WD     Sun  Rain
# 466920 1987 1 1 1 1019.7   20.2     80    6.9   90.0    0.0 -999.9
#-----------------------------------------------------------------------
# widths = c(7,4,2,2,2,7,7,7,7,7,7,7)
#=======================================================================
# List all .dat files in the given directory
#all.stations <- list.files("D:\\work/atmophericscience_data/cwb_station/cleaned/", pattern="*.dat", full.names=T)
#tmp <- all.stations[1]
#all.stations[1] <- all.stations[2]
#all.stations[2] <- tmp
#rm(tmp)

# Read in files
read.cwbs <- function(dfile) {
    x <- read.fwf(file = dfile, 
                  widths = c(7,4,2,2,2,7,7,7,7,7,7,7),
                  colClass = "character", #c("character","integer","integer","integer","integer","numeric","numeric","numeric","numeric","numeric","numeric","numeric"),                  
                  col.names = c("ID","year","month","day","hour","pressure","temperature","RH","wind-speed","wind-direction","sun","rain"),
                  na.strings=c("-999.9","-999.8","-999.7","-999.6","-9997","-9998","-9999","9999"),
                  stringsAsFactors=F,
                  strip.white=T)
    # Fix wind.direction 999.9
    wd.missing <- which(x[,10]=="999.9")
    x[wd.missing, 10] <- rep(NA,length(wd.missing))
    return(x)
}

# Scan through the folders for all *.dat files and generate summary
summarize.cwbs <- function(files, idList=NULL, 
                           yearList=NULL, monthList=NULL, dayList=NULL, hourList=NULL,
                           keepData=FALSE){
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
    cat('\r', files[i])
    tmp <- read.cwbs(files[i])
    flush.console()
    # Apply time filters
    if(!is.null(yearList)){
      tmp <- tmp[which(tmp$year %in% yearList),]
    }
    if(!is.null(monthList)){
      tmp <- tmp[which(tmp$month %in% monthList),]
    }
    if(!is.null(dayList)){
      tmp <- tmp[which(tmp$day %in% dayList),]
    }
    if(!is.null(hourList)){
      tmp <- tmp[which(tmp$hour %in% hourList),]
    }
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
      for(i in 6:12){
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

# Compute daily summary
# Keep mean, sd, max and min
convertToDaily <- function(x){
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
    means <- apply(tmp[,6:12], 2, function(x){mean(as.numeric(x), na.rm=T)})
    sds <- apply(tmp[,6:12], 2, function(x){sd(as.numeric(x), na.rm=T)})
    maxs <- apply(tmp[,6:12], 2, function(x){max(as.numeric(x), na.rm=T)})
    mins <- apply(tmp[,6:12], 2, function(x){min(as.numeric(x), na.rm=T)})
    #
    daily <- c("ID"=tmp[1,1], "year"=tmp[1,2], "month"=tmp[1,3], "day"=tmp[1,4],
               "p.mean"=means[1], "p.sd"=sds[1], "p.max"=maxs[1], "p.min"=mins[1],
               "t.mean"=means[2], "t.sd"=sds[2], "t.max"=maxs[2], "t.min"=mins[2],
               "rh.mean"=means[3], "rh.sd"=sds[3], "rh.max"=maxs[3], "rh.min"=mins[3],
               "ws.mean"=means[4], "ws.sd"=sds[4], "ws.max"=maxs[4], "ws.min"=mins[4],
               "wd.mean"=means[5], "wd.sd"=sds[5], "wd.max"=maxs[5], "wd.min"=mins[5],
               "sun.mean"=means[6], "sun.sd"=sds[6], "sun.max"=maxs[6], "sun.min"=mins[6],
               "rain.mean"=means[7], "rain.sd"=sds[7], "rain.max"=maxs[7], "rain.min"=mins[7]
              )
    #
    rname <- as.character(as.Date(paste(daily[2:4], collapse="-")))
    output <- rbind(output, daily)
    rownames(output)[nrow(output)] <- rname
  }
  return(output)
}

# Combine daily data of all stations into one data frame
combineStations <- function(dlist){
  output <- NULL
  vnames <- c("p.mean","p.sd","p.max","p.min",
              "t.mean","t.sd","t.max","t.min",
              "rh.mean","rh.sd","rh.max","rh.min",
              "ws.mean","ws.sd","ws.max","ws.min",
              "wd.mean","wd.sd","wd.max","wd.min",
              "sun.mean","sun.sd","sun.max","sun.min",
              "rain.mean","rain.sd","rain.max","rain.min")
  for(i in 1:length(dlist)){
    id <- dlist[[i]][1,1]
    tmp <- dlist[[i]][,5:32]
    colnames(tmp) <- paste(vnames, id, sep=".")
    output <- cbind(output, tmp)
  }
  return(data.frame(output))
}

# Convert wind-direction / wind-speed to U/V
convertWindToUV <- function(wind){
    #print(wind)
    rad <- pi/180.
    ws <- as.numeric(wind[1])
    wd <- as.numeric(wind[2])
    u <- -1*ws*sin(rad*wd) 
    v <- -1*ws*cos(rad*wd)
    #print(c(u,v))
    return(c(u=u,v=v))
}

#
convertToDailyUV <- function(x){
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
    means <- apply(tmp[,6:12], 2, function(x){mean(as.numeric(x), na.rm=T)})
    sds <- apply(tmp[,6:12], 2, function(x){sd(as.numeric(x), na.rm=T)})
    maxs <- apply(tmp[,6:12], 2, function(x){max(as.numeric(x), na.rm=T)})
    mins <- apply(tmp[,6:12], 2, function(x){min(as.numeric(x), na.rm=T)})
    #
    daily <- c("ID"=tmp[1,1], "year"=tmp[1,2], "month"=tmp[1,3], "day"=tmp[1,4],
               "p.mean"=means[1], "p.sd"=sds[1], "p.max"=maxs[1], "p.min"=mins[1],
               "t.mean"=means[2], "t.sd"=sds[2], "t.max"=maxs[2], "t.min"=mins[2],
               "rh.mean"=means[3], "rh.sd"=sds[3], "rh.max"=maxs[3], "rh.min"=mins[3],
               "u.mean"=means[4], "u.sd"=sds[4], "u.max"=maxs[4], "u.min"=mins[4],
               "v.mean"=means[5], "v.sd"=sds[5], "v.max"=maxs[5], "v.min"=mins[5],
               "sun.mean"=means[6], "sun.sd"=sds[6], "sun.max"=maxs[6], "sun.min"=mins[6],
               "rain.mean"=means[7], "rain.sd"=sds[7], "rain.max"=maxs[7], "rain.min"=mins[7]
    )
    #
    rname <- as.character(as.Date(paste(daily[2:4], collapse="-")))
    output <- rbind(output, daily)
    rownames(output)[nrow(output)] <- rname
  }
  return(output)
}

# 
combineStationsUV <- function(dlist){
  output <- NULL
  vnames <- c("p.mean","p.sd","p.max","p.min",
              "t.mean","t.sd","t.max","t.min",
              "rh.mean","rh.sd","rh.max","rh.min",
              "u.mean","u.sd","u.max","u.min",
              "v.mean","v.sd","v.max","v.min",
              "sun.mean","sun.sd","sun.max","sun.min",
              "rain.mean","rain.sd","rain.max","rain.min")
  for(i in 1:length(dlist)){
    id <- dlist[[i]][1,1]
    tmp <- dlist[[i]][,5:32]
    colnames(tmp) <- paste(vnames, id, sep=".")
    output <- cbind(output, tmp)
  }
  return(data.frame(output))
}


