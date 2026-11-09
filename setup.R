library(survival)
xs <- c('lnIMI','lnACE','lnCLO','lnTHM','lnTHD','lnDNT','lnNIT','lnIDCT','ln5_OH_IMI','ln6_CINA','lnN_ACE','lnN_THM','lnTHD_A')
fac <- c('Culture_2','Marry_2','Income_2','Smoking_3','Drinking_3','Exercise_3','family_history')
covs <- c('age','BMI',fac,'strata(pair)')
rcspline.eval <- Hmisc::rcspline.eval
# Synthetic inputs only. No real study records are distributed or read.
d <- read.csv('example_data.csv', check.names=FALSE)
stopifnot(all(d$synthetic == 1), !anyDuplicated(d$ID), all(table(d$pair,d$event)==1))
# Demonstrate SG correction before natural logarithm; reference is synthetic median SG.
for (x in xs) d[[x]] <- log(d[[paste0(x,'_raw')]] * (median(d$USG)-1)/(d$USG-1))
d[fac] <- lapply(d[fac], factor)
stopifnot(all(complete.cases(d[c(xs,fac,'age','BMI','pair','event')])))

dir.create('results', showWarnings=FALSE)
