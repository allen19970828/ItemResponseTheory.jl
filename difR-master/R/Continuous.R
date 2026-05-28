#' @export
Continuous <- function(DATA, GROUP, member.type = c("group", "cont"),
                       match = "score", type = c("both", "udif", "nudif"),
                       criterion = c("F", "Wald"),
                       anchor = seq_len(ncol(DATA)), tested_items = seq_len(ncol(DATA)),
                       all.cov = FALSE) {
  ## --- Normalize choices & prepare base objects ---
  member.type <- .check_character(member.type, choices = c("group", "cont"))
  type        <- .check_character(type, choices = c("both", "udif", "nudif"))
  criterion   <- .check_character(criterion, choices = c("F", "Wald"))
  all.cov     <- .check_logical(all.cov)

  DATA <- as.data.frame(DATA)
  n <- nrow(DATA)
  m <- ncol(DATA)

  ## --- Build the matching variable(s) ---
  MATCH <- .build_match(match, DATA, anchor, tested_items)

  ## --- Containers (fixed slots) ---
  slots <- c("(Intercept)", "MATCH", "GROUP", "MATCH:GROUP")
  stat    <- rep(NA, m)
  deltaR2 <- rep(NA, m)
  parM1   <- matrix(NA_real_, m, 4, dimnames = list(colnames(DATA), slots))
  seM1    <- parM1
  parM0   <- parM1 * NA
  seM0    <- parM1 * NA
  covM0 <- covM1 <- if (all.cov) vector("list", m) else NULL

  ## --- Helpers to map lm() coef names to fixed slots ---
  map_est <- function(ct, var_match = "MATCH") {
    out <- setNames(rep(NA_real_, 4), slots)
    rn <- rownames(ct)
    if ("(Intercept)" %in% rn) out["(Intercept)"] <- ct["(Intercept)","Estimate"]
    if (var_match %in% rn)     out["MATCH"]       <- ct[var_match,"Estimate"]
    g <- rn[grepl("^GROUP", rn)]
    if (length(g))             out["GROUP"]       <- ct[g[1],"Estimate"]
    ig <- rn[grepl(paste0("^", var_match, ":GROUP"), rn)]
    if (length(ig))            out["MATCH:GROUP"] <- ct[ig[1],"Estimate"]
    out
  }
  map_se <- function(ct, var_match = "MATCH") {
    out <- setNames(rep(NA_real_, 4), slots)
    rn <- rownames(ct)
    if ("(Intercept)" %in% rn) out["(Intercept)"] <- ct["(Intercept)","Std. Error"]
    if (var_match %in% rn)     out["MATCH"]       <- ct[var_match,"Std. Error"]
    g <- rn[grepl("^GROUP", rn)]
    if (length(g))             out["GROUP"]       <- ct[g[1],"Std. Error"]
    ig <- rn[grepl(paste0("^", var_match, ":GROUP"), rn)]
    if (length(ig))            out["MATCH:GROUP"] <- ct[ig[1],"Std. Error"]
    out
  }

  ## --- Per-item loop ---
  for (i in tested_items) {

    df <- data.frame(y = DATA[, i], MATCH = MATCH[, i], GROUP = GROUP)

    # FULL model (M1): includes MATCH + GROUP + interaction (changing this according to Logistik())
    M1 <- switch(type,
                 "udif"  = stats::lm(y ~ MATCH + GROUP, df),
                 "nudif" = stats::lm(y ~ MATCH + GROUP + MATCH:GROUP, df),
                 "both"  = stats::lm(y ~ MATCH + GROUP + MATCH:GROUP, df))

    # REDUCED model (M0) according to 'type'
    M0 <- switch(type,
                 "udif"  = stats::lm(y ~ MATCH, df),                # drops GROUP
                 "nudif" = stats::lm(y ~ MATCH + GROUP, df),        # drops interaction
                 "both"  = stats::lm(y ~ MATCH, df))                # drops both

    # Store mapped coefficients/SEs (robust to GROUP1 etc.)
    ct1 <- stats::coef(summary(M1))
    parM1[i, ] <- map_est(ct1, var_match = "MATCH")
    seM1 [i, ] <- map_se (ct1, var_match = "MATCH")
    ct0 <- stats::coef(summary(M0))
    parM0[i, ] <- map_est(ct0, var_match = "MATCH")
    seM0 [i, ] <- map_se (ct0, var_match = "MATCH")

    if (all.cov) {
      covM1[[i]] <- tryCatch(vcov(M1), error = function(e) NA)
      covM0[[i]] <- tryCatch(vcov(M0), error = function(e) NA)
    }

    # Wald chi-square using t^2 of the dropped terms
    if (criterion == "F") {
      test <- stats::anova(M0, M1)
      stat[i] <- test$F[2]
    } else {
      if (criterion != "Wald") stop("'criterion' must be either 'F' or 'Wald'", call. = FALSE)
      coeff <- as.numeric(coef(M1))
      covMat <- vcov(M1)
      C <- switch(type,
                  udif  = rbind(c(0, 0, 1)),
                  nudif = rbind(c(0, 0, 0, 1)),
                  both  = rbind(c(0, 0, 1, 0), c(0, 0, 0, 1)))
      stat[i] <- t(C %*% coeff) %*% solve(C %*% covMat %*% t(C)) %*% C %*% coeff
    }

    # ΔR² (full minus reduced)
    deltaR2[i] <- summary(M1)$r.squared - summary(M0)$r.squared
  }

  list(
    stat   = stat,
    parM1  = parM1, seM1 = seM1, covM1 = covM1,   # FULL
    parM0  = parM0, seM0 = seM0, covM0 = covM0,   # REDUCED
    deltaR2 = deltaR2,
    match  = if (is.character(match)) match[1] else "custom"
  )
}
