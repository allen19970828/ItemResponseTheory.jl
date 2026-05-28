#' @export
difLogistic <- function(Data, group, focal.name, anchor = NULL, member.type = "group",
                        match = "score", type = "both", criterion = "LRT",
                        alpha = 0.05, all.cov = FALSE, purify = FALSE, nrIter = 10,
                        p.adjust.method = NULL, puriadjType = "simple",
                        save.output = FALSE, output = c("out", "default")) {
  if (member.type != "group" & member.type != "cont") {
    stop("'member.type' must be either 'group' or 'cont'",
      call. = FALSE
    )
  }
  if (purify & match[1] != "score") {
    stop("purification not allowed when matching variable is not 'score'",
      call. = FALSE
    )
  }
  if (!is.character(puriadjType) || !puriadjType %in% c("simple", "combined")) {
    stop("'puriadjType' can be either 'simple' or 'combined'.",
         call. = FALSE
    )
  }
  internalLog <- function() {
    if (length(group) == 1) {
      if (is.numeric(group)) {
        gr <- Data[, group]
        DATA <- Data[, (1:ncol(Data)) != group]
        colnames(DATA) <- colnames(Data)[(1:ncol(Data)) != group]
      } else {
        gr <- Data[, colnames(Data) == group]
        DATA <- Data[, colnames(Data) != group]
        colnames(DATA) <- colnames(Data)[colnames(Data) != group]
      }
    } else {
      gr <- group
      DATA <- Data
    }
    if (member.type == "group") {
      Group <- rep(0, nrow(DATA))
      Group[gr == focal.name] <- 1
    } else {
      Group <- gr
    }
    Q <- switch(type,
      both = qchisq(1 - alpha, 2),
      udif = qchisq(1 - alpha, 1),
      nudif = qchisq(1 - alpha, 1)
    )
    if (!is.null(anchor)) {
      dif.anchor <- anchor
      if (is.numeric(anchor)) {
        ANCHOR <- anchor
      } else {
        ANCHOR <- NULL
        for (i in 1:length(anchor)) {
          ANCHOR[i] <- (1:ncol(DATA))[colnames(DATA) == anchor[i]]
        }
      }
    } else {
      ANCHOR <- 1:ncol(DATA)
      dif.anchor <- NULL
    }

    if (purify) {
      if (is.null(p.adjust.method)) {
        puri.adj.method <- "none"
        adj.method <- "none"
      } else {
        if (puriadjType == "simple") {
          puri.adj.method <- "none"
          adj.method <- p.adjust.method
        } else {
          puri.adj.method <- p.adjust.method
          adj.method <- p.adjust.method
        }
      }
    } else {
      adj.method <- ifelse(is.null(p.adjust.method), "none", p.adjust.method)
    }

    DDF <- ifelse(type == "both", 2, 1)

    if (!purify | match[1] != "score" | !is.null(anchor)) {
      PROV <- Logistik(DATA, Group,
        member.type = member.type,
        match = match, type = type, criterion = criterion,
        anchor = ANCHOR, all.cov = all.cov
      )
      STATS <- PROV$stat
      PVAL <- 1 - pchisq(STATS, DDF)
      P.ADJUST <- p.adjust(PVAL, method = adj.method)
      deltaR2 <- PROV$deltaR2

      logitPar <- PROV$parM1
      logitSe <- PROV$seM1

      if (min(P.ADJUST, na.rm = T) >= alpha) {
        DIFitems <- "No DIF item detected"
      } else {
        DIFitems <- which(P.ADJUST < alpha)
        logitPar[DIFitems, ] <- PROV$parM0[DIFitems, ]
        logitSe[DIFitems, ] <- PROV$seM0[DIFitems, ]
      }

      if (is.null(p.adjust.method)) {
        adjusted.p <- NULL
      } else {
        adjusted.p <- P.ADJUST
      }
      RES <- list(
        Logistik = STATS, p.value = PVAL, logitPar = logitPar,
        logitSe = logitSe, parM0 = PROV$parM0, seM0 = PROV$seM0,
        cov.M0 = PROV$cov.M0, cov.M1 = PROV$cov.M1, deltaR2 = deltaR2,
        alpha = alpha, thr = Q, DIFitems = DIFitems,
        member.type = member.type, match = PROV$match,
        type = type, p.adjust.method = p.adjust.method,
        adjusted.p = adjusted.p, purification = purify, names = colnames(DATA),
        anchor.names = dif.anchor, criterion = criterion,
        save.output = save.output, output = output,
        Data = DATA, group = Group
      )
      if (!is.null(anchor) & match[1] == "score") {
        RES$Logistik[ANCHOR] <- NA
        RES$logitPar[ANCHOR, ] <- NA
        RES$parM0[ANCHOR, ] <- NA
        RES$deltaR2[ANCHOR] <- NA
        for (i in 1:length(RES$DIFitems)) {
          if (sum(RES$DIFitems[i] == ANCHOR) == 1) {
            RES$DIFitems[i] <- NA
          }
        }
        RES$DIFitems <- RES$DIFitems[!is.na(RES$DIFitems)]
      }
    } else {
      nrPur <- 0
      difPur <- NULL
      noLoop <- FALSE
      prov1 <- Logistik(DATA, Group,
        member.type = member.type,
        match = match, type = type, criterion = criterion, all.cov = all.cov
      )
      stats1 <- prov1$stat
      pval1 <- 1 - pchisq(stats1, DDF)
      p.adjust1 <- p.adjust(pval1, method = puri.adj.method)
      deltaR2 <- prov1$deltaR2
      if (min(p.adjust1, na.rm = T) >= alpha) {
        DIFitems <- "No DIF item detected"
        logitPar <- prov1$parM1
        logitSe <- prov1$seM1
        noLoop <- TRUE
      } else {
        dif <- which(p.adjust1 < alpha)
        difPur <- rep(0, length(stats1))
        difPur[dif] <- 1
        repeat {
          if (nrPur >= nrIter) {
            break
          } else {
            nrPur <- nrPur + 1
            nodif <- NULL
            if (is.null(dif)) {
              nodif <- 1:ncol(DATA)
            } else {
              for (i in 1:ncol(DATA)) {
                if (sum(i == dif) == 0) {
                  nodif <- c(nodif, i)
                }
              }
            }
            prov2 <- Logistik(DATA, Group,
              anchor = nodif,
              member.type = member.type, match = match,
              type = type, criterion = criterion, all.cov = all.cov
            )
            stats2 <- prov2$stat
            pval2 <- 1 - pchisq(stats2, DDF)
            p.adjust2 <- p.adjust(pval2, method = puri.adj.method)
            deltaR2 <- prov2$deltaR2
            if (min(p.adjust2, na.rm = T) >= alpha) {
              dif2 <- NULL
            } else {
              dif2 <- which(p.adjust2 < alpha)
            }
            difPur <- rbind(difPur, rep(0, ncol(DATA)))
            difPur[nrPur + 1, dif2] <- 1
            dif <- sort(dif)
            dif2 <- sort(dif2)

            if (length(dif) != length(dif2)) {
              dif <- dif2
            } else {
              dif <- sort(dif)
              dif2 <- sort(dif2)
              if (all(dif == dif2)) {
                noLoop <- TRUE
                break
              } else {
                dif <- dif2
              }
            }
          }
        }
        prov1 <- prov2
        stats1 <- stats2
        pval1 <- 1 - pchisq(stats1, DDF)
        p.adjust1 <- p.adjust(pval1, method = adj.method)
        deltaR2 <- deltaR2
        logitPar <- prov1$parM1
        logitSe <- prov1$seM1

        if (min(p.adjust1, na.rm = T) >= alpha) {
          DIFitems <- "No DIF item detected"
        } else {
          DIFitems <- which(!is.na(stats1) & p.adjust1 < alpha)
          logitPar[DIFitems, ] <- prov1$parM0[DIFitems, ]
          logitSe[DIFitems, ] <- prov1$seM0[DIFitems, ]
        }
      }

      if (is.null(difPur) == FALSE) {
        ro <- co <- NULL
        for (ir in 1:nrow(difPur)) {
          ro[ir] <- paste("Step",
            ir - 1,
            sep = ""
          )
        }
        for (ic in 1:ncol(difPur)) {
          co[ic] <- paste("Item",
            ic,
            sep = ""
          )
        }
        rownames(difPur) <- ro
        colnames(difPur) <- co
      }
      if (is.null(p.adjust.method)) {
        adjusted.p <- NULL
      } else {
        adjusted.p <- p.adjust1
      }

      RES <- list(
        Logistik = stats1, p.value = pval1, logitPar = logitPar,
        logitSe = logitSe, parM0 = prov1$parM0, seM0 = prov1$seM0,
        cov.M0 = prov1$cov.M0, cov.M1 = prov1$cov.M1,
        deltaR2 = deltaR2, alpha = alpha, thr = Q, DIFitems = DIFitems,
        member.type = member.type, match = prov1$match,
        type = type, p.adjust.method = p.adjust.method,
        adjusted.p = adjusted.p, purification = purify, nrPur = nrPur, puriadjType = puriadjType,
        difPur = difPur, convergence = noLoop, names = colnames(DATA),
        anchor.names = NULL, criterion = criterion, save.output = save.output,
        output = output,
        Data = DATA, group = Group
      )
    }
    class(RES) <- "Logistic"
    return(RES)
  }
  resToReturn <- internalLog()
  if (save.output) {
    if (output[2] == "default") {
      wd <- paste(getwd(), "/", sep = "")
    } else {
      wd <- output[2]
    }
    fileName <- paste(wd, output[1], ".txt", sep = "")
    capture.output(resToReturn, file = fileName)
  }
  return(resToReturn)
}

#' @method plot Logistic
#' @rdname difLogistic
#'
#' @param x the result from a \code{"Logistik"} class object.
#' @param plot character: the type of plot, either \code{"lrStat"} (default)
#' or \code{"itemCurve"}. See \bold{Details}.
#' @param item numeric or character: either the number or the name of the item
#' for which logistic curves are plotted. Used only when \code{plot = "itemCurve"}.
#' @param itemFit character: the model to be selected for drawing the item
#' curves. Possible values are \code{"best"} (default) for drawing from the
#' best of the two models, and \code{"null"} for using fitted parameters of
#' the null model \eqn{M_0}. Not used if \code{"plot"} is \code{"lrStat"}. See
#' \bold{Details}.
#' @param pch,col type of usual \code{pch} and \code{col} graphical options.
#' @param number logical: should the item number identification be printed
#' (default is \code{TRUE}).
#' @param colIC,ltyIC vectors of two elements of the usual \code{col} and
#' \code{lty} arguments for logistic curves. Used only when
#' \code{plot = "itemCurve"}.
#' @param save.plot logical: should the plot be saved into a separate file?
#' (default is \code{FALSE}).
#' @param save.options character: a vector of three components. The first
#' component is the name of the output file, the second component is either
#' the file path or \code{"default"} (default value), and the third component
#' is the file extension, either \code{"pdf"} (default) or \code{"jpeg"}. See
#' \bold{Details}.
#' @param group.names either \code{NULL} (default) or a vector of two
#' character strings giving the names of the reference group and the focal
#' group (in this order) for display in the legend. Ignored if \code{plot} is
#' \code{"lrStat"}.
#' @param ... other generic parameters for the \code{plot} or the \code{print}
#' functions.
#'
#' @export
plot.Logistic <- function(
    x, plot = "lrStat", item = 1, itemFit = "best", pch = 8, number = TRUE,
    col = "red", colIC = rep("black", 2), ltyIC = c(1, 2), save.plot = FALSE,
    save.options = c("plot", "default", "pdf"), group.names = NULL, ...) {
  internalLog <- function() {
    res <- x
    plotType <- switch(plot,
      lrStat = 1,
      itemCurve = 2
    )
    if (is.null(plotType)) {
      return("Error: misspecified 'type' argument")
    } else {
      if (plotType == 1) {
        if (!number) {
          plot(res$Logistik, xlab = "Item", ylab = paste(x$criterion,
            " statistic",
            sep = ""
          ), ylim = c(0, max(c(
            res$Logistik,
            res$thr
          ) + 1, na.rm = TRUE)), pch = pch, main = paste("Logistic regression (",
            x$criterion, "statistic)",
            sep = ""
          ))
          if (!is.character(res$DIFitems)) {
            points(res$DIFitems, res$Logistik[res$DIFitems],
              pch = pch, col = col
            )
          }
        } else {
          plot(res$Logistik, xlab = "Item", ylab = paste(x$criterion,
            " statistic",
            sep = ""
          ), ylim = c(0, max(c(
            res$Logistik,
            res$thr
          ) + 1, na.rm = TRUE)), col = "white", main = paste("Logistic regression (",
            x$criterion, " statistic)",
            sep = ""
          ))
          text(
            1:length(res$Logistik), res$Logistik,
            1:length(res$Logistik)
          )
          if (!is.character(res$DIFitems)) {
            text(res$DIFitems, res$Logistik[res$DIFitems],
              res$DIFitems,
              col = col
            )
          }
        }
        abline(h = res$thr)
      } else {
        it <- ifelse(is.character(item) | is.factor(item),
          (1:length(res$names))[res$names == item], item
        )
        if (is.na(res$logitPar[it, 1])) stop("Selected item is an anchor item!", call. = FALSE)
        if (itemFit == "best") {
          logitPar <- res$logitPar[it, ]
        } else {
          logitPar <- res$parM0[it, ]
        }
        s <- seq(0, length(res$Logistik), 0.1)
        expit <- function(t) exp(t) / (1 + exp(t))
        mainName <- ifelse(is.character(res$names[it]),
          res$names[it], paste("Item ", it, sep = "")
        )
        plot(s, expit(logitPar[1] + logitPar[2] * s),
          col = colIC[1], type = "l", lty = ltyIC[1],
          ylim = c(0, 1), xlab = "Score", ylab = "Probability",
          main = mainName
        )
        if (itemFit == "null" | (itemFit == "best" &
          !is.character(res$DIFitems) & sum(res$DIFitems ==
          it) == 1)) {
          lines(s, expit(logitPar[1] + logitPar[2] *
            s + logitPar[3] + logitPar[4] * s),
          col = colIC[2],
          lty = ltyIC[2]
          )
          if (is.null(group.names)) {
            legnames <- c("Reference", "Focal")
          } else {
            legnames <- group.names
          }
          legend(0, 1, legnames,
            col = colIC,
            lty = ltyIC, bty = "n"
          )
        }
      }
    }
  }
  internalLog()
  if (save.plot) {
    plotype <- NULL
    if (save.options[3] == "pdf") {
      plotype <- 1
    }
    if (save.options[3] == "jpeg") {
      plotype <- 2
    }
    if (is.null(plotype)) {
      cat(
        "Invalid plot type (should be either 'pdf' or 'jpeg').",
        "\n", "The plot was not captured!", "\n"
      )
    } else {
      if (save.options[2] == "default") {
        wd <- paste(getwd(), "/", sep = "")
      } else {
        wd <- save.options[2]
      }
      fileName <- paste(wd, save.options[1], switch(plotype,
        `1` = ".pdf",
        `2` = ".jpg"
      ), sep = "")
      if (plotype == 1) {
        {
          pdf(file = fileName)
          internalLog()
        }
        dev.off()
      }
      if (plotype == 2) {
        {
          jpeg(filename = fileName)
          internalLog()
        }
        dev.off()
      }
      cat("The plot was captured and saved into", "\n",
        " '", fileName, "'", "\n", "\n",
        sep = ""
      )
    }
  } else {
    cat("The plot was not captured!", "\n", sep = "")
  }
}

#' @export
print.Logistic <- function(x, ...) {
  res <- x
  cat("\n")
  mess1 <- switch(res$type,
    both = " both types of ",
    nudif = " nonuniform ",
    udif = " uniform "
  )
  cat("Detection of", mess1, "Differential Item Functioning",
    "\n", "using Logistic regression method, ",
    sep = ""
  )
  if (res$purification & is.null(res$anchor.names) & res$match ==
    "score") {
    pur <- "with "
  } else {
    pur <- "without "
  }
  cat(pur, "item purification", "\n", sep = "")
  cat("and with ", res$criterion, " DIF statistic", "\n", "\n",
    sep = ""
  )
  if (res$purification & is.null(res$anchor.names) & res$match ==
    "score") {
    if (res$nrPur <= 1) {
      word <- " iteration"
    } else {
      word <- " iterations"
    }
    if (!res$convergence) {
      cat("WARNING: no item purification convergence after ",
        res$nrPur, word, "\n",
        sep = ""
      )
      loop <- NULL
      for (i in 1:res$nrPur) loop[i] <- sum(res$difPur[1, ] == res$difPur[i + 1, ])
      if (max(loop) != length(res$Logistik)) {
        cat("(Note: no loop detected in less than ",
          res$nrPur, word, ")", "\n",
          sep = ""
        )
      } else {
        cat("(Note: loop of length ", min((1:res$nrPur)[loop ==
          length(res$Logistik)]), " in the item purification process)",
        "\n",
        sep = ""
        )
      }
      cat(
        "WARNING: following results based on the last iteration of the purification",
        "\n", "\n"
      )
    } else {
      cat("Convergence reached after ", res$nrPur, word,
        "\n", "\n",
        sep = ""
      )
    }
  }
  if (res$match[1] == "score") {
    cat("Matching variable: test score", "\n", "\n")
  } else {
    cat(
      "Matching variable: specified matching variable",
      "\n", "\n"
    )
  }
  if (is.null(res$anchor.names) | res$match != "score") {
    itk <- 1:length(res$Logistik)
    cat("No set of anchor items was provided", "\n", "\n")
  } else {
    itk <- (1:length(res$Logistik))[!is.na(res$Logistik)]
    cat("Anchor items (provided by the user):", "\n")
    if (is.numeric(res$anchor.names)) {
      mm <- res$names[res$anchor.names]
    } else {
      mm <- res$anchor.names
    }
    mm <- cbind(mm)
    rownames(mm) <- rep("", nrow(mm))
    colnames(mm) <- ""
    print(mm, quote = FALSE)
    cat("\n", "\n")
  }
  if (is.null(res$p.adjust.method)) {
    cat(
      "No p-value adjustment for multiple comparisons",
      "\n", "\n"
    )
  } else {
    pAdjMeth <- switch(res$p.adjust.method,
      bonferroni = "Bonferroni",
      holm = "Holm",
      hochberg = "Hochberg",
      hommel = "Hommel",
      BH = "Benjamini-Hochberg",
      BY = "Benjamini-Yekutieli"
    )
    cat(
      "Multiple comparisons made with", pAdjMeth, "adjustement of p-values\n"
    )
    if (res$purification) {
      cat(paste0(
        "Multiple comparison applied after ",
        ifelse(res$puriadjType == "simple", "", "each iteration of "),
        "item purification \n\n"
      ))
    } else {
      cat("\n")
    }
  }
  cat("Logistic regression DIF statistic:", "\n", "\n")
  df <- switch(res$type,
    both = 2,
    udif = 1,
    nudif = 1
  )
  pval <- round(1 - pchisq(res$Logistik, df), 4)
  if (is.null(res$p.adjust.method)) {
    symb <- symnum(pval, c(0, 0.001, 0.01, 0.05, 0.1, 1), symbols = c(
      "***",
      "**", "*", ".", ""
    ))
  } else {
    symb <- symnum(res$adjusted.p, c(0, 0.001, 0.01, 0.05, 0.1, 1), symbols = c(
      "***",
      "**", "*", ".", ""
    ))
  }
  m1 <- cbind(round(res$Logistik[itk], 4), pval[itk])
  if (!is.null(res$p.adjust.method)) m1 <- cbind(m1, round(res$adjusted.p[itk], 4))
  m1 <- noquote(cbind(format(m1, justify = "right"), symb[itk]))
  if (!is.null(res$names)) {
    rownames(m1) <- res$names[itk]
  } else {
    rn <- NULL
    for (i in 1:nrow(m1)) rn[i] <- paste("Item", i, sep = "")
    rownames(m1) <- rn[itk]
  }
  con <- c("Stat.", "P-value")
  if (!is.null(res$p.adjust.method)) {
    con <- c(con, "Adj. P")
  }
  con <- c(con, "")
  colnames(m1) <- con
  print(m1)
  cat("\n")
  cat(
    "Signif. codes: 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 ",
    "\n"
  )
  cat("\n", "Detection threshold: ", round(res$thr, 4), " (significance level: ",
    res$alpha, ")", "\n", "\n",
    sep = ""
  )
  if (is.character(res$DIFitems)) {
    cat(
      "Items detected as DIF items:", res$DIFitems, "\n",
      "\n"
    )
  } else {
    mess2 <- switch(res$type,
      both = " ",
      nudif = " nonuniform ",
      udif = " uniform "
    )
    cat("Items detected as", mess2, "DIF items:", "\n", sep = "")
    if (!is.null(res$names)) {
      m2 <- res$names
    } else {
      rn <- NULL
      for (i in 1:length(res$Logistik)) {
        rn[i] <- paste("Item",
          i,
          sep = ""
        )
      }
      m2 <- rn
    }
    m2 <- cbind(m2[res$DIFitems])
    rownames(m2) <- rep("", nrow(m2))
    colnames(m2) <- ""
    print(m2, quote = FALSE)
    cat("\n", "\n")
  }
  cat("Effect size (Nagelkerke's R^2):", "\n", "\n")
  cat("Effect size code:", "\n")
  cat(" 'A': negligible effect", "\n")
  cat(" 'B': moderate effect", "\n")
  cat(" 'C': large effect", "\n", "\n")
  r2 <- round(res$deltaR2, 4)
  symb1 <- symnum(r2, c(0, 0.13, 0.26, 1), symbols = c(
    "A",
    "B", "C"
  ))
  symb2 <- symnum(r2, c(0, 0.035, 0.07, 1), symbols = c(
    "A",
    "B", "C"
  ))
  matR2 <- noquote(cbind(
    format(r2[itk], justify = "right"),
    symb1[itk], symb2[itk]
  ))
  if (!is.null(res$names)) {
    rownames(matR2) <- res$names[itk]
  } else {
    rn <- NULL
    for (i in 1:length(r2)) rn[i] <- paste("Item", i, sep = "")
    rownames(matR2) <- rn[itk]
  }
  colnames(matR2) <- c("R^2", "ZT", "JG")
  print(matR2)
  cat("\n")
  cat("Effect size codes:", "\n")
  cat(" Zumbo & Thomas (ZT): 0 'A' 0.13 'B' 0.26 'C' 1", "\n")
  cat(" Jodoin & Gierl (JG): 0 'A' 0.035 'B' 0.07 'C' 1", "\n")
  if (!x$save.output) {
    cat("\n", "Output was not captured!", "\n")
  } else {
    if (x$output[2] == "default") {
      wd <- paste(getwd(), "/", sep = "")
    } else {
      wd <- x$output[2]
    }
    fileName <- paste(wd, x$output[1], ".txt", sep = "")
    cat("\n", "Output was captured and saved into file",
      "\n", " '", fileName, "'", "\n", "\n",
      sep = ""
    )
  }
}
