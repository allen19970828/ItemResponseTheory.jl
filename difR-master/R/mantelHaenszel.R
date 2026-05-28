#' @importFrom stats mantelhaen.test
#' @export
mantelHaenszel <- function (data, member, match = "score", correct = TRUE, exact = FALSE, anchor = 1:ncol(data)) {
  res <- resAlpha <- varLambda <- RES <- NULL

  for (item in 1:ncol(data)) {
    # Sélection de l'ensemble d'items à utiliser pour le score
    data2 <- data[, anchor, drop = FALSE]
    if (sum(anchor == item) == 0) {
      data2 <- cbind(data2, data[, item])
    }

    if (!is.matrix(data2)) data2 <- cbind(data2)

    # Calcul du matching score
    if (match[1] == "score") {
      xj <- rowSums(data2, na.rm = TRUE)
    } else if (match[1] == "restscore") {
      rest_anchor <- setdiff(anchor, item)
      if (length(rest_anchor) == 0) {
        xj <- rep(NA, nrow(data))
      } else {
        xj <- rowSums(data[, rest_anchor, drop = FALSE], na.rm = TRUE)
      }
    } else {
      xj <- match
    }

    scores <- sort(unique(xj))
    prov <- NULL
    ind <- 1:nrow(data)

    for (j in 1:length(scores)) {
      Aj <- length(ind[xj == scores[j] & member == 0 & data[, item] == 1])
      Bj <- length(ind[xj == scores[j] & member == 0 & data[, item] == 0])
      Cj <- length(ind[xj == scores[j] & member == 1 & data[, item] == 1])
      Dj <- length(ind[xj == scores[j] & member == 1 & data[, item] == 0])
      nrj <- length(ind[xj == scores[j] & member == 0])
      nfj <- length(ind[xj == scores[j] & member == 1])
      m1j <- length(ind[xj == scores[j] & data[, item] == 1])
      m0j <- length(ind[xj == scores[j] & data[, item] == 0])
      Tj <- length(ind[xj == scores[j]])

      if (exact) {
        if (Tj > 1) prov <- c(prov, c(Aj, Bj, Cj, Dj))
      } else {
        if (Tj > 1)
          prov <- rbind(prov, c(Aj, nrj * m1j / Tj,
                                (((nrj * nfj) / Tj) * (m1j / Tj) * (m0j / (Tj - 1))),
                                scores[j], Bj, Cj, Dj, Tj))
      }
    }

    if (exact) {
      tab <- array(prov, c(2, 2, length(prov) / 4))
      pr <- mantelhaen.test(tab, exact = TRUE)
      RES <- rbind(RES, c(item, pr$statistic, pr$p.value))
    } else {
      if (!is.null(prov)) {
        if (correct)
          res[item] <- (abs(sum(prov[, 1] - prov[, 2])) - 0.5)^2 / sum(prov[, 3])
        else
          res[item] <- (abs(sum(prov[, 1] - prov[, 2])))^2 / sum(prov[, 3])

        resAlpha[item] <- sum(prov[, 1] * prov[, 7] / prov[, 8]) / sum(prov[, 5] * prov[, 6] / prov[, 8])
        varLambda[item] <- sum((prov[, 1] * prov[, 7] + resAlpha[item] * prov[, 5] * prov[, 6]) *
                               (prov[, 1] + prov[, 7] + resAlpha[item] * (prov[, 5] + prov[, 6])) /
                               prov[, 8]^2) / (2 * (sum(prov[, 1] * prov[, 7] / prov[, 8]))^2)
      } else {
        res[item] <- NA
        resAlpha[item] <- NA
        varLambda[item] <- NA
      }
    }
  }

  if (any(resAlpha == Inf | is.na(resAlpha) | resAlpha == 0)) {
    susp_items <- which(resAlpha == Inf | is.na(resAlpha) | resAlpha == 0)
    warning(paste0(
      "Sparse data detected for ",
      ifelse(length(susp_items) > 1, "items ", "item "),
      paste(susp_items, collapse = ", "),
      ": too many zeros in contingency tables. ",
      "This may occur when there are too few respondents, leading to infinite or undefined alpha/delta estimates."
    ), call. = FALSE)
  }

  if (match[1] != "score") mess <- "matching variable" else mess <- "score"

  if (exact)
    return(list(resMH = RES[, 2], Pval = RES[, 3], match = mess))
  else
    return(list(resMH = res, resAlpha = resAlpha, varLambda = varLambda, match = mess))
}
