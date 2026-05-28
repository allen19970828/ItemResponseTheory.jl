#' @export
difQuade <- function(Data, group, focal.name = NULL, anchor = NULL, 
                     match = "score", type = c("ta", "e", "dxy", "dyx", "gamma"), 
                     alpha = 0.05, purify = FALSE, nrIter = 10, 
                     save.output = FALSE, output = c("out", "default")) {
  
  output <- match.arg(output)
  type <- match.arg(type)

  if (!is.matrix(Data)) {
    Data <- as.matrix(Data)
  }
  storage.mode(Data) <- "numeric"

  if (length(group) != nrow(Data))
    stop("'group' must be the same length as number of rows in 'Data'.")

  group <- as.factor(group)
  levels.group <- levels(group)
  if (length(levels.group) != 2 && is.null(focal.name))
    stop("A binary grouping variable or 'focal.name' must be provided.")
  if (!is.null(focal.name))
    group <- factor(group == focal.name, levels = c(FALSE, TRUE))

  group_num <- as.numeric(group) - 1  # 0 = reference, 1 = focal
  n <- nrow(Data)
  J <- ncol(Data)

  studied <- if (is.null(anchor)) 1:J else setdiff(1:J, anchor)
  anchor0 <- if (is.null(anchor)) 1:J else anchor

  if (match == "score") {
    matchval <- rowSums(Data[, anchor0, drop = FALSE])
  } else if (match == "restscore") {
    matchval <- sapply(studied, function(j) rowSums(Data[, -j, drop = FALSE]))
    matchval <- as.matrix(matchval)
  } else {
    stop("'match' must be either 'score' or 'restscore'")
  }

  Stat <- SE <- Zval <- Pval <- rep(NA, length(studied))
  names(Stat) <- names(Pval) <- colnames(Data)[studied]
  DIFitems <- rep(FALSE, length(studied))

  for (i in seq_along(studied)) {
    item <- studied[i]
    Y <- Data[, item]
    Z <- if (match == "restscore") matchval[, i] + Y else matchval + Y
    X <- group_num

    out <- quadeIndex(X = X, Y = Y, Z = Z, type = type)

    Stat[i] <- out$stat
    SE[i] <- out$se
    Zval[i] <- out$z
    Pval[i] <- out$p
    DIFitems[i] <- out$p < alpha
  }

  res <- list(
    Data = Data,
    group = group,
    focal.name = levels(group)[2],
    type = type,
    match = match,
    purification = purify,
    alpha = alpha,
    stat = Stat,
    se = SE,
    zstat = Zval,
    p.value = Pval,
    DIFitems = DIFitems,
    names = colnames(Data)[studied],
    anchor = anchor0,
    method = "Quade's ordinal indices"
  )
  class(res) <- "difQuade"

  if (save.output) {
    file.name <- if (output == "out") "Quade_results.txt" else output
    write.table(data.frame(Item = names(Stat), Stat, SE, Zval, Pval, DIF = DIFitems),
                file = file.name, sep = "\t", row.names = FALSE)
  }

  return(res)
}

quadeIndex <- function(X, Y, Z, type = "ta", nbins = 5) {
  X <- as.numeric(X)
  Y <- as.numeric(Y)
  Z <- as.numeric(Z)

  valid <- complete.cases(X, Y, Z)
  X <- X[valid]
  Y <- Y[valid]
  Z <- Z[valid]
  n <- length(Y)

  # Discretize Z into bins
  Zb <- cut(Z, breaks = nbins, labels = FALSE)

  Ci <- Di <- Txi <- Tyi <- Txyi <- Wi <- rep(0, n)
  R <- rep(0, n)

  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      if (Zb[i] == Zb[j]) {
        R[c(i, j)] <- R[c(i, j)] + 1

        if ((Y[i] > Y[j] && X[i] > X[j]) || (Y[i] < Y[j] && X[i] < X[j])) {
          Ci[c(i, j)] <- Ci[c(i, j)] + 1
        } else if ((Y[i] > Y[j] && X[i] < X[j]) || (Y[i] < Y[j] && X[i] > X[j])) {
          Di[c(i, j)] <- Di[c(i, j)] + 1
        } else if (Y[i] == Y[j] && X[i] != X[j]) {
          Txi[c(i, j)] <- Txi[c(i, j)] + 1
        } else if (Y[i] != Y[j] && X[i] == X[j]) {
          Tyi[c(i, j)] <- Tyi[c(i, j)] + 1
        } else if (Y[i] == Y[j] && X[i] == X[j]) {
          Txyi[c(i, j)] <- Txyi[c(i, j)] + 1
        }
      }
    }
  }

  Wi <- Ci - Di

  if (type == "gamma") {
    Denom <- Ci + Di
  } else if (type == "ta") {
    Denom <- Ci + Di + Txi + Tyi + Txyi
  } else if (type == "e") {
    Denom <- Ci + Di + Txi + Tyi
  } else if (type == "dyx") {
    Denom <- Ci + Di + Tyi
  } else if (type == "dxy") {
    Denom <- Ci + Di + Txi
  } else {
    stop("Unrecognized type")
  }

  if (sum(Denom) == 0) {
    return(list(stat = NA, se = NA, z = NA, p = NA))
  }

  stat <- sum(Wi) / sum(Denom)
  se <- quadeASE(Denom, Wi)
  z <- stat / se
  p <- 2 * (1 - pnorm(abs(z)))

  return(list(stat = stat, se = se, z = z, p = p))
}

quadeASE <- function(Ri, Wi) {
  sumRsqrd <- sum(Ri)^2
  sumSqW <- sum(Wi^2)
  sumSqR <- sum(Ri^2)
  sumRW <- sum(Ri * Wi)
  sumWsqrd <- sum(Wi)^2

  t1 <- 2 / sumRsqrd
  t2 <- sumRsqrd * sumSqW
  t3 <- 2 * sum(Ri) * sum(Wi) * sumRW
  t4 <- sumWsqrd * sumSqR

  se <- t1 * sqrt(t2 - t3 + t4)
  return(se)
}


#' @export
print.difQuade <- function(x, ...) {
  if (!inherits(x, "difQuade")) {
    stop("Object must be of class 'difQuade'.")
  }

  cat("Detection of DIF Using Quade-type Ordinal Association Indices\n")
  cat("-------------------------------------------------------------\n")
  cat("Index used: ", x$type, "\n")
  cat("Matching variable: ", x$match, "\n")
  cat("Focal group coded as: ", x$focal.name, "\n")
  cat("Item purification: ", ifelse(x$purification, "Yes", "No"), "\n")
  cat("Significance level: ", x$alpha, "\n")
  cat("Anchor items: ", 
      if (is.null(x$anchor)) "none" else paste(x$anchor, collapse = ", "), "\n")
  cat("\n")

  df <- data.frame(
    Item = x$names,
    Stat = round(x$stat, 4),
    `P.value` = signif(x$p.value, 3),
    Signif = symnum(x$p.value, corr = FALSE,
                    cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1),
                    symbols = c("***", "**", "*", ".", " "))
  )

  print(df, row.names = FALSE, right = FALSE)
  cat("\nSignif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1\n")

  cat("\nItems detected as DIF items:\n")
  if (any(x$DIFitems)) {
    cat(" ", paste(x$names[x$DIFitems], collapse = "\n  "), "\n")
  } else {
    cat(" None\n")
  }

  invisible(x)
}


#' @export
plot.difQuade <- function(x, alpha = 0.05,
                          main = "Detection of DIF Using Quade-type Indices",
                          xlab = "Items", ylab = "Quade Index", ...) {
  if (!inherits(x, "difQuade")) {
    stop("Object must be of class 'difQuade'.")
  }

  stat <- x$stat
  pval <- x$p.value
  items <- names(stat)
  J <- length(stat)
  col <- ifelse(pval < alpha, "red", "black")

  plot(stat, type = "h", lwd = 2, col = col,
       xaxt = "n", xlab = xlab, ylab = ylab, main = main, ...)
  axis(1, at = 1:J, labels = items, las = 2)
  abline(h = 0, col = "gray", lty = 2)
}
