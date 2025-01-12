
## This script contains the codes to generate figures 4 - 7 in the paper. 

# load necessary libraries 
library('frechet')
library('ggplot2')

## You need csv files created by "Table3_computation.R" for Fig 6/9,
## so rerunning here in case not previously done.

source("Table3_computation.R")

################################################
## Codes for producing figure 4 in the document
################################################

# plot all densities with highest six and lowest six density-modes

# This function computes the mode age of the mortality density over a grid
# Inputs:  1) dSup     : An equispaced grid of points of length m on the support of densities
#          2) densities: matrix of dimension rxm, each row represents a density on dSup. Total r densities.
# Outputs: a numeric vector of length r of modes of the r densities in the respective order.

mode_ages <- function(dSup, densities) {
  r<- nrow(densities)
  modes <- matrix(0, r,1)
  for (j in 1:r) {
    modes[j] <- dSup[which.max(densities[j,])]
  }
  return(modes)
}

# read the mortality densities of all countries
density_all<- read.csv("density_all.csv", header= T)
country_ <- density_all[,1]
rownames(density_all) <- country_
density_all <- as.matrix(density_all[,-1])

# length of support for densities/quantiles
m<- ncol(density_all)

# number of countries under study
n<- nrow(density_all)

# equidistant grid for densities 
dSup <- seq(20, 110, length.out= m)

# equidistant grid for quantiles 
qSup <- seq(0, 1, length.out = m)

# Compute the models of all countries
mdf<- data.frame(Sequence=seq(1:length(country_)), Country=country_, Mode_Age=mode_ages(dSup, density_all))

# 6 countries with lowest life expectancy 
head(mdf[order(mdf$Mode_Age),]) 

# 6 countries with highest life expectancy 
head(mdf[order(-mdf$Mode_Age),]) 


# create the plot

png(file = "Rplot_density_all_r1.png", height = 433, width = 615)

ind_ls<- list()
ind_ls<- list(Blank=c(2,3,8,9,10,11,13,14,16,17,18,20,21,22,23,25,26,27,29,30,31,32,33,36,37,39),
              Red = c(4,5,19,34,35,38), Blue = c(1,6,7,12,15,24))

plot(dSup, density_all[2,],lwd=2, xlab='Age', ylab='Density', type='l',col='lightgrey', 
     ylim = c(0, 0.045))
for (j in ind_ls$Blank) {
  lines(dSup, density_all[j,],lwd=2, xlab='Age', ylab='Density', type='l',col='lightgrey')
}

for (j in ind_ls$Red) {
  lines(dSup, density_all[j,], 
        xlab='Age', ylab='Density', type='l', lwd=2, col=rgb(red = 1, green=0, blue = 0, alpha = 0.5))
}

for (j in ind_ls$Blue) {
  lines(dSup, density_all[j,], 
        xlab='Age', ylab='Density', type='l', lwd=2, col=rgb(red = 0, green=0, blue = 1, alpha = 0.5))
}

# Add a legend to the plot
legend(20, 0.045, legend=c("Bottom 6", "Top 6"),
       col=c("red", "blue"), lty=c(1,1), cex=1.2,
       title="Modes of distribution", text.font=10, bg='lightblue')
grid(nx = NULL, ny = NULL, col = "lightgray", lty = "dotted",
     lwd = par("lwd"), equilogs = TRUE)

dev.off()


################################################
## Codes for producing figure 5 in the document
################################################


# read predicted densities from Global Frechet regression
gf_dpred<- read.csv("GF_Dpred.csv", header = T)[,-1]

# read predicted densities from Local Frechet regression with HDI covariate
lf_hdi_dpred <- read.csv("LF_HDI_Dpred.csv", header = T)[,-1]

# read predicted densities from Frechet Single index regression model 
fsi_dpred <- read.csv("FSI_Dpred.csv", header = T)[,-1]


# create the dataset for the plot
df_gf<- data.frame(Age=rep(dSup, n), Method=rep("Global Frechet", n*m), 
                   Density=as.vector(t(gf_dpred)), 
                   Country=rep(country_, each=m), 
                   Mode_Age= rep(mode_ages(dSup, gf_dpred), each=m))

df_lf_hdi<- data.frame(Age=rep(dSup, n), Method=rep("LF:HDI", n*m), 
                       Density=as.vector(t(lf_hdi_dpred)), 
                       Country=rep(country_, each=m), 
                       Mode_Age= rep(mode_ages(dSup, lf_hdi_dpred), each=m))

df_fsi <-data.frame(Age=rep(dSup, n), Method=rep("FSI", n*m), 
                    Density=as.vector(t(fsi_dpred)), 
                    Country=rep(country_, each=m), 
                    Mode_Age= rep(mode_ages(dSup,fsi_dpred), each=m))

df_all_actual <- data.frame(Age=rep(dSup, n), Method= rep('Actual Mortality', n*m), 
                            Density = as.vector(t(as.matrix(density_all))), 
                            Country=rep(country_,each=m), 
                            Mode_Age=rep(mode_ages(dSup,as.matrix(density_all)),each=m))

df_pred_plot<- rbind(df_all_actual, df_gf, df_lf_hdi, df_fsi)

ggplot(data = df_pred_plot, aes(x=Age, y=Density, fill=Country )) +
  geom_path(aes(colour=(Mode_Age)), size=.6, alpha=1) +
  facet_wrap(~Method)+
  #ggtitle("Mortality distributions of 2013") +
  scale_color_gradientn(colours = terrain.colors(10)) +
  labs(colour = "Mode Age")+
  theme(text=element_text(size=20))

ggsave(file="Rplot_models_predictions_r1.eps")



################################################
## Codes for producing figure 6 in the document
################################################

df_mspe_fold <- read.csv("MSPE_folds.csv", header = T)[,-1]

df_mspe_fold$Model <- factor(df_mspe_fold$Model, 
                             levels=c("GF", "LF(HDI)", "LF(HCE)", "LF(GDPC)", "LF(IM)", "LF(CO2E)", "FSI"))
df_mspe_fold$log.MSPE <- log(df_mspe_fold$MSPE)

setEPS()
postscript(file = "Rplot_mpse_models_compare_log_r1.eps", width = 8, height = 5, paper = 'special')
my.bp <- ggplot(data =df_mspe_fold) + 
  geom_boxplot(aes(y=log.MSPE, x=Model, fill=Model), size = 0.3, outlier.size = 0.4) + 
  ylab('log MSPE') + 
  scale_fill_manual(values=c("red3",
                             "purple3",
                             "green3",
                             "pink3",
                             "skyblue2",
                             "grey",
                             "yellow3")) + 
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  theme(axis.text.y=element_text(size=16),
        axis.title.y=element_text(size=18),
        legend.text=element_text(size=18),
        legend.title=element_text(size=18))
my.bp
dev.off()
#ggsave(file="Rplot_mspe_models_compare_log_r1.eps")


# plots to compare MSPE of LF(HDI) FSI
lf_hdi_folds <- read.csv("LF_HDI_folds.csv", header= T)
lf_hce_folds <- read.csv("LF_HCE_folds.csv", header=T)
fsi_folds <- read.csv("FSI_MSPE_folds.csv", header = T)
gf_folds<- read.csv("GF_folds.csv", header = T)
#mvlf_folds<- read.csv("MvLF_MSPE_folds.csv", header=T)

hdi_fsi_ratio_log <- log(lf_hdi_folds[,2]/fsi_folds[,2])
hce_fsi_ratio_log <- log(lf_hce_folds[,2]/fsi_folds[,2])
gf_fsi_ratio_log <- log(gf_folds[,2]/fsi_folds[,2])

log_ratio_df <- rbind(data.frame(Comparison = "LF(HDI):FSI",MSPE.Ratio = hdi_fsi_ratio_log),
                      data.frame(Comparison = "LF(HCE):FSI", MSPE.Ratio = hce_fsi_ratio_log),
                      data.frame(Comparison = "GF:FSI", MSPE.Ratio = gf_fsi_ratio_log))

postscript(file = "Rplot_mspe_compare_hdi_hce_fsi_r1.eps", width = 4, height = 5, paper = 'special')
my.bp1 <- ggplot(data = log_ratio_df) + 
  geom_boxplot(aes(y=MSPE.Ratio, x=Comparison, fill= Comparison), size = 0.3, outlier.size = 0.4) + 
  ylab('log Ratio') + 
  scale_fill_manual(values=c("red3",
                             "green3",
                             "purple3")) + 
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) + 
  geom_hline(yintercept = 0, linetype="dashed") +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  theme(axis.text.y=element_text(size=16),
        axis.title.y=element_text(size=18),
        legend.text=element_text(size=18),
        legend.title=element_text(size=18))
my.bp1
dev.off()
#ggsave(file="Rplot_mspe_compare_hdi_hce_fsi_r1.eps")





#################################################
## Codes for producing figure 7 in the document
#################################################


# read the covariate data for all countries
X_ctr<- read.csv("X_centerscale.csv", header = T)
country_<- X_ctr[,1]
X_ctr <- X_ctr[,-1]
rownames(X_ctr)<- country_

# Read the response data as quantiles
quant_all <- read.csv("quant_all.csv", header = T)
rownames(quant_all)<- quant_all[,1]
quant_all <- quant_all[,-1]

# creating effects plot for HDI:
l= seq(min(X_ctr[,'HDI']), max(X_ctr[,'HDI']), length.out= 100)
covar_median_hdi_effect<- matrix(0, length(l), 5)
medn=apply(X_ctr, 2, median)

thetahat <- read.csv('Theta_Hat.csv', header = T)
thetahat<- t(thetahat[,2])

h_fsi <- read.csv("FSI_bw.csv", header = T)[,2]

covar_median_hdi_effect<- cbind(GDP_yoy=rep(medn[1],100), HC_exp=rep(medn[2],100), 
                                CO2emission=rep(medn[3],100), Infantm=rep(medn[4],100))
ef_hdi<-cbind(covar_median_hdi_effect, HDI=l)
ef_hdi<- ef_hdi%*%t(thetahat)

X_ctr <- as.matrix(X_ctr)
colnames(X_ctr) <- c('GDPC', 'HCE', 'CO2E', 'IM', 'HDI')

temp_hdi_effect<- LocDenReg(xin= X_ctr%*%t(thetahat), qin=as.matrix(quant_all), 
                            xout=as.matrix(ef_hdi,n,1),
                            optns=list(bwReg= h_fsi, qSup=qSup, 
                                       dSup=dSup,lower=20, upper=110))

hdi_effect_data<- data.frame(Age=rep(dSup, 100), HDI.group=rep(factor(1:100),each=m),Density=as.vector(t(temp_hdi_effect$dout)),
                             HDI= rep(l, each=m))

ggplot(data = hdi_effect_data, aes(x=Age, y=Density, fill=HDI.group)) +
  geom_path(aes(colour=(HDI)), size=.9, alpha=1) +
  #ggtitle("Mortality Distributions Variation by partial HDI effect") +
  scale_color_gradientn(colours = terrain.colors(10)) +
  labs(colour = "Standard HDI") +
  theme(axis.text=element_text(size=18),
        axis.title=element_text(size=18)) +
  theme(text=element_text(size=18))

ggsave(file="Rplot_HDI_effect_r1.eps")



# creating effects plot for HCE, healthcare expenditure:
l= seq(min(X_ctr[,'HCE']), max(X_ctr[,'HCE']), length.out= 100)
covar_median_hcexp_effect<- matrix(0, length(l), 5)
medn=apply(X_ctr, 2, median)

covar_median_hce_effect<- cbind(GDP_yoy=rep(medn[1],100), 
                                CO2emission=rep(medn[3],100), Infantm=rep(medn[4],100), HDI=rep(medn[5],100))
ef_hce<-cbind(covar_median_hce_effect, HCE=l)
ef_hce<- ef_hce%*%t(thetahat)


temp_hce_effect<- LocDenReg(xin= X_ctr%*%t(thetahat), qin=as.matrix(quant_all), 
                            xout=as.matrix(ef_hce,n,1),
                            optns=list(bwReg= h_fsi, qSup=qSup, 
                                       dSup=dSup,lower=20, upper=110))

hce_effect_data<- data.frame(Age=rep(dSup, 100), HCE.group=rep(factor(1:100),each=m),Density=as.vector(t(temp_hce_effect$dout)),
                             HCE= rep(l, each=m))

ggplot(data = hce_effect_data, aes(x=Age, y=Density, fill=HCE.group)) +
  geom_path(aes(colour=(HCE)), size=.9, alpha=1) +
  #ggtitle("Mortality Distributions Variation by partial HCE effect") +
  scale_color_gradientn(colours = terrain.colors(10)) +
  labs(colour = "Standard HCE") +
  theme(axis.text=element_text(size=18),
        axis.title=element_text(size=18)) +
  theme(text=element_text(size=18))

ggsave(file="Rplot_HCE_effect_r1.eps")
