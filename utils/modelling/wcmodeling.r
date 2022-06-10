# Run experiemnts on various events
require(caret)
require(gbm)
require(kernlab)
#options(error=recover)
# Experiment settings
rseed <- 5432123
exps <- c("cwbs","ec20","ec10","ncep20","ncep10","ecncep20","ecncep10")
mods <- c("glm","gbm","svm")
results <- NULL
# Loop through events
for(ev in 1:6){
  print(names(events)[ev])
  # Create CV folds
  set.seed(777)
  cvOut <- createFolds(events[,ev], k=10)
  cvIn <- cvOut
  for(i in 1:10){
    cvIn[[i]] <- (1:length(events[,ev]))[-cvOut[[i]]]
  }
  ctrl <- trainControl(method="cv", index=cvIn, indexOut=cvOut)
  #ctrl <- trainControl(method="cv", number=10)
  # Create tmp datasets
  dfs <- NULL
  dfs <- c(dfs, list(cbind(events[,ev], cwbsuv)))
  dfs <- c(dfs, list(cbind(events[,ev], ecsvd20)))
  dfs <- c(dfs, list(cbind(events[,ev], ecsvd10)))
  dfs <- c(dfs, list(cbind(events[,ev], ncepsvd20)))
  dfs <- c(dfs, list(cbind(events[,ev], ncepsvd10)))
  dfs <- c(dfs, list(cbind(events[,ev], "ec"=ecsvd20, "ncep"=ncepsvd20)))
  dfs <- c(dfs, list(cbind(events[,ev], "ec"=ecsvd10, "ncep"=ncepsvd10)))
  # Loop through datasets
  cmsByDataset <- NULL
  for(i in 1:7){
    print(paste("dataset:",exps[i],"..."))
    dset <- dfs[[i]]
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
    #
    cmsByDataset <- c(cmsByDataset, list(cms))
    rm(fit.glm, fit.gbm, fit.svmr)
  }
  # Aggregate results
  names(cmsByDataset) <- exps
  results <- c(results, list(cmsByDataset))
  rm(dfs, cms, cmsByDataset)
}
names(results) <- names(events)
rm(ev, i)
# Convert results to metrics
results.metrics <- NULL
for(i in 1:6){for(j in 1:7){for(k in 1:3){results.metrics <- rbind(results.metrics,cmToMetrics(results[[i]][[j]][[k]]))}}}
rns <- NULL
for(i in 1:6){for(j in 1:7){for(k in 1:3){rns <- c(rns,paste(names(events)[i],exps[j],mods[k],sep="-"))}}}
colnames(results.metrics) <- rns
#
rm(i,j,k)
