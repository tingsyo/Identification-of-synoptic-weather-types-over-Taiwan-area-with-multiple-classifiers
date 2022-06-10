#=======================================================================
# File: wc04.evaluate.model.r
# Purpose:
#   Read in tidy data and perform the evaluation of model. 
#=======================================================================
# Parameters
source("wc00.parameters.r")
#=======================================================================
# Functions
#=======================================================================

evaluate.models <- function(df, rseed=54321, cv=10){
  require(caret)
  require(e1071)
  require(kernlab)
  # Create cross validation folds
  set.seed(rseed)
  cvOut <- createFolds(df$event, k=cv)
  cvIn <- cvOut
  for(i in 1:10){
    cvIn[[i]] <- (1:length(df$event))[-cvOut[[i]]]
  }
  ctrl <- trainControl(method="cv", index=cvIn, indexOut=cvOut)
  #
  fit.glm <- train(factor(event)~., data=df, method="glm", family="binomial", trControl=ctrl)
  set.seed(rseed)
  fit.svm <- train(factor(event)~., data=df, method="svmRadial", trControl=ctrl)
  # Evaluation metrics
  cm.glm <- confusionMatrix.train(fit.glm)$table
  cm.svm <- confusionMatrix.train(fit.svm)$table
  metrics <- rbind(cmToMetrics(cm.glm),cmToMetrics(cm.svm))
  row.names(metrics) <- c("GLM","SVM")
  #
  return(list("model"=list("glm"=fit.glm,"svm"=fit.svm),
              "table"=list("glm"=confusionMatrix(fit.glm),"svm"=confusionMatrix(fit.svm)),
              "metrics"=metrics))
}


# Create folds for cross validation
makeFolds <- function(y, nfold=10, rseed=54321){
  # Reordering
  set.seed(rseed)
  ev1s <- sample(which(y==1))
  ev0s <- sample(which(y==0))
  #print(paste("Index 1s:", ev1s))
  #print(paste("Index 0s:", ev0s))
  # Subsetting
  n1s <- length(ev1s)
  n0s <- length(ev0s)
  #print(paste("number of 1s:", n1s,", number of 0s:",n0s))
  inc1 <- as.integer(n1s/nfold)
  inc0 <- as.integer(n0s/nfold)
  #print(paste("Inc of 1s:", inc1,", inc of 0s:",inc0))
  fidx <- NULL
  for(i in 1:nfold){
    sidx1 <- (i-1)*inc1+1    # starting index for 1s
    sidx0 <- (i-1)*inc0+1    # starting index for 0s
    #print(paste("sidx1:", sidx1,", sidx0:", sidx0))
    # Add based index
    idx <- c(ev1s[sidx1:(sidx1+inc1-1)], ev0s[sidx0:(sidx0+inc0-1)])
    # Add remained index
    if(i <= n1s%%nfold){idx <- c(idx,ev1s[n1s-i+1])}
    if(i <= n0s%%nfold){idx <- c(idx,ev0s[n0s-i+1])}
    # Aggregate all samples
    fidx <- c(fidx, list(idx))
  }
  return(fidx)
}

# Create confusion matrix
makeCM <- function(pred, ref){
  return(table(pred, ref))
}

# Calculate various metrics from confusion matrix
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
#=======================================================================
# Script commands
#=======================================================================
df <- read.csv(IODATA, stringsAsFactors=F, row.names=1)
results <- evaluate.models(df, rseed=rseed, cv=10)
print(results$table)
print(results$metrics)
write.csv(results$metrics, file=METRIC_FILE)
save(results, file=MODEL_FILE)
