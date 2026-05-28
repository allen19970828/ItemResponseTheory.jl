#' @export
difContinuous <- function(
    Data, group, focal.name,
    anchor = NULL,
    member.type = "group",
    match = "score",
    type = "both",
    criterion = "F",
    alpha = 0.05, all.cov = FALSE,
    purify = FALSE, nrIter = 10,
    p.adjust.method = NULL, puriadjType = "simple",
    save.output = FALSE, output = c("out", "default")
) {
  ## --- Normalize choices & prepare base objects ---
  member.type <- .check_character(member.type, choices = c("group", "cont"))
  type        <- .check_character(type, choices = c("both", "udif", "nudif"))
  criterion   <- .check_character(criterion, choices = c("F", "Wald"))
  puriadjType <- .check_character(puriadjType, choices = c("simple", "combined"))
  output      <- .check_character(output, choices = c("out", "default"), several.ok = TRUE)
  alpha       <- .check_numeric(alpha, 0, 1)
  nrIter      <- .check_numeric(nrIter, low = 0)
  all.cov     <- .check_logical(all.cov)

  ## --- Locate/validate the grouping variable ---
  group_result <- .resolve_group(Data, group, focal.name, member.type)
  GROUP <- group_result$GROUP
  DATA <- group_result$DATA

  m <- ncol(DATA)
  n <- nrow(DATA)

  ## --- Checking structure of Data - continuous items required
  if (any(!sapply(DATA, is.numeric))) {
    stop("'Data' must contain numeric responses only.", call. = FALSE)
  }

  ## --- Handle anchor items ---
  anchor_results <- .resolve_anchor(anchor, DATA)
  ANCHOR         <- anchor_results$ANCHOR
  tested_items   <- anchor_results$tested_items

  ## --- Validate 'purify', 'p.adjust.method', and 'puriadjType' arguments ---
  purify  <- .check_logical(purify)
  if (purify && !(is.character(match) && match[1] %in% c("score", "zscore"))) {
    stop("Purification allowed only when match is 'score' or 'zscore'.", call. = FALSE)
  }

  p.adjust_results <- .resolve_p.adjust(p.adjust.method, purify, puriadjType)
  adj.method <- p.adjust_results$adj.method # after item purification completed
  puri.adj.method <- p.adjust_results$puri.adj.method # afted each run of item purification

  ## --- Constants for tests ---
  DDF <- switch(type,
                "both" = c(3 - 1, n - 3),
                "udif" = c(2 - 1, n - 2),
                "nudif" = c(3 - 2, n - 3))
  Q   <- switch(criterion,
                "F" = qf(1 - alpha, DDF[1], DDF[2]),
                "Wald" = qchisq(1 - alpha, DDF[1]))

  ## --- Main path (no purification or anchors/custom match present) ---
  if (!purify || !(is.character(match) && match[1] %in% c("score", "zscore")) || !is.null(anchor)) {

    PROV <- Continuous(DATA, GROUP,
                       member.type = member.type,
                       match = match, type = type, criterion = criterion,
                       anchor = ANCHOR, tested_items = tested_items, all.cov = all.cov)

    STATS <- PROV$stat
    PVAL  <-  switch(criterion,
                     "F" = 1 - pf(STATS, DDF[1], DDF[2]),
                     "Wald" = 1 - pchisq(STATS, DDF[1]))
    P.ADJUST <- p.adjust(PVAL, method = adj.method)

    lmPar <- PROV$parM1
    lmSe  <- PROV$seM1

    if (min(P.ADJUST, na.rm = TRUE) >= alpha) {
      DIFitems <- "No DIF item detected"
    } else {
      DIFitems <- which(P.ADJUST < alpha)
      lmPar[DIFitems, ] <- PROV$parM0[DIFitems, ]
      lmSe[DIFitems, ]  <- PROV$seM0[DIFitems, ]
    }
    adjusted.p <- if (is.null(p.adjust.method)) NULL else P.ADJUST

    RES <- list(
      Stat = STATS, p.value = PVAL,
      lmPar = lmPar, lmSe = lmSe,
      parM0 = PROV$parM0, seM0 = PROV$seM0,
      covM0 = PROV$covM0, covM1 = PROV$covM1,
      deltaR2 = PROV$deltaR2,
      alpha = alpha, thr = Q, DIFitems = DIFitems,
      member.type = member.type, match = PROV$match,
      type = type, p.adjust.method = p.adjust.method,
      adjusted.p = adjusted.p, purification = purify,
      names = colnames(DATA), anchor.names = anchor, #anchor.names = dif.anchor,
      criterion = criterion, save.output = save.output, output = output,
      Data = DATA, group = GROUP
    )

  } else {
    ## --- Purification loop ---
    nrPur  <- 0L
    difPur <- NULL
    noLoop <- FALSE

    prov1   <- Continuous(DATA, GROUP,
                          member.type = member.type, match = match,
                          type = type, criterion = criterion,
                          tested_items = tested_items,
                          all.cov = all.cov)
    stats1 <- prov1$stat
    pval1  <-  switch(criterion,
                     "F" = 1 - pf(stats1, DDF[1], DDF[2]),
                     "Wald" = 1 - pchisq(stats1, DDF[1]))
    p.adjust1 <- p.adjust(pval1, method = puri.adj.method)

    if (min(p.adjust1, na.rm = TRUE) >= alpha) {
      DIFitems <- "No DIF item detected"
      lmPar <- prov1$parM1
      lmSe  <- prov1$seM1
      noLoop <- TRUE
    } else {
      dif   <- which(p.adjust1 < alpha)
      difPur <- rep(0L, length(stats1))
      difPur[dif] <- 1L

      repeat {
        if (nrPur >= nrIter) break
        nrPur <- nrPur + 1L
        nodif <- if (is.null(dif)) seq_len(m) else setdiff(seq_len(m), dif)

        prov2 <- Continuous(DATA, GROUP,
                            member.type = member.type, match = match,
                            type = type, criterion = criterion,
                            anchor = nodif, tested_items = tested_items,
                            all.cov = all.cov)

        stats2 <- prov2$stat
        pval2  <-  switch(criterion,
                          "F" = 1 - pf(stats2, DDF[1], DDF[2]),
                          "Wald" = 1 - pchisq(stats2, DDF[1]))
        p.adjust2 <- p.adjust(pval2, method = puri.adj.method)

        dif2 <- if (min(p.adjust2, na.rm = TRUE) >= alpha) NULL else which(p.adjust2 < alpha)

        difPur <- rbind(difPur, rep(0L, m))
        difPur[nrPur + 1L, dif2] <- 1L

        dif  <- sort(if (is.null(dif)) integer(0) else dif)
        dif2 <- sort(if (is.null(dif2)) integer(0) else dif2)
        if (length(dif) == length(dif2) && identical(dif, dif2)) {
          noLoop <- TRUE
          break
        } else {
          dif <- dif2
        }
      }

      prov1     <- prov2
      stats1    <- stats2
      pval1     <- pval2
      p.adjust1 <- p.adjust(pval1, method = adj.method)

      lmPar <- prov1$parM1
      lmSe  <- prov1$seM1

      if (min(p.adjust1, na.rm = TRUE) >= alpha) {
        DIFitems <- "No DIF item detected"
      } else {
        DIFitems <- which(!is.na(stats1) & p.adjust1 < alpha)
        lmPar[DIFitems, ] <- prov1$parM0[DIFitems, ]
        lmSe[DIFitems, ]  <- prov1$seM0[DIFitems, ]
      }
      adjusted.p <- if (is.null(p.adjust.method)) NULL else p.adjust1
    }

    if (!is.null(difPur)) {
      rownames(difPur) <- paste0("Step", seq_len(nrow(difPur)) - 1L)
      colnames(difPur) <- paste0("Item", seq_len(ncol(difPur)))
    }

    RES <- list(
      Stat = stats1, p.value = pval1,
      lmPar = lmPar, lmSe = lmSe,
      parM0 = prov1$parM0, seM0 = prov1$seM0,
      covM0 = prov1$covM0, covM1 = prov1$covM1,
      deltaR2 = prov1$deltaR2, alpha = alpha, thr = Q, DIFitems = DIFitems,
      member.type = member.type, match = prov1$match,
      type = type, p.adjust.method = p.adjust.method,
      adjusted.p = adjusted.p, purification = purify,
      nrPur = nrPur, puriadjType = puriadjType,
      difPur = difPur, convergence = noLoop,
      names = colnames(DATA), anchor.names = NULL,
      criterion = criterion, save.output = save.output, output = output,
      Data = DATA, group = GROUP
    )
  }

  class(RES) <- "Continuous"
  if (save.output) {
    wd <- if (length(output) >= 2L && output[2] != "default") output[2] else paste0(getwd(), "/")
    fileName <- paste0(wd, output[1], ".txt")
    capture.output(RES, file = fileName)
  }
  RES
}

#' @export
print.Continuous <- function(x, ...) {
  res <- x
  cat("\n")

  ## --- Precompute ofted used values ---
  type_msg <- switch(res$type,
                     both  = " both types of ",
                     nudif = " nonuniform ",
                     udif  = " uniform ")

  test_msg <- switch(res$criterion,
                     F = "F-test",
                     W = "Wald test")

  match_msg <- switch(res$match[1],
                      score     = "test score",
                      zscore    = "standardized test score",
                      restscore = "test score without currently tested item",
                      `__other__` = "specified matching variable")
  ## item names
  item_names <- if (!is.null(res$names)) res$names else paste0("Item", seq_along(res$Stat))
  ## index of valid items
  itk <- if (is.null(res$anchor.names) | !res$match %in% c("score", "zscore"))
    seq_along(res$Stat)
  else
    which(!is.na(res$Stat))

  ## --- HEADER ---
  cat("Detection of", type_msg, "Differential Item Functioning\n",
      "using linear regression models for continuous items\n", sep = "")

  ## --- SUBMODEL TEST ---
  cat("with ", test_msg, " of submodel\n\n", sep = "")

  ## --- PURIFICATION ---
  pur_enabled <- res$purification &&
    is.null(res$anchor.names) &&
    res$match %in% c("score", "zscore")

  cat("Item purification ", if (pur_enabled) "" else "not ", "enabled\n", sep = "")

  ## --- PURIFICATION DETAILS ---
  if (pur_enabled) {
    word <- if (res$nrPur <= 1) " iteration" else " iterations"

    if (!res$convergence) {
      cat("WARNING: no item purification convergence after ",
          res$nrPur, word, "\n", sep = "")

      loop <- colSums(t(res$difPur[-1, , drop = FALSE]) ==
                        res$difPur[1, ])  ## vectorized

      if (max(loop) != length(res$Stat)) {
        cat("(Note: no loop detected in less than ",
            res$nrPur, word, ")\n", sep = "")
      } else {
        loop_len <- min(which(loop == length(res$Stat)))
        cat("(Note: loop of length ", loop_len,
            " in the item purification process)\n", sep = "")
      }

      cat("WARNING: following results based on the last iteration of the purification\n\n")
    } else {
      cat("Convergence reached after ", res$nrPur, word, "\n\n", sep = "")
    }
  } else {
    cat("\n")
  }

  ## --- MATCHING VARIABLE ---
  if (res$match[1] %in% c("score", "zscore", "restscore"))
    cat("Matching variable: ", match_msg, "\n\n", sep = "")
  else
    cat("Matching variable: specified matching variable\n\n")

  ## --- ANCHOR ITEMS ---
  if (is.null(res$anchor.names) | !res$match %in% c("score", "zscore")) {
    cat("No set of anchor items was provided\n\n")
  } else {
    cat("Anchor items (provided by the user):\n")
    mm <- if (is.numeric(res$anchor.names)) item_names[res$anchor.names] else res$anchor.names
    print(matrix(mm, ncol = 1, dimnames = list(rep("", length(mm)), "")), quote = FALSE)
    cat("\n\n")
  }

  ## --- P-VALUE ADJUSTMENT ---
  if (is.null(res$p.adjust.method)) {
    cat("No p-value adjustment for multiple comparisons\n\n")
  } else {

    pAdjMeth <- switch(res$p.adjust.method,
                       bonferroni = "Bonferroni",
                       holm       = "Holm",
                       hochberg   = "Hochberg",
                       hommel     = "Hommel",
                       BH         = "Benjamini-Hochberg",
                       BY         = "Benjamini-Yekutieli")

    cat("Multiple comparisons made with ", pAdjMeth,
        " adjustement of p-values\n", sep = "")

    if (res$purification) {
      cat("Multiple comparison applied after ",
          ifelse(res$puriadjType == "simple", "", "each iteration of "),
          "item purification \n\n", sep = "")
    } else cat("\n")
  }

  ## --- DIF STATISTICS TABLE ---
  cat("Linear model regression DIF statistic:\n\n")

  pval <- res$p.value
  symb <- symnum(if (is.null(res$p.adjust.method)) pval else res$adjusted.p,
                 c(0, 0.001, 0.01, 0.05, 0.1, 1),
                 symbols = c("***", "**", "*", ".", ""))

  m1 <- cbind(
    round(res$Stat[itk], 4),
    round(pval[itk], 4)
  )
  if (!is.null(res$p.adjust.method))
    m1 <- cbind(m1, round(res$adjusted.p[itk], 4))

  m1 <- noquote(cbind(format(m1, justify = "right"), symb[itk]))
  rownames(m1) <- item_names[itk]
  colnames(m1) <- c("Stat.", "P-value", if (!is.null(res$p.adjust.method)) "Adj. P", "")

  print(m1)
  cat("\nSignif. codes: 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1\n\n")

  ## --- THRESHOLDS ---
  cat("Detection threshold: ", round(res$thr, 4),
      " (significance level: ", res$alpha, ")\n\n", sep = "")

  ## --- DETECTED ITEMS ---
  if (is.character(res$DIFitems)) {
    cat("Items detected as DIF items: ", res$DIFitems, "\n\n", sep = "")
  } else {
    msg <- switch(res$type,
                  both = " ",
                  nudif = " nonuniform ",
                  udif = " uniform ")
    cat("Items detected as", msg, "DIF items:\n", sep = "")

    mm <- matrix(item_names[res$DIFitems], ncol = 1,
                 dimnames = list(rep("", length(res$DIFitems)), ""))

    print(mm, quote = FALSE)
    cat("\n\n")
  }

  ## --- EFFECT SIZE ---
  cat("Effect size (R^2):\n\n")

  r2 <- round(res$deltaR2, 4)
  symb1 <- symnum(r2, c(0, 0.02, .13, .26, 1), symbols = c("negligible", "small", "moderate", "larg"))

  matR2 <- noquote(cbind(format(r2[itk], justify = "right"), symb1[itk]))
  rownames(matR2) <- item_names[itk]
  colnames(matR2) <- c("R^2", "Cohen")

  print(matR2)
  cat("\nEffect size thresholds:\n Cohen (1988): 'negligible' 0.02 'small' 0.13 'moderate' 0.26 'large' 1\n")

  ## --- OUTPUT SAVING ---
  if (!res$save.output) {
    cat("\nOutput was not captured!\n")
  } else {
    wd <- if (res$output[2] == "default") paste0(getwd(), "/") else res$output[2]
    fileName <- paste0(wd, res$output[1], ".txt")
    cat("\nOutput was captured and saved into file\n '", fileName, "'\n\n", sep = "")
  }

  invisible(x)
}
