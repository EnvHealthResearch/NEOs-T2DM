# Run from this folder. Input data are synthetic.
source('setup.R')
local({
# Model calculations preserved from supplied script; synthetic inputs only.
out <- 'results/Spearman'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
comb<-combn(xs,2);z<-do.call(rbind,lapply(seq_len(ncol(comb)),function(i){u<-comb[1,i];v<-comb[2,i];test<-cor.test(d[[u]],d[[v]],method='spearman',exact=FALSE);data.frame(x=u,y=v,rho=unname(test$estimate),P=test$p.value)}));z$FDR<-p.adjust(z$P,'BH')
write.csv(z,file.path(out,'spearman.csv'),row.names=FALSE)
})
