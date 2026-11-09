# Run from this folder. Input data are synthetic.
source('setup.R')
local({
# Model calculations preserved from supplied script; synthetic inputs only.
out <- 'results/clogit'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
summaries <- list()
for(x in xs){
 v <- d[[x]]
 fit <- clogit(reformulate(c(x,covs),'event'),data=d)
 b <- coef(fit)[x]; se <- sqrt(vcov(fit)[x,x]); iq <- IQR(v)
 summaries[[x]] <- data.frame(exposure=x,beta=b,OR=exp(b),lower=exp(b-1.96*se),upper=exp(b+1.96*se),IQR=iq,OR_IQR=exp(b*iq),lower_IQR=exp((b-1.96*se)*iq),upper_IQR=exp((b+1.96*se)*iq),P=2*pnorm(-abs(b/se)))
}
single <- do.call(rbind,summaries);single$FDR <- p.adjust(single$P,'BH')
write.csv(single,file.path(out,'single.csv'),row.names=FALSE)
})
