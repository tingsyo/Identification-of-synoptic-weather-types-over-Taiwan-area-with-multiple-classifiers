# Train with 2001~2010 data, and label 1979~2010
require(caret)
require(kernlab)
rseed <- 5432123
# Load dataframe
load("ncep.svd20.1979.RData")
# train model
set.seed(rseed)
fit.front <- train(factor(event)~., data=df.front, method="svmRadial")
set.seed(rseed)
fit.typhoon <- train(factor(event)~., data=df.typhoon, method="svmRadial")
set.seed(rseed)
fit.hr <- train(factor(event)~., data=df.heavyrain, method="svmRadial")
# label past data
pred.front <- predict(fit.front, newdata=nc1979.test)
pred.typhoon <- predict(fit.typhoon, newdata=nc1979.test)
pred.hr <- predict(fit.hr, newdata=nc1979.test)
#

