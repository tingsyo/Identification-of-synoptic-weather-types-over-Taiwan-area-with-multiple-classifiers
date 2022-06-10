#=======================================================================
# File: read_svd.r
# Purpose:
#   Read in SVDs of grid data in csv format (pre-processed with python). 
#   Variables: h500, mslp, pwat, rh700, rh800, rh925, t700, t800, t925,
#              u200, u850, u925, v200, v850, v925 (15 in total)
#=======================================================================
vars <- c("h500","mslp","pwat","rh700","rh800","rh925","t700","t800","t925",
            "u200","u850","u925","v200","v850","v925")

read.csv.svd <- function(dpath, suffix=".csv", nsvd=50){
  output <- NULL
  #
  for(i in 1:length(vars)){
    fname <- paste(dpath, vars[i], suffix, sep="")
    print(fname)
    tmp <- read.csv(fname, header=F, colClasses="character", stringsAsFactors=F, fileEncoding="UTF-8-BOM")
    # Prepare names
    rnames <- tmp[,1]
    ncol.output <- nsvd
    if(nsvd > (ncol(tmp)-1)){
      ncol.output <- ncol(tmp)-1
    }
    cnames <- paste(vars[i], "svd", 1:ncol.output, sep=".")
    # Clean up
    tmp <- tmp[,-1]
    tmp <- tmp[,1:ncol.output]
    tmp <- sapply(tmp, as.numeric)
    rownames(tmp) <- rnames
    colnames(tmp) <- cnames
    #
    output <- cbind(output,tmp)
    #print(dim(tmp))
    #print(dim(output))
  }
  return(data.frame(output))
}

# Derive statistics from confusion matrix
# [ref] https://en.wikipedia.org/wiki/Confusion_matrix
generateCM <- function(pred, ref){
  return(table(pred, ref))
}

cmToMetrics <- function(cm, positive=1){
  # Decode the matrix
  if(positive==0){
    TP <- cm[1,1]/sum(cm)
    TN <- cm[2,2]/sum(cm)
    FP <- cm[1,2]/sum(cm)
    FN <- cm[2,1]/sum(cm)
  } else {
    TP <- cm[2,2]/sum(cm)
    TN <- cm[1,1]/sum(cm)
    FP <- cm[2,1]/sum(cm)
    FN <- cm[1,2]/sum(cm)
  }
  # Derive Metrics
  sensitivity <- TP/(TP+FN)
  specificity <- TN/(FP+TN)
  prevalence <- TP+FN/(FN+TP+FP+TN)
  ppv <- TP/(TP+FP)
  npv <- TN/(TN+FN)
  fpr <- FP/(FP+TN)
  fnr <- FN/(FN+TP)
  fdr <- FP/(FP+TP)
  FOR <- FN/(TN+FN)
  accuracy <- (TP+TN)/(FN+TP+FP+TN)
  F1 <- 2*TP/(2*TP+FP+FN)
  MCC <- (TP*TN-FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN))
  informedness <- sensitivity + specificity - 1
  markedness <- ppv + npv -1
  # Output
  output <- c("Accuracy"=accuracy,
              "True.Positive"=TP,
              "False.Negative"=FN,
              "False.Positive"=FP,
              "True.Negative"=TN,
              "Sensitivity"=sensitivity, 
              "Specificity"=specificity,
              "Prevalence"=prevalence, 
              "Positive.Predictive.Value"=ppv,
              "Negative.Predictive.Value"=npv,
              "False.Positive.Rate"=fpr,
              "False.Discovery.Rate"=fdr,
              "False.Negative.Rate"=fnr,
              "False.Omission.Rate"=FOR,
              "F1.Score"=F1,
              "Matthews.correlation.coefficient"=MCC,
              "Informedness"=informedness,
              "Markedness"=markedness)
  return(output)
}

# Main script
require(caret)
require(gbm)
require(kernlab)

# Experiment settings
rseed <- 5432123
mods <- c("glm","gbm","svm")
results <- NULL
events <- ncdr.train$y
fits <- NULL
# Loop through events
for(ev in 1:3){
  print(names(events)[ev])
  # Create CV folds
  set.seed(777)
  cvOut <- createFolds(events[,ev], k=10)
  cvIn <- cvOut
  for(i in 1:10){
    cvIn[[i]] <- (1:length(events[,ev]))[-cvOut[[i]]]
  }
  ctrl <- trainControl(method="cv", index=cvIn, indexOut=cvOut)
  # Run
  dset <- cbind(events[,ev], ncdr.train$x)
  dset[,1] <- factor(dset[,1])
  # 
  names(dset)[1] <- "event"
  # CV
  cat(paste(mods[1],"..."))
  set.seed(rseed)
  fit.glm <- train(event~., data=dset, method="glm", family="binomial", trControl=ctrl)
  cat(paste(mods[2],"..."))
  set.seed(rseed)
  fit.gbm <- train(event~., data=dset, method="gbm", trControl=ctrl, verbose=F)
  cat(paste(mods[3],"..."))
  set.seed(rseed)
  fit.svmr <- train(event~., data=dset, method="svmRadial", trControl=ctrl)
  #
  cms <- list("glm"=confusionMatrix.train(fit.glm)$table,
              "gbm"=confusionMatrix.train(fit.gbm)$table,
              "svm"=confusionMatrix.train(fit.svmr)$table)
  # save svm model
  fits <- c(fits, list(fit.svmr))
  rm(fit.glm, fit.gbm, fit.svmr)

  # Aggregate results
  results <- c(results, list(cms))
  rm(cms)
}
names(results) <- names(events)[1:3]
rm(ev, i)
# Convert results to metrics
results.metrics <- NULL
for(i in 1:3){for(k in 1:3){results.metrics <- rbind(results.metrics,cmToMetrics(results[[i]][[k]]))}}
rns <- NULL
for(i in 1:3){for(k in 1:3){rns <- c(rns,paste(names(events)[i],mods[k],sep="-"))}}
rownames(results.metrics) <- rns
#
rm(i,k)
rm(ctrl,cvIn, cvOut, mods,rns,rseed,results,dset,events)
