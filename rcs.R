# Run from this folder. Input data are synthetic.
source('setup.R')
local({
# Model calculations preserved from supplied script; synthetic inputs only.
out <- 'results/RCS'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
splines <- curves <- list()
pdf(file.path(out,'RCS.pdf'),width=10,height=8)
par(mfrow=c(2,2),mar=c(4,4,3,1))
for(x in xs){
 v <- d[[x]]
 k <- rcspline.eval(v,nk=3,knots.only=TRUE)
 B <- rcspline.eval(v,knots=k,inclx=TRUE)
 d$linear <- B[,1]; d$nonlinear <- B[,2]
 fit <- clogit(reformulate(c('linear','nonlinear',covs),'event'),data=d)
 b <- coef(fit)[1:2]; V <- vcov(fit)[1:2,1:2]
 splines[[x]] <- data.frame(exposure=x,k1=k[1],k2=k[2],k3=k[3],reference=median(v),P_overall=pchisq(drop(t(b)%*%solve(V,b)),2,lower.tail=FALSE),P_nonlinear=pchisq(b[2]^2/V[2,2],1,lower.tail=FALSE))
 g <- sort(unique(c(seq(quantile(v,.05),quantile(v,.95),length.out=200),median(v))))
 D <- sweep(rcspline.eval(g,knots=k,inclx=TRUE),2,rcspline.eval(median(v),knots=k,inclx=TRUE)[1,])
 eta <- drop(D%*%b); se <- sqrt(rowSums((D%*%V)*D))
 cr <- data.frame(exposure=x,value=g,OR=exp(eta),lower=exp(eta-1.96*se),upper=exp(eta+1.96*se))
 stopifnot(all(cr[g==median(v),3:5]==1))
 curves[[x]] <- cr
 plot(g,cr$OR,type='l',ylim=range(cr$lower,cr$upper),main=x,xlab='ln(SG-adjusted concentration)',ylab='Conditional OR (95% CI)')
 lines(g,cr$lower,lty=2);lines(g,cr$upper,lty=2);abline(h=1,lty=3)
}
dev.off()
write.csv(do.call(rbind,splines),file.path(out,'RCS.csv'),row.names=FALSE)
write.csv(do.call(rbind,curves),file.path(out,'curves.csv'),row.names=FALSE)
})
