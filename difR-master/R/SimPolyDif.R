################################################################################
## GPCM traceline

# theta - vector or single theta value
# a - slope parameter
# b - overall difficulty parameter
# d - K x 1 vector of step parameters (these ought to sum to 0; usually first is 0)
# where K is the total number of categories
# D - scaling constant

crf.gpcm<-function(theta, a, b, d, D=1){
  ncat<-length(d)
  P<-matrix(0,length(theta),ncat)
  for(i in 1:ncat){
    if(i==1){
      z<-D*a*(theta-b+d[i])
    } else {
      z<-D*a*(theta-b+d[i])
      z<-z+rowSums(as.matrix(P[,(i-1)]))
    }
    P[,i]<-z
  }
  
  P<-exp(P)/rowSums(exp(P))
  P
}


################################################################################
## Data generation

# Assumes thetas and item parameters are supplied

gen.gpcm <- function(th, a.vec, b.vec, d.list, D=1){
  
  ni <- length(a.vec) # number of items
  n <- length(th) # number of respondents

  dat <- sapply(as.list(1:ni), function(j){
    P <- crf.gpcm(th, a.vec[j], b.vec[j], d.list[[j]], D=D)
    ncat <- ncol(P)
    apply(P, 1, function(p){sample(0:(ncat-1), 1, prob = p)})   
  })
  
  colnames(dat) <- paste0("item",1:ni)
  dat
  
}

################################################################################
## Wrapper for multiple group data generation and DIF generation.

#' @export
SimPolyDif <- function(It, ItDIFa, ItDIFb,
                       NR, NF, a, b, d, ncat=3,
                       Ga=rep(0,ItDIFa), Gb=rep(0,ItDIFb),
                       D=1, 
                       thR=NULL,thF=NULL,muR=0,muF=0,sigR=1,sigF=1,
                       ItDIFd=NULL, Gd = lapply(1:It, function(x){rep(0,ncat)})){
  
  # generate latent trait scores
  if(is.null(thR)){thR<-rnorm(NR,muR,sigR)}    # Ref group    
  if(is.null(thF)){thF<-rnorm(NF,muF,sigF)}    # Focal group
  
  # modify parameters to induce DIF
  aR <- aF <- a                 # Item discr.
  aF[ItDIFa] <- aF[ItDIFa]+Ga
  bR <- bF <- b                 # Item diff.
  bF[ItDIFb] <- bF[ItDIFb]+Gb
  dR <- dF <- d                 # Step parameters
  if(!is.null(ItDIFd)){
    dF <- lapply(1:It, function(i){
      if(i %in% ItDIFd){
        dF[[i]]+Gd[[which(ItDIFd %in% i)]]
      } else {
        dF[[i]]
      }
    })
  }
  
  # Generate responses
  datR <- gen.gpcm(thR, aR, bR, dR, D=D)
  datF <- gen.gpcm(thF, aF, bF, dF, D=D)
  
  # create output
  out       <- list()
  group     <- c(rep("G1",NR),rep("G2",NF))
  out$data  <- cbind(rbind(datR,datF),data.frame(group))
  out$ipars <- cbind(data.frame(aR=aR, aF=aF, bR=bR, bF=bF), 
                     t(as.data.frame(dR, fix.empty.names=FALSE, row.names=paste0("dR",1:ncat))),
                     t(as.data.frame(dF, fix.empty.names=FALSE, row.names=paste0("dF",1:ncat))))
  row.names(out$ipars) <- NULL
  out$thetas <- data.frame(c(thR, thF), group) # SB: new
  colnames(out$thetas) <- c("Theta", "Groupe")
  return(out)
}




