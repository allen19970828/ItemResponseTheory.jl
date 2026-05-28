#' @export difSIBTEST
difSIBTEST <- function(
    Data, group, focal.name, type = "udif", anchor = NULL,
    alpha = 0.05, purify = FALSE, nrIter = 10, p.adjust.method = NULL, puriadjType = "simple",
    save.output = FALSE, output = c("out", "default")) {
  if (!is.character(puriadjType) || !puriadjType %in% c("simple", "combined")) {
    stop("'puriadjType' can be either 'simple' or 'combined'.",
         call. = FALSE
    )
  }
  internalSIBTEST <- function() {
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
    Group <- rep(0, nrow(DATA))
    Group[gr == focal.name] <- 1
    if (is.null(anchor)) {
      ANCHOR <- 1:ncol(DATA)
      anchor.names <- NULL
    } else {
      if (is.numeric(anchor)) {
        ANCHOR <- anchor
        anchor.names <- anchor
      } else {
        ANCHOR <- NULL
        for (i in anchor) {
          ANCHOR <- c(ANCHOR, which(colnames(Data) == i))
        }
        anchor.names <- anchor
      }
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

    if (!purify | !is.null(anchor)) {
      PROV <- sibTest(DATA, Group, type = type, anchor = ANCHOR)
      PVAL <- PROV$p.value
      P.ADJUST <- p.adjust(PVAL, method = adj.method)
      if (min(P.ADJUST, na.rm = TRUE) >= alpha) {
        DIFitems <- "No DIF item detected"
      } else {
        DIFitems <- which(!is.na(PVAL) & P.ADJUST < alpha)
      }

      if (is.null(p.adjust.method)) {
        adjusted.p <- NULL
      } else {
        adjusted.p <- P.ADJUST
      }

      RES <- list(
        Beta = PROV$Beta, SE = PROV$SE, X2 = PROV$X2,
        df = PROV$df, p.value = PROV$p.value, type = type,
        alpha = alpha, DIFitems = DIFitems, p.adjust.method = p.adjust.method,
        adjusted.p = adjusted.p, purification = purify, names = colnames(DATA),
        anchor.names = anchor.names, save.output = save.output,
        output = output
      )
      if (!is.null(anchor)) {
        RES$Beta[ANCHOR] <- NA
        RES$SE[ANCHOR] <- NA
        RES$X2[ANCHOR] <- NA
        RES$df[ANCHOR] <- NA
        RES$p.value[ANCHOR] <- NA
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
      prov1 <- sibTest(DATA, Group, type = type)
      pval1 <- prov1$p.value
      p.adjust1 <- p.adjust(pval1, method = puri.adj.method)
      if (min(p.adjust1, na.rm = TRUE) >= alpha) {
        DIFitems <- "No DIF item detected"
        noLoop <- TRUE
      } else {
        dif <- which(!is.na(pval1) & p.adjust1 < alpha)
        difPur <- rep(0, length(pval1))
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
            prov2 <- sibTest(DATA, Group, type = type, anchor = nodif)
            pval2 <- prov2$p.value
            p.adjust2 <- p.adjust(pval2, method = puri.adj.method)

            if (min(p.adjust2, na.rm = TRUE) >= alpha) {
              dif2 <- NULL
            } else {
              dif2 <- which(!is.na(pval2) & p.adjust2 < alpha)
            }
            difPur <- rbind(difPur, rep(0, ncol(DATA)))
            difPur[nrPur + 1, dif2] <- 1
            if (length(dif) != length(dif2)) {
              dif <- dif2
            } else {
              dif <- sort(dif)
              dif2 <- sort(dif2)
              if (sum(dif == dif2) == length(dif)) {
                noLoop <- TRUE
                break
              } else {
                dif <- dif2
              }
            }
          }
        }
        pval1 <- pval2
        p.adjust1 <- p.adjust(pval1, method = adj.method)
        prov1 <- prov2
        if (min(p.adjust1, na.rm = TRUE) >= alpha) {
          DIFitems <- "No DIF item detected"
        } else {
          DIFitems <- which(!is.na(pval1) & p.adjust1 < alpha)
        }
      }
      if (!is.null(difPur)) {
        ro <- co <- NULL
        for (ir in 1:nrow(difPur)) {
          ro[ir] <- paste("Step", ir - 1, sep = "")
        }
        for (ic in 1:ncol(difPur)) {
          co[ic] <- paste("Item", ic, sep = "")
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
        Beta = prov1$Beta, SE = prov1$SE, X2 = prov1$X2,
        df = prov1$df, p.value = pval1, type = type,
        alpha = alpha, DIFitems = DIFitems, p.adjust.method = p.adjust.method,
        adjusted.p = adjusted.p, puriadjType = puriadjType, purification = purify, nrPur = nrPur,
        difPur = difPur, convergence = noLoop, names = colnames(DATA),
        anchor.names = NULL, save.output = save.output,
        output = output
      )
    }
    class(RES) <- "SIBTEST"
    return(RES)
  }
  resToReturn <- internalSIBTEST()
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

#' @method plot SIBTEST
#' @rdname difSIBTEST
#'
#' @param x the result from a \code{"SIBTEST"} class object.
#' @param pch,col type of usual \code{pch} and \code{col} graphical options.
#' @param number logical: should the item number identification be printed
#' (default is \code{TRUE}).
#' @param save.plot logical: should the plot be saved into a separate file?
#' (default is \code{FALSE}).
#' @param save.options character: a vector of three components. The first
#' component is the name of the output file, the second component is either
#' the file path or \code{"default"} (default value), and the third component
#' is the file extension, either \code{"pdf"} (default) or \code{"jpeg"}. See
#' \bold{Details}.
#' @param ... other generic parameters for the \code{plot} or the \code{print}
#' functions.
#'
#' @export
plot.SIBTEST <- function(
    x, pch = 8, number = TRUE, col = "red", save.plot = FALSE,
    save.options = c("plot", "default", "pdf"), ...) {
  internalSIBTEST <- function() {
    res <- x
    thr <- qchisq(1 - res$alpha, res$df)
    yl <- c(0, max(c(res$X2, thr) + 0.5, na.rm = TRUE))
    if (!number) {
      plot(res$X2,
        xlab = "Item", ylab = "SIBTEST X2 statistic",
        ylim = yl, pch = pch, main = "SIBTEST"
      )
      if (!is.character(res$DIFitems)) {
        points(res$DIFitems, res$X2[res$DIFitems],
          pch = pch,
          col = col
        )
      }
    } else {
      plot(res$X2,
        xlab = "Item", ylab = "SIBTEST X2 statistic",
        ylim = yl, col = "white", main = "SIBTEST"
      )
      text(1:length(res$X2), res$X2, 1:length(res$X2))
      if (!is.character(res$DIFitems)) {
        text(res$DIFitems, res$X2[res$DIFitems], res$DIFitems,
          col = col
        )
      }
    }
    abline(h = thr[1])
  }
  internalSIBTEST()
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
          internalSIBTEST()
        }
        dev.off()
      }
      if (plotype == 2) {
        {
          jpeg(filename = fileName)
          internalSIBTEST()
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
print.SIBTEST <- function(x, ...) {
  res <- x
  cat("\n")
  cat(
    "Detection of Differential Item Functioning using SIBTEST method",
    "\n"
  )
  if (res$purification & is.null(res$anchor.names)) {
    pur <- "with "
  } else {
    pur <- "without "
  }
  cat(pur, "item purification", "\n", "\n", sep = "")
  if (res$purification & is.null(res$anchor.names)) {
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
      if (max(loop) != length(res$X2)) {
        cat("(Note: no loop detected in less than ",
          res$nrPur, word, ")", "\n",
          sep = ""
        )
      } else {
        cat("(Note: loop of length ", min((1:res$nrPur)[loop ==
          length(res$X2)]), " in the item purification process)",
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
  if (res$type == "udif") {
    cat(
      "Investigation of uniform DIF using SIBTEST (Shealy and Stout, 1993)",
      "\n", "\n"
    )
  } else {
    cat(
      "Investigation of nonuniform DIF using Crossing-SIBTEST (Chalmers, 2018)",
      "\n", "\n"
    )
  }
  if (is.null(res$anchor.names)) {
    itk <- 1:length(res$X2)
    cat("No set of anchor items was provided", "\n", "\n")
  } else {
    itk <- (1:length(res$X2))[!is.na(res$X2)]
    cat("Anchor items (provided by the user):", "\n")
    if (is.null(res$names)) {
      mm <- NULL
      for (i in res$anchor.names) {
        mm <- c(mm, paste("Item",
          i,
          sep = ""
        ))
      }
    } else {
      if (is.numeric(res$anchor.names)) {
        mm <- res$names[res$anchor.names]
      } else {
        mm <- res$anchor.names
      }
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
  if (is.null(res$p.adjust.method)) {
    symb <- symnum(res$p.value, c(
      0, 0.001, 0.01, 0.05, 0.1,
      1
    ), symbols = c("***", "**", "*", ".", ""))
  } else {
    symb <- symnum(round(res$adjusted.p, 4), c(
      0, 0.001,
      0.01, 0.05, 0.1, 1
    ), symbols = c(
      "***", "**", "*", ".",
      ""
    ))
  }
  m1 <- cbind(res$Beta[itk], res$SE[itk], res$X2[itk], res$p.value[itk])
  if (!is.null(res$p.adjust.method)) {
    m1 <- cbind(m1, round(res$adjusted.p[itk], 4))
  }
  m1 <- round(m1, 4)
  m1 <- noquote(cbind(format(m1, justify = "right"), symb[itk]))
  if (!is.null(res$names)) {
    rownames(m1) <- res$names[itk]
  } else {
    rn <- NULL
    for (i in 1:nrow(m1)) rn[i] <- paste("Item", i, sep = "")
    rownames(m1) <- rn[itk]
  }
  if (is.null(res$p.adjust.method)) {
    colnames(m1) <- c(
      "Beta", "SE", "X2 Stat.", "P-value",
      ""
    )
  } else {
    colnames(m1) <- c(
      "Beta", "SE", "X2 Stat.", "P-value",
      "Adj. P", ""
    )
  }
  print(m1)
  cat("\n")
  cat(
    "Signif. codes: 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 ",
    "\n"
  )
  THR <- qchisq(1 - res$alpha, res$df[itk][1])
  cat("\n", "Detection threshold: ", round(THR, 4), " (significance level: ",
    res$alpha, ")", "\n", "\n",
    sep = ""
  )
  if (is.character(res$DIFitems)) {
    cat(
      "Items detected as DIF items:", res$DIFitems, "\n",
      "\n"
    )
  } else {
    cat("Items detected as DIF items:", "\n")
    if (!is.null(res$names)) {
      m2 <- res$names
    } else {
      rn <- NULL
      for (i in 1:length(res$X2)) {
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
  if (!x$save.output) {
    cat("Output was not captured!", "\n")
  } else {
    if (x$output[2] == "default") {
      wd <- paste(getwd(), "/", sep = "")
    } else {
      wd <- x$output[2]
    }
    fileName <- paste(wd, x$output[1], ".txt", sep = "")
    cat("Output was captured and saved into file", "\n",
      " '", fileName, "'", "\n", "\n",
      sep = ""
    )
  }
}
