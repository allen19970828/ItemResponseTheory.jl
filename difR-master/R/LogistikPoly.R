#' @importFrom VGAM vglm propodds
#' @importFrom DescTools PseudoR2
#' @importFrom stats coef vcov deviance
#' @export
LogistikPoly <- function(data, member, member.type = "group", match = "score",
                         anchor = 1:ncol(data), type = "both", criterion = "LRT",
                         all.cov = FALSE) {

  dev <- R2full <- R2simple <- deltaR <- NULL
  max_cats <- sapply(data, function(x) length(unique(na.omit(x))))
  max_intercepts <- max(max_cats) - 1
  mFull <- mSimple <- seFull <- seSimple <- matrix(0, ncol(data), max_intercepts + 3)
  cov.matM0 <- cov.matM1 <- if (all.cov) vector("list", ncol(data)) else NULL

  GROUP <- if (member.type == "group") as.factor(member) else member

  for (item in 1:ncol(data)) {
    item_cat <- length(unique(na.omit(data[, item])))
    item_intercepts <- item_cat - 1

    if (match[1] == "score") {
      data2 <- data[, anchor, drop = FALSE]
      if (!(item %in% anchor)) data2 <- cbind(data2, data[, item])
      SCORES <- rowSums(data2, na.rm = TRUE)

    } else if (match[1] == "restscore") {
      data2 <- data
      items_for_score <- setdiff(anchor, item)
      if (length(items_for_score) == 0) {
        SCORES <- rep(0, nrow(data))
      } else {
        SCORES <- rowSums(data[, items_for_score, drop = FALSE], na.rm = TRUE)
      }

    } else {
      SCORES <- match
      data2 <- data
    }

    ITEM <- data[, item]

    # ----- modèles complets / réduits -----
    m0 <- switch(
      type,
      both  = vglm(ITEM ~ SCORES * GROUP, family = propodds, data = data2, model = TRUE),
      udif  = vglm(ITEM ~ SCORES + GROUP,   family = propodds, data = data2, model = TRUE),
      nudif = vglm(ITEM ~ SCORES * GROUP,   family = propodds, data = data2, model = TRUE)
    )

    m1 <- switch(
      type,
      both  = vglm(ITEM ~ SCORES,          family = propodds, data = data2, model = TRUE),
      udif  = vglm(ITEM ~ SCORES,          family = propodds, data = data2, model = TRUE),
      nudif = vglm(ITEM ~ SCORES + GROUP,  family = propodds, data = data2, model = TRUE)
    )

    # ----- statistique DIF -----
    if (criterion == "LRT") {
      dev[item] <- deviance(m1) - deviance(m0)

    } else if (criterion == "Wald") {
      coef_m0 <- stats::coef(m0)
      vcov_m0 <- stats::vcov(m0)
      idx <- switch(
        type,
        udif  = length(coef_m0),
        nudif = length(coef_m0),
        both  = (length(coef_m0) - 1):length(coef_m0)
      )
      C <- diag(length(coef_m0))[idx, , drop = FALSE]
      W <- t(C %*% coef_m0) %*% solve(C %*% vcov_m0 %*% t(C)) %*% (C %*% coef_m0)
      dev[item] <- as.numeric(W)

    } else {
      stop("'criterion' must be either 'LRT' or 'Wald'")
    }

    R2full[item]   <- PseudoR2(m0, which = "McKelveyZavoina")
    R2simple[item] <- PseudoR2(m1, which = "McKelveyZavoina")
    deltaR[item]   <- R2full[item] - R2simple[item]

    mFull[item, 1:length(stats::coef(m0))]   <- stats::coef(m0)
    mSimple[item, 1:length(stats::coef(m1))] <- stats::coef(m1)
    seFull[item, 1:length(stats::coef(m0))]  <- sqrt(diag(stats::vcov(m0)))
    seSimple[item, 1:length(stats::coef(m1))]<- sqrt(diag(stats::vcov(m1)))

    if (all.cov) {
      cov.matM0[[item]] <- stats::vcov(m0)
      cov.matM1[[item]] <- stats::vcov(m1)
    }
  }

  col_labels <- c(paste0(1:max_intercepts, "(Intercept)"), "SCORE", "GROUP", "SCORE:GROUP")
  colnames(mFull) <- colnames(mSimple) <- colnames(seFull) <- colnames(seSimple) <- col_labels

  list(
    stat     = dev,
    R2M0     = R2full,
    R2M1     = R2simple,
    deltaR2  = deltaR,
    parM0    = mFull,
    parM1    = mSimple,
    seM0     = seFull,
    seM1     = seSimple,
    cov.M0   = cov.matM0,
    cov.M1   = cov.matM1,
    criterion= criterion,
    member.type = member.type,
    match    = match[1]
  )
}

##########################################################################

#' @importFrom stats qchisq pchisq p.adjust
#' @importFrom utils capture.output
#' @export
difPolyLogistic <- function (Data, group, focal.name, anchor = NULL, member.type = "group",    
    match = "score", type = "both", criterion = "LRT", alpha = 0.05, all.cov=FALSE,
    purify = FALSE, nrIter = 10, p.adjust.method = NULL, save.output = FALSE, 
    output = c("out", "default")) 
{
    if (member.type != "group" & member.type != "cont") 
        stop("'member.type' must be either 'group' or 'cont'", call. = FALSE)
    if (purify & match[1] != "score") 
        stop("purification not allowed when matching variable is not 'score'", call. = FALSE)

    internalLog <- function() {
        if (length(group) == 1) {
            if (is.numeric(group)) {
                gr <- Data[, group]
                DATA <- Data[, -group]
            } else {
                gr <- Data[, colnames(Data) == group]
                DATA <- Data[, colnames(Data) != group]
            }
        } else {
            gr <- group
            DATA <- Data
        }

        if (member.type == "group") {
            # Correction ici : détecter si gr est déjà binaire
            if (length(unique(gr)) == 2 && all(sort(unique(gr)) == c(0, 1))) {
                Group <- gr
            } else {
                Group <- rep(0, length(gr))
                Group[gr == focal.name] <- 1
            }
        } else Group <- gr

        Q <- switch(type, both = qchisq(1 - alpha, 2), udif = qchisq(1 - alpha, 1), nudif = qchisq(1 - alpha, 1))
        DDF <- ifelse(type == "both", 2, 1)

        if (!is.null(anchor)) {
            ANCHOR <- if (is.numeric(anchor)) anchor else which(colnames(DATA) %in% anchor)
            dif.anchor <- anchor
        } else {
            ANCHOR <- 1:ncol(DATA)
            dif.anchor <- NULL
        }

#' @keywords internal
#' @noRd
        buildResult <- function(PROV, STATS, deltaR2, Q, Group) {
            PVAL <- 1 - pchisq(STATS, DDF)
            logitPar <- matrix(NA, nrow = ncol(DATA), ncol = ncol(PROV$parM1))
            logitSe  <- matrix(NA, nrow = ncol(DATA), ncol = ncol(PROV$seM1))
            if (max(STATS, na.rm = TRUE) <= Q) {
                DIFitems <- "No DIF item detected"
                logitPar <- PROV$parM1
                logitSe <- PROV$seM1
            } else {
                DIFitems <- which(STATS > Q)
                logitPar <- PROV$parM1
                logitSe  <- PROV$seM1
                for (idif in DIFitems) {
                    logitPar[idif, ] <- PROV$parM0[idif, ]
                    logitSe[idif, ]  <- PROV$seM0[idif, ]
                }
            }

            list(LogistikPoly = STATS, p.value = PVAL, logitPar = logitPar,
                 logitSe = logitSe, parM0 = PROV$parM0, seM0 = PROV$seM0,
                 cov.M0 = PROV$cov.M0, cov.M1 = PROV$cov.M1,
                 deltaR2 = deltaR2, alpha = alpha, thr = Q, DIFitems = DIFitems,
                 member.type = member.type, match = PROV$match, type = type,
                 p.adjust.method = p.adjust.method, adjusted.p = NULL,
                 purification = purify, names = colnames(DATA),
                 anchor.names = dif.anchor, criterion = criterion,
                 save.output = save.output, output = output)
        }

        if (!purify | match[1] != "score" | !is.null(anchor)) {
            PROV <- LogistikPoly(DATA, Group, member.type = member.type,
                                 match = match, type = type, criterion = criterion,
                                 anchor = ANCHOR, all.cov = all.cov)
            return(buildResult(PROV, PROV$stat, PROV$deltaR2, Q, Group))
        } else {
            nrPur <- 0
            difPur <- NULL
            noLoop <- FALSE
            prov1 <- LogistikPoly(DATA, Group, member.type = member.type,
                                  match = match, type = type, criterion = criterion,
                                  all.cov = all.cov)
            stats1 <- prov1$stat
            deltaR2 <- prov1$deltaR2
            if (max(stats1, na.rm = TRUE) <= Q) {
                return(buildResult(prov1, stats1, deltaR2, Q, Group))
            } else {
                dif <- which(stats1 > Q)
                difPur <- matrix(0, nrow = 1, ncol = ncol(DATA))
                difPur[1, dif] <- 1
                repeat {
                    if (nrPur >= nrIter) break
                    nrPur <- nrPur + 1
                    nodif <- setdiff(1:ncol(DATA), dif)
                    prov2 <- LogistikPoly(DATA, Group, anchor = nodif,
                                          member.type = member.type, match = match,
                                          type = type, criterion = criterion, all.cov = all.cov)
                    stats2 <- prov2$stat
                    deltaR2 <- prov2$deltaR2
                    dif2 <- which(stats2 > Q)
                    difPur <- rbind(difPur, rep(0, ncol(DATA)))
                    difPur[nrPur + 1, dif2] <- 1
                    if (identical(sort(dif), sort(dif2))) {
                        noLoop <- TRUE
                        break
                    }
                    dif <- dif2
                }
                RES <- buildResult(prov2, stats2, deltaR2, Q, Group)
                RES$nrPur <- nrPur
                RES$difPur <- difPur
                RES$convergence <- noLoop
                return(RES)
            }
        }
    }

    resToReturn <- internalLog()

    if (!is.null(p.adjust.method)) {
        df <- ifelse(type == "both", 2, 1)
        pval <- 1 - pchisq(resToReturn$LogistikPoly, df)
        resToReturn$adjusted.p <- p.adjust(pval, method = p.adjust.method)
        if (min(resToReturn$adjusted.p, na.rm = TRUE) > alpha) 
            resToReturn$DIFitems <- "No DIF item detected"
        else 
            resToReturn$DIFitems <- which(resToReturn$adjusted.p < alpha)
    }

    class(resToReturn) <- "Logistic"
    if (save.output) {
        wd <- if (output[2] == "default") paste0(getwd(), "/") else output[2]
        fileName <- paste0(wd, output[1], ".txt")
        capture.output(resToReturn, file = fileName)
    }

    return(resToReturn)
}

###############################################

#' @export
plot.Logistic.Poly <- function(x, plot = "lrStat", item = 1, itemFit = "best", pch = 8,
                          number = TRUE, col = "red", colIC = rep("black", 2),
                          ltyIC = c(1, 2), save.plot = FALSE,
                          save.options = c("plot", "default", "pdf"),
                          group.names = NULL, ...) {
  internalLog <- function() {
    res <- x
    plotType <- switch(plot, lrStat = 1, itemCurve = 2)
    if (is.null(plotType)) stop("Invalid plot type")

    if (plotType == 1) {
      ylim_max <- max(c(res$LogistikPoly, res$thr), na.rm = TRUE) + 1
      if (!number) {
        plot(res$LogistikPoly, xlab = "Item", ylab = paste(x$criterion, " statistic"),
             ylim = c(0, ylim_max), pch = pch,
             main = paste("Logistic regression (", x$criterion, " statistic)", sep = ""))
        if (!is.character(res$DIFitems))
          points(res$DIFitems, res$LogistikPoly[res$DIFitems], pch = pch, col = col)
      } else {
        plot(res$LogistikPoly, xlab = "Item", ylab = paste(x$criterion, " statistic"),
             ylim = c(0, ylim_max), col = "white",
             main = paste("Logistic regression (", x$criterion, " statistic)", sep = ""))
        text(1:length(res$LogistikPoly), res$LogistikPoly, 1:length(res$LogistikPoly))
        if (!is.character(res$DIFitems))
          text(res$DIFitems, res$LogistikPoly[res$DIFitems], res$DIFitems, col = col)
      }
      abline(h = res$thr)
    } else {
      it <- ifelse(is.character(item) | is.factor(item),
                   which(res$names == item), item)
      if (is.na(res$logitPar[it, 1])) stop("Selected item is an anchor item!", call. = FALSE)
      logitPar <- if (itemFit == "best") res$logitPar[it, ] else res$parM0[it, ]
      s <- seq(0, max(res$LogistikPoly, na.rm = TRUE), length.out = 100)
      expit <- function(t) exp(t) / (1 + exp(t))
      mainName <- ifelse(is.character(res$names[it]), res$names[it], paste("Item ", it))
      plot(s, expit(logitPar[1] + logitPar[2] * s),
           col = colIC[1], type = "l", lty = ltyIC[1],
           ylim = c(0, 1), xlab = "Score", ylab = "Probability",
           main = mainName)
      if (itemFit == "null" || (itemFit == "best" && !is.character(res$DIFitems) && it %in% res$DIFitems)) {
        lines(s, expit(logitPar[1] + logitPar[2] * s + logitPar[3] + logitPar[4] * s),
              col = colIC[2], lty = ltyIC[2])
        legnames <- if (is.null(group.names)) c("Reference", "Focal") else group.names
        legend("bottomright", legend = legnames, col = colIC, lty = ltyIC, bty = "n")
      }
    }
  }

  if (save.plot) {
    plotype <- switch(save.options[3], pdf = 1, jpeg = 2, NULL)
    if (is.null(plotype)) {
      cat("Invalid plot type. Must be 'pdf' or 'jpeg'. Plot not saved.
")
    } else {
      wd <- if (save.options[2] == "default") paste0(getwd(), "/") else save.options[2]
      ext <- switch(plotype, "1" = ".pdf", "2" = ".jpg")
      fileName <- paste0(wd, save.options[1], ext)
      if (plotype == 1) {
        pdf(file = fileName); internalLog(); dev.off()
      } else {
        jpeg(filename = fileName); internalLog(); dev.off()
      }
      cat("Plot saved to '", fileName, "'
")
    }
  } else {
    internalLog()
  }
}

##############################################

#' @export
print.Logistic.Poly<-function (x, ...) 
{
    res <- x
    cat("\n")
    mess1 <- switch(res$type, both = " both types of ", nudif = " nonuniform ", 
        udif = " uniform ")
    cat("Detection of", mess1, "Differential Item Functioning", 
        "\n", "using ordinal logistic regression method, ", sep = "")
    if (res$purification & is.null(res$anchor.names) & res$match == 
        "score") 
        pur <- "with "
    else pur <- "without "
    cat(pur, "item purification", "\n", sep = "")
    cat("and with ", res$criterion, " DIF statistic", "\n", "\n", 
        sep = "")
    if (res$purification & is.null(res$anchor.names) & res$match == 
        "score") {
        if (res$nrPur <= 1) 
            word <- " iteration"
        else word <- " iterations"
        if (!res$convergence) {
            cat("WARNING: no item purification convergence after ", 
                res$nrPur, word, "\n", sep = "")
            loop <- NULL
            for (i in 1:res$nrPur) loop[i] <- sum(res$difPur[1, 
                ] == res$difPur[i + 1, ])
            if (max(loop) != length(res$LogistikPoly)) 
                cat("(Note: no loop detected in less than ", 
                  res$nrPur, word, ")", "\n", sep = "")
            else cat("(Note: loop of length ", min((1:res$nrPur)[loop == 
                length(res$LogistikPoly)]), " in the item purification process)", 
                "\n", sep = "")
            cat("WARNING: following results based on the last iteration of the purification", 
                "\n", "\n")
        }
        else cat("Convergence reached after ", res$nrPur, word, 
            "\n", "\n", sep = "")
    }
    if (res$match[1] == "score") 
        cat("Matching variable: test score", "\n", "\n")
    else cat("Matching variable: specified matching variable", 
        "\n", "\n")
    if (is.null(res$anchor.names) | res$match != "score") {
        itk <- 1:length(res$LogistikPoly)
        cat("No set of anchor items was provided", "\n", "\n")
    }
    else {
        itk <- (1:length(res$LogistikPoly))[!is.na(res$LogistikPoly)]
        cat("Anchor items (provided by the user):", "\n")
        if (is.numeric(res$anchor.names)) 
            mm <- res$names[res$anchor.names]
        else mm <- res$anchor.names
        mm <- cbind(mm)
        rownames(mm) <- rep("", nrow(mm))
        colnames(mm) <- ""
        print(mm, quote = FALSE)
        cat("\n", "\n")
    }
    if (is.null(res$p.adjust.method)) 
        cat("No p-value adjustment for multiple comparisons", 
            "\n", "\n")
    else {
        pAdjMeth <- switch(res$p.adjust.method, bonferroni = "Bonferroni", 
            holm = "Holm", hochberg = "Hochberg", hommel = "Hommel", 
            BH = "Benjamini-Hochberg", BY = "Benjamini-Yekutieli")
        cat("Multiple comparisons made with", pAdjMeth, "adjustement of p-values", 
            "\n", "\n")
    }
    cat("Logistic regression DIF statistic:", "\n", "\n")
    df <- switch(res$type, both = 2, udif = 1, nudif = 1)
    pval <- round(1 - pchisq(res$LogistikPoly, df), 4)
if (is.null(res$p.adjust.method)) symb <- symnum(pval, c(0, 0.001, 0.01, 0.05, 0.1, 1), symbols = c("***", 
        "**", "*", ".", ""))
else symb <- symnum(res$adjusted.p, c(0, 0.001, 0.01, 0.05, 0.1, 1), symbols = c("***", 
        "**", "*", ".", ""))
    m1 <- cbind(round(res$LogistikPoly[itk], 4), pval[itk])
if (!is.null(res$p.adjust.method)) m1<-cbind(m1,round(res$adjusted.p[itk],4))
    m1 <- noquote(cbind(format(m1, justify = "right"), symb[itk]))
    if (!is.null(res$names)) 
        rownames(m1) <- res$names[itk]
    else {
        rn <- NULL
        for (i in 1:nrow(m1)) rn[i] <- paste("Item", i, sep = "")
        rownames(m1) <- rn[itk]
    }
    con <- c("Stat.", "P-value")
    if (!is.null(res$p.adjust.method)) 
        con <- c(con, "Adj. P")
    con <- c(con, "")
    colnames(m1) <- con
    print(m1)
    cat("\n")
    cat("Signif. codes: 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 ", 
        "\n")
    cat("\n", "Detection threshold: ", round(res$thr, 4), " (significance level: ", 
        res$alpha, ")", "\n", "\n", sep = "")
    if (is.character(res$DIFitems)) 
        cat("Items detected as DIF items:", res$DIFitems, "\n", 
            "\n")
    else {
        mess2 <- switch(res$type, both = " ", nudif = " nonuniform ", 
            udif = " uniform ")
        cat("Items detected as", mess2, "DIF items:", "\n", sep = "")
        if (!is.null(res$names)) 
            m2 <- res$names
        else {
            rn <- NULL
            for (i in 1:length(res$LogistikPoly)) rn[i] <- paste("Item", 
                i, sep = "")
            m2 <- rn
        }
        m2 <- cbind(m2[res$DIFitems])
        rownames(m2) <- rep("", nrow(m2))
        colnames(m2) <- ""
        print(m2, quote = FALSE)
        cat("\n", "\n")
    }
    cat("Effect size (McKelvey & Zavoina's (1975) R^2):", "\n", "\n")
    cat("Effect size code:", "\n")
    cat(" 'A': negligible effect", "\n")
    cat(" 'B': moderate effect", "\n")
    cat(" 'C': large effect", "\n", "\n")
    r2 <- round(res$deltaR2, 4)
    symb1 <- symnum(r2, c(0, 0.13, 0.26, 1), symbols = c("A", 
        "B", "C"))
    symb2 <- symnum(r2, c(0, 0.035, 0.07, 1), symbols = c("A", 
        "B", "C"))
    matR2 <- noquote(cbind(format(r2[itk], justify = "right"), 
        symb1[itk], symb2[itk]))
    if (!is.null(res$names)) 
        rownames(matR2) <- res$names[itk]
    else {
        rn <- NULL
        for (i in 1:length(r2)) rn[i] <- paste("Item", i, sep = "")
        rownames(matR2) <- rn[itk]
    }
    colnames(matR2) <- c("R^2", "ZT", "JG")
    print(matR2[,1:2]) # Report only Zumbo & Thomas
    cat("\n")
    cat("Effect size codes:", "\n")
    cat(" Zumbo & Thomas (ZT): 0 'A' 0.13 'B' 0.26 'C' 1", "\n")
    # cat(" Jodoin & Gierl (JG): 0 'A' 0.035 'B' 0.07 'C' 1", "\n") # Check if useful for ordinal items
    if (!x$save.output) 
        cat("\n", "Output was not captured!", "\n")
    else {
        if (x$output[2] == "default") 
            wd <- paste(getwd(), "/", sep = "")
        else wd <- x$output[2]
        fileName <- paste(wd, x$output[1], ".txt", sep = "")
        cat("\n", "Output was captured and saved into file", 
            "\n", " '", fileName, "'", "\n", "\n", sep = "")
    }
}