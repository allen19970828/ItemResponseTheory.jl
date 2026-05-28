#' @importFrom stats glm deviance vcov coefficients
#' @export Logistik
Logistik <- function(
    data, member, member.type = "group", match = "score",
    anchor = 1:ncol(data), type = "both", criterion = "LRT", all.cov = FALSE) {
  #' @keywords internal
  R2 <- function(m, n) {
    1 - (exp(-m$null.deviance / n + m$deviance / n))
  }
  #' @keywords internal
  R2max <- function(m, n) {
    1 - (exp(-m$null.deviance / n))
  }
  #' @keywords internal
  R2DIF <- function(m, n) {
    R2(m, n) / R2max(m, n)
  }

  dev <- R2full <- R2simple <- deltaR <- NULL
  mFull <- mSimple <- seFull <- seSimple <- matrix(0, ncol(data), 4)

  cov.matM0 <- cov.matM1 <- if (all.cov) vector("list", ncol(data)) else NULL

  GROUP <- if (member.type == "group") as.factor(member) else member

  for (item in 1:ncol(data)) {
    if (match[1] == "score") {
      data2 <- data[, anchor, drop = FALSE]
      if (!(item %in% anchor)) {
        data2 <- cbind(data2, data[, item])
      }
      SCORES <- rowSums(data2, na.rm = TRUE)
    } else if (match[1] == "restscore") {
      rest_anchor <- setdiff(anchor, item)
      if (length(rest_anchor) == 0) {
        SCORES <- rep(NA, nrow(data))
      } else {
        SCORES <- rowSums(data[, rest_anchor, drop = FALSE], na.rm = TRUE)
      }
    } else {
      SCORES <- match
    }

    ITEM <- data[, item]
    m0 <- switch(type,
      both = glm(ITEM ~ SCORES * GROUP, family = "binomial"),
      udif = glm(ITEM ~ SCORES + GROUP, family = "binomial"),
      nudif = glm(ITEM ~ SCORES * GROUP, family = "binomial")
    )
    m1 <- switch(type,
      both = glm(ITEM ~ SCORES, family = "binomial"),
      udif = glm(ITEM ~ SCORES, family = "binomial"),
      nudif = glm(ITEM ~ SCORES + GROUP, family = "binomial")
    )

    if (criterion == "LRT") {
      dev[item] <- deviance(m1) - deviance(m0)
    } else {
      if (criterion != "Wald") stop("'criterion' must be either 'LRT' or Wald'", call. = FALSE)
      coeff <- as.numeric(coefficients(m0))
      covMat <- summary(m0)$cov.scaled
      C <- switch(type,
        udif = rbind(c(0, 0, 1)),
        nudif = rbind(c(0, 0, 0, 1)),
        both = rbind(c(0, 0, 1, 0), c(0, 0, 0, 1))
      )
      dev[item] <- t(C %*% coeff) %*% solve(C %*% covMat %*% t(C)) %*% C %*% coeff
    }

    R2full[item] <- R2DIF(m0, nrow(data))
    R2simple[item] <- R2DIF(m1, nrow(data))
    deltaR[item] <- R2DIF(m0, nrow(data)) - R2DIF(m1, nrow(data))

    mFull[item, 1:length(m0$coefficients)] <- m0$coefficients
    mSimple[item, 1:length(m1$coefficients)] <- m1$coefficients
    seFull[item, 1:length(m0$coefficients)] <- sqrt(diag(vcov(m0)))
    seSimple[item, 1:length(m1$coefficients)] <- sqrt(diag(vcov(m1)))

    if (all.cov) cov.matM0[[item]] <- vcov(m0)
    if (all.cov) cov.matM1[[item]] <- vcov(m1)
  }

  colnames(mFull) <- colnames(mSimple) <- colnames(seFull) <- colnames(seSimple) <-
    c("(Intercept)", "SCORE", "GROUP", "SCORE:GROUP")

  res <- list(
    stat = dev, R2M0 = R2full, R2M1 = R2simple, deltaR2 = deltaR,
    parM0 = mFull, parM1 = mSimple, seM0 = seFull, seM1 = seSimple,
    cov.M0 = cov.matM0, cov.M1 = cov.matM1,
    criterion = criterion, member.type = member.type,
    match = ifelse(match[1] == "score", "score",
      ifelse(match[1] == "restscore", "restscore", "matching variable")
    )
  )
  return(res)
}
