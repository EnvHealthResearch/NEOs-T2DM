# NEOs and incident T2DM: example analysis code

This folder contains separate scripts adapted from a nested case-control study. All supplied data are synthetic: 80 matched pairs, 160 people. No participant records or original fitted models are included. Example outputs are not manuscript results.

## Files
| File | Purpose |
|---|---|
| setup.R | Shared example-data reading, exposure transformation and variable definitions |
| spearman.R | Spearman correlations |
| clogit.R | Single-pollutant conditional logistic regression |
| rcs.R | Three-knot restricted cubic splines, median reference |
| qgcomp.R | Supplied conditional quantile-mixture calculation and weights |
| bkmr.R | BKMR, PIPs, response summaries and P4/P5 plots |
| example_data.csv | Synthetic example data shared by all scripts |

## Run
Install dependencies once in R:
```r
install.packages(c("survival", "Hmisc", "bkmr", "ggplot2"))
```
Set the working directory to this folder. Run the desired script, for example:
```r
source("clogit.R")
source("rcs.R")
source("bkmr.R")
```
Each analysis automatically loads `setup.R`; scripts can be run independently. Outputs are written to `results/`. No descriptive-analysis script is included.

## Notes
The original model formulas are retained where verified from source code. The shared input is illustrative: synthetic raw exposures are SG-corrected then natural-log transformed. BKMR covariate names illustrate the source's positional columns and have not been checked against private data. The quantile-mixture script implements the supplied coefficient-sum calculation using a conditional logistic model, rather than calling the qgcomp package.

BKMR uses 20,000 MCMC iterations (seed 2026). P4/P5 show latent probit estimates, not odds ratios; they are saved as PNG and 600 dpi TIFF. Original P2/P3/P6 interaction plots are not included.

The example workflow was tested with R 4.6.1, survival 3.8.6, Hmisc 5.3.0 and bkmr 0.2.2; ggplot2 is required for plotting. BKMR execution was tested using a shortened chain of 100 iterations; the distributed script specifies 20,000 iterations, as in the original analysis. The 20,000-iteration configuration has not been rerun as part of this code cleanup. The synthetic data illustrate code execution and do not reproduce the study's numerical results. Original study data, model convergence and manuscript numerical results have not been independently verified.
