#MTL_Cox for Personalized Prediction
#Take CHD as an example
library(dplyr)
data0 <- fread("CHD_unionVars_data_std.csv") #The first three columns of data are eid, survival_time, and censored_indicators.
data0<-data0[,-1]
beta <- read_xlsx("MTL_beta.xlsx",sheet = "BETA") #There are three columns of data, the first column is the variable ordinal number sorted in ascending order, named "Num". The second column is the diseases ordinal number, named "dis". The third column is the beta value, named "beta".
beta <- beta[which(beta$dis==1),]
var_number<- beta$Num
var_number <- as.vector(var_number+3)

risk_quantile <- as.data.frame(matrix(NA,4,3))
MTL_beta <- as.matrix(beta$beta)
data <- data0[order(data0$survtime),]
dt <- as.numeric(data$survtime)
MTL_HH <- as.data.frame(data$eid)

m <- 1
for (t in c(1,3,5,7)) {
  k <- length(which(dt < as.vector(t %*% 365)))
  MTL_eXB <- exp(data.matrix(data[,-c(1:3)]) %*% MTL_beta)
  h <- rep(0,k)
  for (i in 1:k) {
    h[i] <- sum((data$survtime == dt[i]) & (data$I20to25 == 1))/sum(MTL_eXB[data$survtime >= dt[i]])
  }
  MTL_H0 <- sum(h)
  MTL_S0 <- exp(-MTL_H0)
  MTL_S <- MTL_S0 ^ MTL_eXB
  MTL_H <- 1-MTL_S
  MTL_H <-as.data.frame(MTL_H)
  MTL_HH <- cbind(MTL_HH,MTL_H)
  risk_quantile[m,] <- quantile(MTL_HH[,m+1],na.rm = T,probs = c(0.33,0.5,0.66))
  m <- m+1
}

names(MTL_HH)[1] <- "eid"
names(MTL_HH)[c(2,3,4,5)] <- c("t1_CHD","t3_CHD","t5_CHD","t7_CHD")
names(risk_quantile)[1:3] <- c("Low risk","Average risk", "High risk")

MTL_HH_allDiseases <- inner_join(MTL_HH_allDiseases,MTL_HH,by="eid")
load("varsdata.RData")
MTL_allDiseases <- left_join(MTL_HH_allDiseases,data[,c("eid","age")],by="eid")

#------------



#RAR=AR1/AR0
library(data.table)
library(readxl)
AR <- fread("MTL_allDiseases.csv")
AR$age1 <- cut(AR$age, breaks = c(0,39,49,59,69,100),labels=c(1,2,3,4,5))
cut_line <- fread("lowAvgHigh.csv")
cut_line <- as.data.frame(cut_line)
RAR <- AR
RAR$age1 <- as.numeric(as.factor(RAR$age1))
RAR <- as.data.frame(RAR)
for (j in 1:5) {
  for (i in 2:37) {
    RAR[which(RAR$age1==cut_line[j,1]),i] <- RAR[which(RAR$age1==cut_line[j,1]),i]/cut_line[1,i]
  }
}

#EAR=AR1-AR0
EAR <- AR
EAR$age1 <- as.numeric(as.factor(EAR$age1))
EAR <- as.data.frame(EAR)
for (j in 1:5) {
  for (i in 2:37) {
    EAR[which(EAR$age1==cut_line[j,1]),i] <- EAR[which(EAR$age1==cut_line[j,1]),i]-cut_line[1,i]
  }
}