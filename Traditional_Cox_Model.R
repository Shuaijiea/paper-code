# Traditional Cox model
#---------
rm(list = ls())
load("/lung_data.RData")
set.seed(1234)
require(caret)
folds <- createFolds(y=lung_data$C34,k=5)

c <- as.data.frame(matrix(NA,5,2))
AUC <- as.data.frame(matrix(NA,5,2))
CI <- as.data.frame(matrix(NA,5,6))
cuttime <-1825

VarNames <- colnames(lung_data)
FML <- as.formula(paste0("Surv(survtime, C34) ~ ",paste0(VarNames[-c(1:3)], collapse = "+")))


for(i in 1:5){
  fold_test <- as.data.frame(lung_data[folds[[i]],])   
  fold_train <- as.data.frame(lung_data[-folds[[i]],])   
  
  coxcph_train <- coxph(FML, data = fold_train,x=T)
  c[i,1] <- concordance(coxcph_train)[["concordance"]]
  c[i,2] <-concordance(coxcph_train, newdata=fold_test)[["concordance"]]
  
  # AUC
  H0<-basehaz(coxcph_train, centered=T)
  so <- as.data.frame(H0)
  so$SO <- exp(-H0)
  t <- 5
  fold_train$year5 <- ifelse(fold_train$C34==1 & fold_train$survtime<=as.vector(t %*% 365),1,0)
  fold_train$pre1 <- predict(coxcph_train,type="lp",data=fold_train)
  b <- which(abs(H0$time-cuttime)==min(abs(H0$time-cuttime)))
  fold_train$Ht <- 1-exp(-H0[b,1])^exp(fold_train$pre1)
  
  fold_test$year5 <- ifelse(fold_test$C34==1 & fold_test$survtime<=as.vector(t %*% 365),1,0)
  fold_test$pre1 <-  predict(coxcph_train,type="lp",newdata=fold_test)###
  b <- which(abs(H0$time-cuttime)==min(abs(H0$time-cuttime)))
  fold_test$Ht <- 1-exp(-H0[b,1])^exp(fold_test$pre1)
  
  ares.coxs2 <- roc(fold_train$year5,fold_train$Ht,plot=TRUE,legacy.axes=T,print.thres=T,print.auc=T)
  plot(ares.coxs2)
  AUC[i,1] <- as.numeric(ares.coxs2[["auc"]])
  CI[i,1:3] <- as.numeric(ci(ares.coxs2))
  ares.coxs2 <- roc(fold_test$year5,fold_test$Ht,plot=TRUE,legacy.axes=T,print.thres=T,print.auc=T)
  plot(ares.coxs2)
  AUC[i,2] <- as.numeric(ares.coxs2[["auc"]])
  CI[i,4:6] <- as.numeric(ci(ares.coxs2))

  
}
