
#' @export
genMantelHaenszel<-function(data,member,match="score",anchor=1:ncol(data)){
res<-NULL
for (item in 1:ncol(data)){
data2<-data[,anchor]
if (sum(anchor==item)==0) data2<-cbind(data2,data[,item])
if (match[1]=="score") xj<-rowSums(data2,na.rm=TRUE)
else xj<-match
scores<-sort(unique(xj))
nrGroups<-length(unique(member))-1
a<-e<-rep(0,nrGroups)
v<-matrix(0,nrGroups,nrGroups)
for (sc in 1:length(scores)){
n.ppk<-length(data[,item][xj==scores[sc]])
if (n.ppk>1){
n.1pk<-length(data[,item][xj==scores[sc] & data[,item]==0])
n.2pk<-length(data[,item][xj==scores[sc] & data[,item]==1])
rk<-NULL
for (nrg in 1:(nrGroups)) rk[nrg]<-length(data[,item][xj==scores[sc] & member==nrg])
ak<-NULL
for (nrg in 1:(nrGroups)) ak[nrg]<-length(data[,item][xj==scores[sc] & member==nrg & data[,item]==0])
ek<-n.1pk*rk/n.ppk
vk<-n.1pk*n.2pk/((n.ppk-1)*n.ppk^2)*(n.ppk*diag(rk)-rk%*%t(rk))
a<-a+ak
e<-e+ek
v<-v+vk
}
}
gmh<-as.numeric(t(a-e)%*%solve(v)%*%(a-e))
res[item]<-gmh
}
return(res)
}







