#' @export
SimDichoDif <- function(It, ItDIFa, ItDIFb, NR, NF,
                        a = rep(1, It), b,
                        Ga = rep(0, length(ItDIFa)), Gb = rep(0, length(ItDIFb)),
                        D = 1, thR = NULL, thF = NULL,
                        muR = 0, muF = 0, sigR = 1, sigF = 1) {

  pr<-function(th,a,b) exp(a*(th-b))/(1+exp(a*(th-b))) # 2PL to generate UDIF and NUDIF
  
  aR <- aF <- a                 # Item discr. 
  #aF<-aR+Ga             # Item discr. + Group value for NUDIF
  aF[ItDIFa] <- aF[ItDIFa]+Ga
  bR <- bF <- b                 # Item diff.
  #bF<-bR+Gb             # Item diff. + Group value for UDIF
  bF[ItDIFb] <- bF[ItDIFb]+Gb
  
  thR <- if (is.null(thR)) rnorm(NR, muR, sigR) else thR
  thF <- if (is.null(thF)) rnorm(NF, muF, sigF) else thF                                                
  
  #if(Type == "UDIF") {
  #  print("Don't forget to assign a value of 0 to Ga when you investigate UDIF :-)")}
  
  res <- matrix(NA,(NR+NF),It)                                  # Allocate response matrix
  for (i in 1:NR) res[i,]<-rbinom(It,1,pr(thR[i],aR,bR))        # Generate responses for Ref. group               
  for (i in 1:NF) res[NF+i,]<-rbinom(It,1,pr(thF[i],aF,bF))     # Generate responses for Focal group
  
  out <- list()
  out$data <- cbind(res,c(rep(1,NR),rep(2,NF)))
  out$ipars <- data.frame(aR = aR, aF = aF, bR = bR, bF = bF)
  out$thetas <- data.frame(thR = thR, thF = thF)
  return(out)}















