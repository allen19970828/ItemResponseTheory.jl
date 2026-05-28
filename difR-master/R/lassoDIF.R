#' @importFrom glmnet glmnet
lassoDIF <- function(Data, lambda = NULL, ...) {
  if (!is.data.frame(Data)) Data <- as.data.frame(Data)
  y <- factor(Data$Y)
  J <- length(unique(Data$ITEM))
  x <- model.matrix(Data$Y ~ -1 + factor(Data$ITEM) + Data$SCORE + factor(Data$ITEM):factor(Data$GROUP))
  
  pen <- rep(0, 2 * J + 1)
  pen[(length(pen) - J + 1):length(pen)] <- 1
  
  res <- glmnet(x, y, family = "binomial", alpha = 1,
                penalty.factor = pen, lambda = lambda,
                intercept = FALSE, ...)
  
  return(res)
}
