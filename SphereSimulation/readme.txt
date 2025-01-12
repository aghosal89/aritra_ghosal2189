This folder contains various m files necessary to reproduce the simulation results of the paper
"Fréchet Single Index Models for Object Response Regression" by Ghosal, Meiring, and Petersen.
The main file is "get_sphere_fit_FSI.m" which produces the desired FSI estimates for a
given data set consisting of pairs (X_i, Y_i), with Y_i being an element of the
two-dimensional sphere.  Multivariate local Fréchet regression is also implemented
in the file "get_sphere_fit_LFpcov.m" as a competitor.

#### Running the simulation scripts ###

There are many simulation scripts with file names of the form "run_sphere_sim_nN_pP_NOISE*.m",
where N denotes the sample size (50, 100, 200), P the dimension (2, 5, 10), and NOISE
the noise level (low = LN, high = HN).  Some filenames end in "_batchM" to indicate
that the 200 simulation runs were broken up into different batches, sometimes of
unequal size.  The first two non-commented lines of code in each file allow the user
to specify whether or not a parallel pool should be created and, if so, how many
workers should be requested.  These can be reset without changing the outputs of
any of the simulations, though timing will depend on these choices among other things.

To run any one of these scripts, one first needs to download and install the following files

1) The manifold optimization toolbox for matlab used for our analyses, 'Manopt_6.0' is available to download from the following link:

https://github.com/NicolasBoumal/manopt-web/blob/master/downloads/Manopt_6.0.zip

Unzip 'Manopt_6.0', which will give folder 'manopt'. Move folder 'manopt' into the directory containing the simulation scripts

2) For implementing Neldermead optimization download the zip file 'FMINSEARCHBND.zip' from the following link:
https://www.mathworks.com/matlabcentral/fileexchange/8277-fminsearchbnd-fminsearchcon

Extract the folder 'FMINSEARCHBND' by unzipping 'FMINSEARCHBND.zip' then move it to the directory containing the simulation scripts

Once installed, a simulation script can be run either by simply typing its name at the
prompt within a Matlab session, e.g.,

>> run_sphere_sim_n50_p2_LN

or via the command line.  For example, to run in the background on a Unix system, one can use

nohup matlab -batch "run_sphere_sim_n50_p2_LN" > n50p2LN.out &

which will save the output into the file n50p2LN.out

NOTE: For larger sample sizes and dimension, the code can take a very long time
to execute and require a lot of memory.  The cases with n = 50 and p = 2, however,
should be doable on a decent laptop or desktop.

### Analyzing Simulation Results

The compiled data sets are all contained in the directory 'FinalSimResults', one
.mat file for each of the 18 simulation settings.  The numeric and graphical
summaries in the text can be reproduced as follows.

1) To reproduce the panels in Figure 1, run the script "Figure_sphereplots_new.m".

2) To reproduce Tables 1 and 2, the script "Tables_1_2_computation.m" can be used.  As
lines 4-5 of this script indicate, a result file from 'FinalSimResults' must first
be read into the Matlab workspace, then the corresponding summaries are computed for
that particular simulation setting.

3) To reproduce the histograms in Figure 2, run the script "Figure_etahat_distribution_p2_new.m"

4) To reproduce the boxplots in Figure 3, run the script "Figures_MSEE_boxplots_new.m"
