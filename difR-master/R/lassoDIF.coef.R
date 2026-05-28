#' @importFrom stats coef
#' @importFrom glmnet coef
lassoDIF.coef <- function(out, nr.lambda){
  J <- (nrow(out$beta)-1)/2
  nr1 <- nrow(coef(out, s = 0))-J+1
  nr2 <- nrow(coef(out, s = 0))
  s <- seq(from = 0, to = max(out$lambda), length = nr.lambda)
  mat <- coef(out, s = s)[nr1:nr2, ]
  mat.names <- "Item1"
  for (i in 2:J) mat.names <- c(mat.names, paste("Item", i, sep = ""))
  rownames(mat) <- mat.names
  return(list(lambda = s, pars = as.matrix(mat)))
}




