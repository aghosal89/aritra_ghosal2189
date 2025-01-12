
1) Download all the files from the folder 'Mortality_analysis' into a folder in your computer and set it as the working directory for operation in R/RStudio.

    * List of countries: The file 'Countries_FSI.csv' contains the list of 39 countries considered in the mortality analysis.
    * Generation of Covariates: For reproducibility we provide standardized covariate data used in the model for 2013 in the file 'X_centerscale.csv'. For the latest raw data we refer the reader to original sources listed below. The file 'X_centerscale.csv' was created using the script 'Covariate_generation.csv'. In the output file 'X_centerscale.csv', the covariates appear in the following order:
         
         
         i.  GDP year-on-year % change: download link: https://data.worldbank.org/indicator/NY.GDP.MKTP.KD.ZG.
         
         ii. Current healthcare expenditure % GDP: download link: https://data.worldbank.org/indicator/SH.XPD.CHEX.GD.ZS .
         
         iii.Carbon-dioxide emission in metric tonnes per capita: download link: https://data.worldbank.org/indicator/EN.ATM.CO2E.PC?name_desc=false.
         
         iv. Infant mortality per 1000 live births: download link: https://childmortality.org/data.
         
         v.  Human Development Index: download link: https://hdr.undp.org/data-center/documentation-and-downloads.
         
      The script 'Covariate_generation.R' uses as inputs the files 'Countries_FSI.csv' and other .csv files downloaded from the links above (the names of the raw datasets used are mentioned in the code). The covariate data were downloaded on September 12, 2022. The covariates in the data above are referred to as 'GDPC', 'HCE', 'CO2E', 'IM' and 'HDI' respectively for analyses. 
      
         - The code calls for the raw datasets in .csv format the files 'API_NY.GDP.MKTP.KD.ZG_DS2_en_csv_v2_4498512.csv' for GDP year-on-year % change, for 'API_SH.XPD.CHEX.GD.ZS_DS2_en_csv_v2_4499032.csv' for Current Healthcare expenditure % GDP, 'API_EN.ATM.CO2E.PC_DS2_en_csv_v2_4498382.csv' for CO2 emission in metric tonnes per capita. These datasets were extracted from the zip folders downloaded from their respective world bank websites mentioned above. The datasets were further cleaned by removing some rows before using for our analysis. The script also calls for 'UNICEF-CME_DF_2021_WQ-1.0-download.csv' for Infant Mortality per 1000 live births and 'HDR21-22_Composite_indices_complete_time_series.csv' for Human Development Index. These two datasets were directly downloaded from their respective websites.
      
    
   * Generation of Response data: The age-at-death data used to create the pdfs and quantiles for 39 countries were downloaded from https://www.mortality.org/ on August 18, 2020. The code in the script 'Response_generation_new.csv' file was used to construct the output files 'quant_all.csv' and 'density_all.csv' which are both 39x101 data frames whose rows represent the countries in the file 'Countries_FSI.csv', the columns of 'density_all.csv' represent the equidistant points on the support [20,110] for mortality distributions, the colmns of 'quant_all.csv' represent an equidistant quantile grid on [0,1]. For reproducibility we provide quant_all.csv and density_all.csv files. Due to mortality.org data usage policies, we refer the reader to https://www.mortality.org/ for the latest raw data.
   
      - The code calls for the raw data on life tables, e.g. for Belarus, the life table is obtained by downloading life tables for Belarus for both sexes by period, using 1 year increments in age, for one year 2013, and then we removed the data for the rest of the years and made it available as 'lt_belarus.csv' which is then read into 'Response_generation_new.csv' for further analysis.


2) Run the codes in the script 'Models_BW_Predictions.R' to find the predicted quantiles/densities for all countries using Local Frechet regression using each of the covariates 'GDPC', 'HCE', 'CO2E', 'IM', 'HDI'; and also running Global Fréchet regression using all of these 5 covariates. Our code for fitting the FSI model starts with leave-one-out cross-validation to find the best bandwidth, followed by estimation of the index parameter. Subsequently the Mean Square Prediction Error is calculated for each of the 30 folds, and then averaged. To calculate the FSI model results, run the codes in the script 'FSI_model.R', which works by sourcing the functions from the following scripts in your working directory:

    a) X_centerscale.csv
    b) quant_all.csv

The outputs are:

    a) LF_GDPC_BW.csv    : contains the chosen bandwidth for the covariate GDPC.
    b) LF_GDPC_Qpred.csv : contains the Local Frechet regression predicted quantiles for 2013 for all countries using GDPC as the covariate.
    c) LF_GDPC_Dpred.csv : contains the Local Frechet regression predicted densities for 2013 for all countries using GDPC as the covariate.
    
    d) LF_HCE_BW.csv    : contains the chosen bandwidth for the covariate HCE.
    e) LF_HCE_Qpred.csv : contains the Local Frechet regression predicted quantiles for 2013 for all countries using HCE as the covariate.
    f) LF_HCE_Dpred.csv : contains the Local Frechet regression predicted densities for 2013 for all countries using HCE as the covariate.
    
    g) LF_CO2E_BW.csv    : contains the chosen bandwidth for the covariate CO2E.
    h) LF_CO2E_Qpred.csv : contains the Local Frechet regression predicted quantiles for 2013 for all countries using CO2E as the covariate.
    i) LF_CO2E_Dpred.csv : contains the Local Frechet regression predicted densities for 2013 for all countries using CO2E as the covariate.
    
    j) LF_IM_BW.csv    : contains the chosen bandwidth for the covariate IM.
    k) LF_IM_Qpred.csv : contains the Local Frechet regression predicted quantiles for 2013 for all countries using IM as the covariate.
    l) LF_IM_Dpred.csv : contains the Local Frechet regression predicted densities for 2013 for all countries using IM as the covariate.
    
    m) LF_HDI_BW.csv    : contains the chosen bandwidth for the covariate HDI.
    n) LF_HDI_Qpred.csv : contains the Local Frechet regression predicted quantiles for 2013 for all countries using HDI as the covariate.
    o) LF_HDI_Dpred.csv : contains the Local Frechet regression predicted densities for 2013 for all countries using HDI as the covariate.
    
    p) GF_Qpred.csv  : contains the Global Frechet regression predicted quantiles for 2013 for all countries using all the covariates.
    q) GF_Dpred.csv  : contains the Global Frechet regression predicted densities for 2013 for all countries using all the covariates.
    

3) Run the codes in the script 'CV_folds_analysis.R'. To understand performance of the models better, we split the data into training/testing segments in 30 folds. The training split consists of 29 observation while testing split consists of 10 observations in each fold. The splits of 30 folds were picked randomly without replacement and stored in 'Folds_new.csv' file to be used for all models repeatedly. Then the respective Local Fréchet and Global Fréchet models were built on each of the the training splits and each trained model was then used for prediction on the corresponding testing set. The Mean Square Prediction Error (MSPE) is calculated for each of the testing sets, and also average MSPE was calculated (averaging the MSPE values across the 30 testing sets). The best bandwidths obtained by running the script 'Models_BW_Predictions.R' are used here. The inputs are:

    
    a) X_centerscale.csv
    
    b) quant_all.csv
    
    c) Folds_new.csv 
    
    d) LF_GDPC_BW.csv
    
    e) LF_HCE_BW.csv
    
    f) LF_CO2E_BW.csv
    
    g) LF_IM_BW.csv
    
    h) LF_HDI_BW.csv
    
    
To run the codes source the function from the script 'LocWassRegAMP.R'.

The outputs: each file below contains 30x1 matrix whose elements are the Mean Square Prediction Error for the models in the 30 folds.

    a) GF_folds.csv       : MSPE for Global Frechet using all covariates in 30 folds.
    
    b) LF_GDPC_folds.csv  : MSPE for Local Frechet using GDPC in 30 folds.
    
    c) LF_HCE_folds.csv   : MSPE for Local Frechet using HCE in 30 folds.
    
    d) LF_CO2E_folds.csv  : MSPE for Local Frechet using CO2E in 30 folds.
    
    e) LF_IM_folds.csv    : MSPE for Local Frechet using IM in 30 folds.
    
    f) LF_HDI_folds.csv   : MSPE for Local Frechet using HDI in 30 folds.

4) Our code for fitting the FSI model starts with leave-one-out cross-validation to find the best bandwidth, followed by estimation of the index parameter. Subsequently the Mean Square Prediction Error is calculated for each of the 30 folds, and then averaged.  To calculate the FSI model results, run the codes in the script 'FSI_model.R', which works by sourcing the functions from the following scripts in your working directory:

    a) FSIAuxFunctions.R
    
    b) FSIDenReg.R
    
    c) LocWassRegAMP.R

The FSI_model.R script takes as inputs the following files: 

    1. X_centerscale.csv
    
    2. quant_all.csv
    
    3. Countries_FSI.csv
    
The outputs:

    1. FSI_bw.csv       : the best chosen bandwidth for FSI model.
    
    2. Theta_Hat.csv    : Estimate of the index parameter using the best bandwidth above.
    
    3. FSI_Qpred.csv    : Predicted quantiles by FSI model by best bandwidth and estimated index parameter above. 
    
    4. FSI_Dpred.csv    : Predicted densities by FSI model by best bandwidth and estimated index parameter above.
    
    5. FSI_MSPE_folds.csv : Mean Square Prediction Error in 30 folds by the FSI model using the best bandwidth above. 

5) To run the computations for the table 3 in the paper run the codes in the script 'Table3_computation.R'. It sources the function 'frechet_Rsquared.R'. The inputs are:

    1. Countries_FSI.csv
    2. X_centerscale.csv
    3. quant_all.csv
    
    4. LF_HDI_BW.csv
    5. LF_HCE_BW.csv
    6. LF_GDPC_BW.csv
    7. LF_IM_BW.csv
    8. LF_CO2E_BW.csv
    9. FSI_bw.csv
    10. Theta_Hat.csv
    
    11. GF_folds.csv
    12. LF_HDI_folds.csv
    13. LF_HCE_folds.csv
    14. LF_GDPC_folds.csv
    15. LF_IM_folds.csv
    16. LF_CO2E_folds.csv

    17. FSI_MSPE_folds.csv

Outputs: This script does not produce outputs to be saved for further use. It is used to compute the numbers in table 3 of the paper. 

6) To generate the figures 4 - 7 in the paper run the codes in the script 'Plots_new.R'. The following are the inputs:

    a) density_all.csv
    
    b) GF_Dpred.csv
    
    c) LF_HDI_Dpred.csv
    
    d) FSI_Dpred.csv
    
    e) MSPE_folds.csv
    
    f) LF_HDI_folds.csv
    
    g) LF_HCE_folds.csv
    
    h) FSI_MSPE_folds.csv
    
    i) GF_folds.csv
    
    j) X_centerscale.csv
    
    j) quant_all.csv
    
    k) Theta_Hat.csv
    
    l) FSI_bw.csv
    

7)  To prepare a similar file as Folds_new.csv, run the codes in the script Folds_generate.csv. The test/train partition of folds will not be identical to
    the one used in our analysis. As output it produces:
    
    Folds_new.csv
