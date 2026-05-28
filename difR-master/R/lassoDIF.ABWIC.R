#' @importFrom stats deviance coef
#' @importFrom glmnet deviance coef
#' @export
lassoDIF.ABWIC <- function(Data, group, type="AIC", N=NULL, lambda=NULL, ...){
  
  data <- LassoData(Data, group)
  out <- lassoDIF(data, lambda, ...)
  if(is.null(N)){N <- nrow(Data)}
  
  J <- (nrow(out$beta)-1)/2
  
  
  if (type == "AIC" | type == "BIC"){
    CRIT <- switch(type, AIC = deviance(out)+2*out$df, BIC = deviance(out)+log(J*N)*out$df)
    l.opt <- out$lambda[CRIT == min(CRIT)]
    nr.opt <- (1:length(out$lambda))[abs(out$lambda-l.opt) == min(abs(out$lambda-l.opt))]
    pr <- out$beta[, nr.opt]
  }
  
  if (type == "WIC"){
    
    CRIT <- NULL
    ppAIC <- deviance(out) + 2*out$df
    ppBIC <- deviance(out) + log(J*N)*out$df
    nr.w <- 100    
    s <- seq(from = 0, to = 1, length = nr.w)
    l.seq <- NULL
    
    for (i in 1:length(s)){
      f <- s[i]*ppAIC + (1-s[i])*ppBIC
      l.seq[i] <- out$lambda[f == min(f)]
    }
    
    l.opt <- median(unique(l.seq))
    nr1 <- nrow(coef(out, s = 0))-J+1
    nr2 <- nrow(coef(out, s = 0))
    pr <- coef(out, s = l.opt)[nr1:nr2, 1]
  }
  
  IND <- (length(pr)-J+1):(length(pr))
  RES <- NULL
  if (max(abs(pr[IND])) > 0) RES <- (1:J)[abs(pr[IND]) > 0]
  mat <- cbind(pr[IND])
  mat.names <- "Item1"
  for (i in 2:J) mat.names <- c(mat.names, paste("Item", i, sep = ""))
  rownames(mat) <- mat.names

  return(list(DIFitems = RES, DIFpars = mat, crit.value = CRIT, crit.type = type, lambda = out$lambda, opt.lambda = l.opt,
              glmnet.fit = out))
}

#######################################################

#' Plot coefficient paths from LASSO DIF
#'
#' This function displays coefficient trajectories from LASSO-regularized DIF detection.
#'
#' @param out A fitted object returned by \code{lassoDIF()}.
#' @param nr.lambda Number of lambda values to evaluate and display (default is 100).
#' @param highlight Optional: indices of items to highlight in color.
#' @param title Main title of the plot.
#' @param ... Additional graphical parameters passed to \code{matplot()}.
#'
#' @return A base R plot of coefficient paths.
#' @export
plot_lasso_paths <- function(out, nr.lambda = 100, highlight = NULL,
                             title = "Regularization Paths of DIF Effects", ...) {

  coef_list  <- lassoDIF.coef(out, nr.lambda = nr.lambda)
  DIF_coefs  <- coef_list$pars
  log_lambda <- log(coef_list$lambda)

  item_names <- rownames(DIF_coefs)
  n_items    <- nrow(DIF_coefs)

  # Colors for paths (and legend), respecting highlight
  cols <- if (is.null(highlight)) {
    seq_len(n_items)
  } else {
    ifelse(seq_len(n_items) %in% highlight, 2, "grey70")
  }

  # Adaptive legend layout
  cex_leg <- if (n_items <= 15) 0.7 else if (n_items <= 30) 0.6 else 0.5
  rows_per_col <- 20  # max items per column in legend panel
  ncol_leg <- max(1, ceiling(n_items / rows_per_col))

  # Save/restore graphics state
  op <- par(no.readonly = TRUE)
  on.exit({
    par(op)
    layout(1)  # reset layout
  }, add = TRUE)

  # Two-panel layout: plot (left) + legend (right)
  layout(matrix(c(1, 2), 1, 2), widths = c(4.5, 1.5))

  ## Panel 1: coefficient paths
  par(mar = c(5, 4, 4, 1))
  matplot(
    log_lambda, t(DIF_coefs),
    type = "l", lty = 1,
    xlab = expression(log(lambda)),
    ylab = "Estimated DIF Effects",
    main = title,
    ...,
    col = cols
  )

  ## Panel 2: legend only
  par(mar = c(0, 0, 0, 0))
  plot.new()
  legend(
    "center",
    legend = item_names,
    col = cols, lty = 1,
    ncol = ncol_leg,
    cex = cex_leg,
    bty = "n"
  )
}



