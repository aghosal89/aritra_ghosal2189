# this function computes the euclidean norm of the vector x:
e_norm <- function(x) sqrt(sum(x^2))

source("FSIDenReg.R")         ### WM
source("FSIAuxFunctions.R")   ### WM

#####################
# Building FSI model
#####################

# Set working directory~

# read the list of countries for our model~
country_<- read.csv("Countries_FSI.csv", header = T)
country_ <- country_[,2]

# read the covariate data:
X_ctr<- read.csv("X_centerscale.csv", header = T)
country_<- X_ctr[,1]
X_ctr <- X_ctr[,-1]
rownames(X_ctr) <- country_

# Read the response data as quantiles
quant_all <- read.csv("quant_all.csv", header = T)
rownames(quant_all)<- quant_all[,1]
quant_all <- quant_all[,-1]

# to find the bandwidth range for analysis~
h_max = max(apply(X_ctr, 1, e_norm))

# number of observations
n<- nrow(quant_all)

## to find the lowest possible value for bandwidth h
metric_v_temp <- matrix(NA, n ,1) 


for (j in 1:n) {
  
  mv <-matrix(NA, n ,1)   
  
  for (i in 1:n) {
    if(i!=j)
      # computing the euclidean distance between rows the standardized X matrix
      mv[i]<- e_norm(X_ctr[j,] - X_ctr[i,]) 
  }
  metric_v_temp[j] = min(mv[-j]) # taking minimum distance 
}

h_min <- min(metric_v_temp)*1.5

# the sequence of bandwidths to optimize over ~
h = exp(seq(log(h_min),log(h_max), length.out = 10))

qSup<- seq(0,1, length.out = 101)
library('numbers')

#######################################################
# Choosing bandwidth by leave-one-out Cross-Validation
#######################################################

mspe_l1ocv <- matrix(NA, length(h), 1) 

#> n  # 39

for (k in 1:length(h)) {
  
  pe_temp <- matrix(NA, n, 1)   
  
  print(k)
  for (i in 1:n) {
    print(i)
    # select the quantiles in train and test splits of fold
    q_in <- quant_all[-i,] # training split
    q_out<- quant_all[i,]  # testing split
    
    # select the covariate observations in train and test splits of fold
    x_in <- X_ctr[-i,]  # training split
    x_out<- X_ctr[i,]   # testing split
    
    # fitting frechet single index model
    tempMatrix <- FSIDenReg(as.matrix(x_in), qSup, as.matrix(q_in), h[k], 
                            kern="gauss", Xout= as.matrix(x_out), 2)
    
    # computing MSPE on out-sample
    pe_temp[i]<- fdadensity:::trapzRcpp(X = qSup, 
                                        Y = (as.vector(tempMatrix$Yout) - as.numeric(q_out))^2)
  }
  
  mspe_l1ocv[k,] <- mean(pe_temp)
}

h_fsi <- h[which.min(mspe_l1ocv)]

write.csv(h_fsi, 'FSI_bw.csv') 

write.csv(mspe_l1ocv, "FSI_MSPE_LOOCV.csv")


####################################
# Estimation of the parameter theta 
####################################


tempMatrix <- FSIDenReg(as.matrix(X_ctr), qSup, as.matrix(quant_all), 
                        h_fsi, kern="gauss", Xout= as.matrix(X_ctr), 4)

theta_hat <- tempMatrix$thetaHat

theta_hat_names = colnames(X_ctr)

write.csv(theta_hat, "Theta_Hat.csv")
write.csv(theta_hat_names, "Theta_Hat_Names.csv")

# Generation of densities & quantiles for FSI
fsi_model<- LocDenReg(xin=as.matrix(X_ctr)%*%theta_hat, qin=as.matrix(quant_all), 
                      optns= list(bwReg=h_fsi,qSup = qSup, dSup=dSup, lower=20, upper=110))

write.csv(fsi_model$dout, "FSI_Dpred.csv")
write.csv(fsi_model$qout, "FSI_Qpred.csv")

###################################
# Test-training out of sample prediction across 30 folds 
###################################

fold <- read.csv("Folds_new.csv", header = T)

mspe_kfcv <- matrix(NA, nrow(fold), 1)

pe_outfold  <- matrix(NA, nrow(fold), 1) # to store the Wn for testing set after theta optimization
pe_infold   <- matrix(NA, nrow(fold), 1)   # to store minimized Wn for training set theta optimization
thetahat_fold <- matrix(NA, nrow(fold), length(theta_hat)) # store the theta estimate for each training split


for (j in 1:nrow(fold)) {
  print(j)
  q_in <- quant_all[-as.numeric(fold[j,]),]
  q_out<- quant_all[as.numeric(fold[j,]),]
  
  x_in <- X_ctr[-as.numeric(fold[j,]),]
  x_out<- X_ctr[as.numeric(fold[j,]),]
  
  tempMatrix <- FSIDenReg(as.matrix(x_in), qSup, as.matrix(q_in), h=h_fsi, 
                          kern="gauss", Xout= as.matrix(x_out), 5)
  thetahat_fold[j, ] <- tempMatrix$thetaHat
  pe_infold[j] <- tempMatrix$fnvalue
  
  pe_outfold[j]<- mean(sapply(1:nrow(tempMatrix$Yout), 
                     function(i) fdadensity:::trapzRcpp(X= qSup, 
                                                        Y = (tempMatrix$Yout[i, ]- as.numeric(q_out[i, ]))^2)))
  
}

write.csv(pe_outfold, "FSI_MSPE_folds.csv")

