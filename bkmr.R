# Run from this folder. Includes P4 and P5 plots.
source('setup.R')
local({
# Demonstration only. Original study setting: iter=20000, seed=2026.
# Covariate names below are a synthetic demonstration schema: source used columns 17:26.
# Their true names/types cannot be verified without private data.
cov_df <- d[c('age','BMI','Gender','Culture_2','Marry_2','Income_2','Smoking_3','Drinking_3','Exercise_3','family_history')]
# Preserve original BKMR coding: only three lifestyle variables explicitly factors.
for (v in names(cov_df)) if (is.factor(cov_df[[v]])) cov_df[[v]]<-as.numeric(as.character(cov_df[[v]]))
for (v in c('Smoking_3','Drinking_3','Exercise_3')) cov_df[[v]]<-factor(cov_df[[v]])
X<-model.matrix(~.,cov_df)[,-1,drop=FALSE];Z<-scale(as.matrix(d[xs]));y<-d$event
stopifnot(qr(X)$rank==ncol(X),all(is.finite(X)),all(is.finite(Z)))
set.seed(2026)
fit<-bkmr::kmbayes(y=y,Z=Z,X=X,iter=20000,family='binomial',varsel=TRUE,est.h=TRUE,verbose=FALSE)
# Retain package selection defaults, as in the original. Not a convergence assessment.
write.csv(bkmr::ExtractPIPs(fit), 'results/bkmr_pip.csv',row.names=FALSE)
u<-bkmr::PredictorResponseUnivar(fit,q.fixed=.5,ngrid=100)
write.csv(u,'results/bkmr_univariate.csv',row.names=FALSE)
write.csv(bkmr::OverallRiskSummaries(fit,y=y,Z=Z,X=X,qs=seq(.25,.75,.05),q.fixed=.5,method='exact'),'results/bkmr_overall.csv',row.names=FALSE)
write.csv(bkmr::SingVarRiskSummaries(fit,y=y,Z=Z,X=X,qs.diff=c(.25,.75),q.fixed=c(.25,.5,.75),method='exact'),'results/bkmr_single.csv',row.names=FALSE)
pdf('results/bkmr_univariate.pdf');par(mfrow=c(4,4))
for(v in unique(u$variable)){a<-u[u$variable==v,];plot(a$z,a$est,type='l',main=v,xlab='Standardized synthetic exposure',ylab='Latent probit estimate');lines(a$z,a$est-1.96*a$se,lty=2);lines(a$z,a$est+1.96*a$se,lty=2)}
dev.off()

# P4 and P5 adapted from the supplied plotting code. Synthetic results only.
# Plot the synthetic summaries generated above.
library(ggplot2)
risks.overall <- read.csv('results/bkmr_overall.csv')
risks.singvar <- read.csv('results/bkmr_single.csv')
# Generic serif avoids platform-specific Windows font registration.
plot_theme <- theme(
  text = element_text(family = 'serif'),
  axis.title = element_text(size = 12, color = 'black', face = 'bold'),
  axis.text = element_text(size = 10, color = 'black'),
  axis.ticks = element_line(color = 'black'),
  legend.text = element_text(size = 10, color = 'black'),
  plot.margin = margin(t = 20, r = 20, b = 10, l = 10)
)
P4 <- ggplot(risks.overall,
             aes(quantile, est, ymin = est - 1.96 * sd, ymax = est + 1.96 * sd)) +
  geom_hline(yintercept = 0, lty = 2, col = 'brown') +
  geom_pointrange() +
  labs(x = 'Joint exposure quantile', y = 'Latent probit estimate (95% interval)',
       caption = 'Synthetic demo data') + plot_theme
name_map <- c(lnIMI='IMI', lnACE='ACE', lnCLO='CLO', lnTHM='THM',
              lnTHD='THD', lnDNT='DNT', lnNIT='NIT', lnIDCT='IDCT',
              ln5_OH_IMI='5-OH-IMI', ln6_CINA='6-CINA', lnN_ACE='N-ACE',
              lnN_THM='N-THM', lnTHD_A='THD-A')
# Preserve ordering by mean absolute effect across the fixed quantiles.
order_effect <- tapply(abs(risks.singvar$est), risks.singvar$variable, mean, na.rm=TRUE)
risks.singvar$variable <- factor(risks.singvar$variable,
                                levels=names(sort(order_effect)))
P5 <- ggplot(risks.singvar,
             aes(variable, est, ymin=est-1.96*sd, ymax=est+1.96*sd, col=q.fixed)) +
  geom_pointrange(position=position_dodge(width=.75)) + coord_flip() +
  scale_x_discrete(labels=function(x) ifelse(x %in% names(name_map),name_map[x],x)) +
  geom_hline(yintercept=0,lty=2,col='black') +
  labs(x='Exposure', y='Latent probit estimate (95% interval)',
       color='Other exposures\n(fixed quantile)',
       caption='Synthetic demo data') + plot_theme
# Original sizes and TIFF resolution; PNG previews are also exported.
for (ext in c('tiff','png')) {
  extra <- if(ext=='tiff') list(compression='none') else list()
  do.call(ggsave,c(list(filename=paste0('results/P4_Overall_Risk.',ext),
                      plot=P4,width=24,height=18,units='cm',dpi=600),extra))
  do.call(ggsave,c(list(filename=paste0('results/P5_Single_Variable.',ext),
                      plot=P5,width=20,height=20,units='cm',dpi=600),extra))
}
})
