#' @importFrom stats coef deviance
#' @importFrom glmnet cv.glmnet coef deviance
#' @export
lassoDIF.CV <- function(Data, group, nfold = 5, lambda = NULL, ...){
  
  data <- LassoData(Data, group)
  
  if (!is.data.frame(data)) data <- as.data.frame(data) 
  y <- factor(data$Y)
  J <- length(unique(data$ITEM))
  x <- model.matrix(data$Y~-1+factor(data$ITEM)+data$SCORE+factor(data$ITEM):factor(data$GROUP))
  
  pen<-rep(0, 2*J+1)
  pen[(length(pen)-J+1):length(pen)] <- 1
  
  prov <- cv.glmnet(x, y, family = "binomial", nfolds = nfold, alpha = 1, type.measure = "deviance", penalty.factor = pen,
                    lambda = lambda, ...)
  l.opt <- max(prov$lambda[prov$cvm == min(prov$cvm)])

  nr.opt <- (1:length(prov$lambda))[abs(prov$lambda-l.opt) == min(abs(prov$lambda-l.opt))]
  pr <- prov$glmnet.fit$beta[, nr.opt]
  
  IND <- (length(pr)-J+1):(length(pr))
  RES <- NULL
  if (max(abs(pr[IND])) > 0) RES <- (1:J)[abs(pr[IND]) > 0]
  
  mat <- cbind(pr[IND])
  mat.names <- "Item1"
  for (i in 2:J) mat.names <- c(mat.names, paste("Item", i, sep = ""))
  rownames(mat) <- mat.names
  
  
  return(list(DIFitems = RES, DIFpars = mat, crit.value = prov$cvm, crit.type = "cv", lambda = prov$glmnet.fit$lambda, opt.lambda = l.opt,
              glmnet.fit = prov$glmnet.fit))
}



