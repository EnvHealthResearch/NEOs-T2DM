# Run from this folder. Input data are synthetic.
source('setup.R')
local({
# Model calculations preserved from supplied script; synthetic inputs only.
out <- 'results/qgcomp'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
for(x in xs){
 k <- quantile(d[[x]],c(.25,.5,.75))
 stopifnot(!anyDuplicated(k))
 d[[x]] <- as.integer(cut(d[[x]],c(-Inf,k,Inf),right=FALSE))-1L
}
fit <- clogit(reformulate(c(xs,covs),'event'),data=d)
b <- coef(fit)[xs]; psi <- sum(b); se <- sqrt(sum(vcov(fit)[xs,xs]))
write.csv(data.frame(OR=exp(psi),lower=exp(psi-1.96*se),upper=exp(psi+1.96*se),P=2*pnorm(-abs(psi/se))),file.path(out,'mixture.csv'),row.names=FALSE)
write.csv(data.frame(exposure=xs,beta=b,direction=ifelse(b>0,'positive','negative'),weight=ifelse(b>0,b/sum(b[b>0]),b/sum(b[b<0]))),file.path(out,'weights.csv'),row.names=FALSE)
})
