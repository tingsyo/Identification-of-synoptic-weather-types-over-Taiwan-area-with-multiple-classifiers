#=======================================================================
# File: cwb_station_pca.r
# Purpose:
#   Preprocess CWB station data.
#-----------------------------------------------------------------------
# Data: 
# - cwbs.raw.uv.RData
#   - summary
#   - data:
#     - 25 stations
#       - Row: 2001-01-01 ~ 2010-12-31, hourly
#       - Column: P, T, RH, U, V, sun, rain
#-----------------------------------------------------------------------
# Pre-processing
# - Re-arrange data:
#   - 25 stations
#     - Row: 2001-01-01 ~ 2010-12-31, daily
#     - Column: P-01, P-02, ..., P-24, T-01, T-02, ..., T-24, ..., rain-24
# - Dimension reduction with PCA
#   - By each variable of each station
#   - By all variable of each station
#   - By each variable of all stations
#   - By all variable of all stations
#=======================================================================

# Compare various data combination for PCA
convertHourlyToDaily <- function(x){
    # Re-arrange raw data from YYYYMMDDHH-Var to YYYYMMDD-Var.HH
    convertHourlyToDaily <- function(x, useList=F){
        # Check record length
        if(!(nrow(x)%%24==0)){
            stop("Record length is not divisible by 24, please check.")
        }
        #
        output <- NULL
        # For every 24 hours
        for(i in 1:(nrow(x)/24)){
            # Preprare data range
            idx1 <- (i-1)*24+1
            idx2 <- i*24
            tmp <- x[idx1:idx2,]
            # Replace NA rain with 0
            tmp[which(is.na(tmp[,11])),11] <- 0 
            # Combine to daily data
            daily <- as.numeric(c(tmp[,6], tmp[,7], tmp[,8], tmp[,9], tmp[,10], tmp[,11]))
            #
            rname <- as.character(as.Date(paste(tmp[1,2:4], collapse="-")))
            output <- rbind(output, daily)
            rownames(output)[nrow(output)] <- rname
        }
        colnames(output) <- c(paste("p",1:24,sep="."),paste("t",1:24,sep="."),paste("rh",1:24,sep="."),paste("u",1:24,sep="."),paste("v",1:24,sep="."),paste("precipitation",1:24,sep="."))
        # Create dailyList
        if(useList){
            dailyList <- list("p"=data.frame(output[,1:24]),"t"=data.frame(output[,25:48]),
                              "rh"=data.frame(output[,49:72]), "u"=data.frame(output[,73:96]),
                              "v"=data.frame(output[,97:120]), "precipitation"=data.frame(output[,121:144]))
            output <- dailyList
        }
        #
        return(list(id=x[1,1],data=data.frame(output)))
    }
    # create daily data
    x.daily <- NULL
    for (i in 1:length(x)){
        tmp <- convertHourlyToDaily(x[[i]])
        x.daily <- c(x.daily, list(tmp))
    }
    #
    return(x.daily)
}

# PCA evaluation
evalPCA <- function(x){
    pca <- prcomp(~., data=x, na.action=na.omit, scale=T)
    ev <- cumsum(pca$sdev/sum(pca$sdev))
    npc70 <- which(ev>=0.7)[1]
    npc80 <- which(ev>=0.8)[1]
    npc90 <- which(ev>=0.9)[1]
    return(c(pca, list("explainedVar"=ev, "npc70"=npc70, "npc80"=npc80, "npc90"=npc90)))
}

# Test PCA
testPCA <- function(x){
    # Parameters
    vars <- c("p","t","rh","u","v","precipitation")
    varidx <- list("p"=1:24, "t"=25:48, "rh"=49:72, "u"=73:96, "v"=97:120, "precipitation"=121:144)
    nstation <- 25
    # Perform PCA on a single variable of a single station
    pca.1s1v <- function(x){
        results <- NULL
        for(i in 1:nstation){
        for(j in 1:6){
            pca <- evalPCA(x[[i]]$data[,varidx[[j]]])
            results <- rbind(results, c("id"=x[[i]]$id, "var"=vars[j], "npc70"=pca$npc70, "npc80"=pca$npc80, "npc90"=pca$npc90, pca$explainedVar))
        }
        }
        return(results)
    }
    # Perform PCA on all variables of a single station
    pca.1s6v <- function(x){
      results <- NULL
      for(i in 1:nstation){
        pca <- evalPCA(x[[i]]$data[,1:144])
        results <- rbind(results, c("id"=x[[i]]$id, "npc70"=pca$npc70, "npc80"=pca$npc80, "npc90"=pca$npc90, pca$explainedVar))
      }
      return(results)
    }
    # Perform PCA on a single variable of all stations
    pca.25s1v <- function(x){
      results <- NULL
      for(j in 1:5){
        newx <- x[[1]]$data[,varidx[[j]]]
        for(i in 2:nstation){
          tmp <- x[[i]]$data[,varidx[[j]]]
          names(tmp) <- paste(names(tmp),i,sep=".")
          newx <- cbind(newx, tmp)
        }
        pca <- evalPCA(newx)
        results <- rbind(results, c("var"=vars[j], "npc70"=pca$npc70, "npc80"=pca$npc80, "npc90"=pca$npc90, pca$explainedVar))
      }
      return(results)
    }
    # Perform PCA on all variables of all stations
    pca.25s6v <- function(x){
      results <- NULL

      return(results)
    }
    #
    return(list("s1v1"=pca.1s1v(x),"s1v6"=pca.1s6v(x),"s25v1"=pca.25s1v(x)))
}