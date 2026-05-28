#' @export
liu_agresti_ccor <- function(responses, group, strata = NULL,
                                se = c("liu_agresti","bootstrap","naive"),
                                B = 1000, seed = NULL, eps = 1e-12) {
  se <- match.arg(se)
  # --- checks
  n <- length(responses)
  if (length(group) != n) stop("'responses' and 'group' must have same length")
  if (is.null(strata)) strata <- rep(1L, n)
  if (length(strata) != n) stop("'strata' must have same length as data")

  # coerce to factors / ordered factors
  if (is.numeric(responses)) {
    lev <- sort(unique(responses))
    responses <- factor(responses, levels = lev, ordered = TRUE)
  } else {
    responses <- factor(responses, ordered = TRUE)
  }
  group  <- factor(group)
  if (nlevels(group) != 2) stop("'group' must have exactly two levels")
  strata <- factor(strata)
  g_levels <- levels(group); ref <- g_levels[1]; foc <- g_levels[2]

  # --- core: compute ∑ R_{jk}, ∑ S_{jk} (R=a*d/N, S=b*c/N, cumuls "≤ j")
  core_ccor <- function(resp, grp, strt){
    num <- 0; den <- 0
    pieces <- list()  # pour la SE analytique
    for (s in levels(strt)) {
      idx <- which(strt == s)
      tab <- table(resp[idx], grp[idx])
      if (!all(c(ref,foc) %in% colnames(tab))) next

      n_ref <- sum(tab[, ref]); n_foc <- sum(tab[, foc]); N <- n_ref + n_foc
      if (N == 0) next
      c_levels <- nrow(tab)

      cum_ref <- cumsum(tab[, ref])   # "≤ j"
      cum_foc <- cumsum(tab[, foc])

      Rjs <- Sjs <- numeric(c_levels - 1L)
      for (j in 1:(c_levels - 1L)) {
        a <- cum_ref[j]
        c_ <- cum_foc[j]
        b <- n_ref - a
        d <- n_foc - c_

        R <- (a * d) / N
        S <- (b * c_) / N

        num <- num + R
        den <- den + S
        Rjs[j] <- R; Sjs[j] <- S
      }
      pieces[[as.character(s)]] <- list(tab = tab, n1 = n_ref, n2 = n_foc, N = N,
                                        R = Rjs, S = Sjs)
    }
    list(num = num, den = den, pieces = pieces)
  }

  est <- core_ccor(responses, group, strata)
  Psi_hat   <- est$num / est$den
  Alpha_hat <- log(Psi_hat)

  # ---------------- SEs ----------------
  SE_log <- NA_real_; CI <- c(NA_real_, NA_real_); z <- NA_real_; p_two <- NA_real_

  if (se == "naive") {
    SE_log <- sqrt(1/est$num + 1/est$den)
    z      <- Alpha_hat / SE_log
    p_two  <- 2 * (1 - stats::pnorm(abs(z)))
    CI     <- Alpha_hat + c(-1,1) * stats::qnorm(0.975) * SE_log

  } else if (se == "bootstrap") {
    if (!is.null(seed)) set.seed(seed)
    dat <- data.frame(y = responses, g = group, s = strata)
    boots <- numeric(B)
    for (b in seq_len(B)) {
      idx_b <- unlist(lapply(split(seq_len(nrow(dat)), dat$s), function(ix){
        sample(ix, length(ix), replace = TRUE)
      }), use.names = FALSE)
      d_b <- dat[idx_b, , drop = FALSE]
      est_b <- core_ccor(d_b$y, d_b$g, d_b$s)
      boots[b] <- if (est_b$den == 0 || est_b$num == 0) NA_real_ else log(est_b$num / est_b$den)
    }
    boots <- boots[is.finite(boots)]
    if (length(boots) < 10) warning("Too few bootstrap replicates; SE may be unstable.")
    SE_log <- stats::sd(boots)
    z      <- Alpha_hat / SE_log
    p_two  <- 2 * (1 - stats::pnorm(abs(z)))
    CI     <- stats::quantile(boots, probs = c(0.025, 0.975), names = FALSE)

  } else if (se == "liu_agresti") {
    denom_all <- est$den
    var_sumT  <- 0

    for (nm in names(est$pieces)) {
      piece <- est$pieces[[nm]]
      tab <- piece$tab; n1 <- piece$n1; n2 <- piece$n2; N <- piece$N
      cL <- nrow(tab)
      if (n1 == 0 || n2 == 0) next

      p1 <- as.numeric(tab[, ref]); p2 <- as.numeric(tab[, foc])
      pi1 <- (p1 + eps) / (n1 + eps * cL)
      pi2 <- (p2 + eps) / (n2 + eps * cL)

      S1 <- n1 * (diag(pi1) - outer(pi1, pi1))
      S2 <- n2 * (diag(pi2) - outer(pi2, pi2))

      U <- t(vapply(1:(cL-1), function(j) as.numeric(seq_len(cL) <= j), numeric(cL)))

      cum_ref <- cumsum(tab[, ref]); cum_foc <- cumsum(tab[, foc])
      a_vec <- cum_ref[1:(cL-1)]
      c_vec <- cum_foc[1:(cL-1)]
      b_vec <- n1 - a_vec
      d_vec <- n2 - c_vec

      # Gradients dT/dX1, dT/dX2 pour T_j = a*d/N - Psi_hat*(b*c)/N
      grads1 <- matrix(0, nrow = cL-1, ncol = cL)
      grads2 <- matrix(0, nrow = cL-1, ncol = cL)
      for (j in 1:(cL-1)) {
        d_da <- d_vec[j]/N + Psi_hat * (c_vec[j]/N)    # via a
        d_dc <- a_vec[j]/N - Psi_hat * (b_vec[j]/N)    # via c
        grads1[j, ] <- d_da * U[j, ]
        grads2[j, ] <- d_dc * U[j, ]                   # U=V ici
      }

      V_T <- grads1 %*% S1 %*% t(grads1) + grads2 %*% S2 %*% t(grads2)
      var_sumT <- var_sumT + sum(V_T)   # inclut variances + covariances j≠j'
    }

    SE_log <- sqrt( var_sumT / (denom_all^2 + eps) )
    z      <- Alpha_hat / SE_log
    p_two  <- 2 * (1 - stats::pnorm(abs(z)))
    CI     <- Alpha_hat + c(-1,1) * stats::qnorm(0.975) * SE_log
  }

  out <- c(
    Psi_hat      = unname(Psi_hat),
    Alpha_hat    = unname(Alpha_hat),
    SE_log_Psi   = unname(SE_log),
    z            = unname(z),
    p_two_sided  = unname(p_two),
    CI_log_lower = unname(CI[1]),
    CI_log_upper = unname(CI[2])
  )
  class(out) <- "liu_agresti_ccor"
  out
}

