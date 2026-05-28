#' @export
difMantel.poly <- function(data, group, focal.name, ref.name,
                           match = "score", sig.level = 0.05,
                           purify = FALSE, max.iter = 10) {

  if (!match %in% c("score", "restscore"))
    stop("'match' must be either 'score' or 'restscore'.")

  if (purify && match == "restscore") {
    warning("Purification is not allowed when match = 'restscore'. Setting purify = FALSE.")
    purify <- FALSE
  }

  # -- coerce inputs
  data <- as.data.frame(data)
  # Colonnes polytomiques: s'assurer que les catégories sont numériques ordonnées
  for (ii in seq_len(ncol(data))) {
    xi <- data[[ii]]
    if (is.ordered(xi)) {
      data[[ii]] <- as.integer(xi)  # respecte l'ordre existant
    } else if (is.factor(xi)) {
      warning(sprintf("Column %s is an unordered factor; converting to integer by current level order.",
                      if (!is.null(colnames(data))) colnames(data)[ii] else ii))
      data[[ii]] <- as.integer(xi)
    }
  }

  if (!all(vapply(data, is.numeric, TRUE))) {
    stop("All item columns must be numeric (or ordered factors).")
  }

  group <- factor(group)
  if (!all(c(ref.name, focal.name) %in% levels(group))) {
    stop("Both 'ref.name' and 'focal.name' must be present in 'group' levels.")
  }
  group <- factor(group, levels = c(ref.name, focal.name))  # ordre ref, puis focal

  test.length <- ncol(data)
  items <- seq_len(test.length)
  current_anchors <- items
  iter <- 0L

  compute_scores <- function(data, i, anchors, match) {
    if (match == "restscore") {
      return(rowSums(data[, setdiff(anchors, i), drop = FALSE], na.rm = TRUE))
    } else {
      return(rowSums(data[, anchors, drop = FALSE], na.rm = TRUE))
    }
  }

  run_mantel <- function(data, group, anchors, match, items) {
    TS <- numeric(length(items))
    Psi <- Alpha <- SE_log_Psi <- rho.spear <- rep(NA_real_, length(items))
    la.valid <- rep(TRUE, length(items))
    item_names <- if (!is.null(colnames(data))) colnames(data)[items] else paste0("Item", items)
    names(TS) <- item_names

    for (j in seq_along(items)) {
      i <- items[j]
      raw.scores <- compute_scores(data, i, anchors, match)

      strata_vals <- sort(unique(raw.scores[is.finite(raw.scores)]))
      if (length(strata_vals) == 0L) {
        TS[j] <- NA_real_
      } else {
        S.Fm <- exp.S.Fm <- var.S.Fm <- rep(NA_real_, length(strata_vals))

        for (s in seq_along(strata_vals)) {
          m <- strata_vals[s]

          temp.F <- data[group == focal.name & raw.scores == m, i]
          temp.R <- data[group == ref.name  & raw.scores == m, i]
          temp   <- data[raw.scores == m, i]

       
          if (length(temp.F) < 1L || length(temp.R) < 1L || length(temp) < 2L) next

          c.vals.F <- as.numeric(names(table(temp.F)))
          c.vals   <- as.numeric(names(table(temp)))

          S.Fm[s] <- sum(table(temp.F) * c.vals.F)

          N.Fm <- length(temp.F)
          N.Rm <- length(temp.R)
          N.m  <- N.Fm + N.Rm

          exp.S.Fm[s] <- N.Fm * mean(temp, na.rm = TRUE)

          if (N.m > 1L) {
            var.part1 <- (N.Fm * N.Rm) / ((N.m^2) * (N.m - 1))
            N.cm <- table(temp)
            var.part2 <- N.m * sum((c.vals^2) * N.cm) - (sum(c.vals * N.cm))^2
            var.S.Fm[s] <- var.part1 * var.part2
          } else {
            var.S.Fm[s] <- NA_real_
          }
        }

        if (sum(!is.na(var.S.Fm)) > 0 && sum(var.S.Fm, na.rm = TRUE) > 0) {
          num <- (sum(S.Fm, na.rm = TRUE) - sum(exp.S.Fm, na.rm = TRUE))^2
          den <- sum(var.S.Fm, na.rm = TRUE)
          TS[j] <- num / den
        } else {
          TS[j] <- NA_real_
        }
      }

      # --------- Liu–Agresti CCOR 
      responses <- data[, i]

      ok_item <- length(unique(responses[!is.na(responses)])) > 1 &&
                 length(unique(responses[group == focal.name])) > 1 &&
                 length(unique(responses[group == ref.name]))  > 1

      if (ok_item) {
        la_result <- tryCatch({
          liu_agresti_ccor(
            responses = responses,
            group     = group,
            strata    = raw.scores,
            se        = "liu_agresti"
          )
        }, error = function(e) NULL)

        if (!is.null(la_result)) {
          # Lecture robuste (vector/list S3)
          Psi[j]        <- suppressWarnings(unname(la_result[["Psi_hat"]]))
          Alpha[j]      <- suppressWarnings(unname(la_result[["Alpha_hat"]]))
          SE_log_Psi[j] <- suppressWarnings(unname(la_result[["SE_log_Psi"]]))
          # Fallback pour autre structure
          if (is.na(Psi[j]) && !is.null(la_result[["psi"]])) {
            Psi[j]        <- la_result[["psi"]]
            Alpha[j]      <- la_result[["log_psi"]]
            SE_log_Psi[j] <- la_result[["se_log"]]
          }
        } else {
          la.valid[j] <- FALSE
        }
      } else {
        la.valid[j] <- FALSE
      }

      rho.spear[j] <- suppressWarnings(
        cor(raw.scores, responses, method = "spearman", use = "complete.obs")
      )
    }

    pval <- 1 - pchisq(TS, df = 1)
    pval.adj <- p.adjust(pval, method = "holm")

    data.frame(
      item      = item_names,
      Stat      = round(TS, 3),
      p.value   = round(pval, 4),
      p.adj     = round(pval.adj, 4),
      Psi_hat   = round(Psi, 4),
      Alpha_hat = round(Alpha, 4),
      SE_log_Psi= round(SE_log_Psi, 4),
      rho.spear = round(rho.spear, 3),
      LA.valid  = la.valid,
      stringsAsFactors = FALSE
    )
  }


  if (!purify) {
    return(run_mantel(data, group, items, match, items))
  }

  repeat {
    iter <- iter + 1L
    result <- run_mantel(data, group, current_anchors, "score", items)
    pval <- result$p.value

    new_anchors <- which(pval >= sig.level)
    # éviter ensemble vide : si tout est en DIF, on garde tous les items (ancrage plein)
    if (length(new_anchors) == 0L) new_anchors <- items

    if (setequal(current_anchors, new_anchors) || iter >= max.iter) {
      attr(result, "iterations") <- iter
      attr(result, "final_anchors") <- new_anchors
      return(result)
    } else {
      current_anchors <- new_anchors
    }
  }
}

#' @export
plot.MHPoly <- function(x, alpha = 0.05, cex = 0.8, col = "black",
                        save.plot = FALSE,
                        save.options = c("plot", getwd(), "pdf"),
                        main = "Mantel (1963)", ...) {


  if (!is.null(rownames(x))) {
    name <- rownames(x)
  } else if (!is.null(x$item)) {
    name <- as.character(x$item)
  } else {
    stop("Item labels not found: provide row names or an 'item' column.")
  }


  thr <- qchisq(1 - alpha, df = 1)
  stat <- x$Stat
  stat_ok <- stat[is.finite(stat)]
  ylim_max <- if (length(stat_ok)) max(stat_ok) else 1
  point_cols <- ifelse(stat > thr, "red", col)


  do_plot <- function() {
    plot(stat,
         xlab = "Item",
         ylab = "Chi-square statistic",
         main = main,
         ylim = c(0, ylim_max + 1),
         pch = "",   # pas de points, on écrit les labels colorés
         ...)
    text(x = seq_along(stat), y = stat, labels = name, col = point_cols, cex = cex, ...)
    abline(h = thr, lty = 2, ...)
  }

  # --- Save
  original_par <- par(no.readonly = TRUE)
  on.exit(par(original_par), add = TRUE)

  do_plot()

  if (isTRUE(save.plot)) {
    if (length(save.options) < 3L) {
      stop("save.options must be c(file_name, directory, file_type).")
    }
    file_name <- save.options[1]
    directory <- save.options[2]
    file_type <- tolower(save.options[3])

    if (!dir.exists(directory)) {
      stop(paste("Directory", directory, "does not exist."))
    }
    full_file_name <- file.path(directory, paste0(file_name, ".", file_type))

    if (file_type == "pdf") {
      pdf(file = full_file_name)
    } else if (file_type %in% c("jpeg", "jpg")) {
      jpeg(filename = full_file_name, quality = 95)
    } else if (file_type == "png") {
      png(filename = full_file_name, type = "cairo")
    } else {
      cat("Invalid plot type (use 'pdf', 'jpeg'/'jpg', or 'png').\n")
      cat("The plot was not captured!\n")
      return(invisible(NULL))
    }

    do_plot()
    dev.off()
    cat("The plot was captured and saved into '", full_file_name, "'\n", sep = "")
  } else {
    cat("The plot was not captured!\n")
  }

  invisible(NULL)
}
