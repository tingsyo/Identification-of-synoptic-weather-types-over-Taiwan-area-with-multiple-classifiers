# Run experiemnts on various events
require(caret)
require(gbm)
require(kernlab)
load("exp.b850.20170101.rdata")
#source("../reporting/confusionMatrixToMetrics.r")
#options(error=recover)
# Experiment settings
rseed <- 5432123
evtypes <- colnames(events)
exps <- c("cwbs","ec20","ec10","ncep20","ncep10","ecncep20","ecncep10")
mods <- c("glm","gbm","svm")
results <- NULL
# Loop through events
for(ev in 1:length(evtypes)){
  print(evtypes[ev])
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
  dfs <- c(dfs, list(cbind(events[,ev], input.cwbs)))
  dfs <- c(dfs, list(cbind(events[,ev], ec.svd20)))
  dfs <- c(dfs, list(cbind(events[,ev], ec.svd10)))
  dfs <- c(dfs, list(cbind(events[,ev], ncep.svd20)))
  dfs <- c(dfs, list(cbind(events[,ev], ncep.svd10)))
  dfs <- c(dfs, list(cbind(events[,ev], "ec"=ec.svd20, "ncep"=ncep.svd20)))
  dfs <- c(dfs, list(cbind(events[,ev], "ec"=ec.svd10, "ncep"=ncep.svd10)))
  # Loop through datasets
  cmsByDataset <- NULL
  for(i in 1:length(dfs)){
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
names(results) <- names(events)[1:3]
rm(ev, i)
# Convert results to metrics
results.metrics <- NULL
for(i in 1:5){
    for(j in 1:7){
        for(k in 1:3){
            newrow <- c("event"=evtypes[i], "data"=exps[j], "model"=mods[k]
                        ,cmToMetrics(results[[i]][[j]][[k]]))
            results.metrics <- rbind(results.metrics, newrow)
        }
    }
}
rns <- NULL
for(i in 1:5){
    for(j in 1:7){
        for(k in 1:3){
            rns <- c(rns,paste(colnames(events)[i],exps[j],mods[k],sep="-"))
        }
    }
}
rownames(results.metrics) <- rns
#
rm(i,j,k)
# output
write.csv(results.metrics, file="result.20170101.csv")
q(save="yes")

