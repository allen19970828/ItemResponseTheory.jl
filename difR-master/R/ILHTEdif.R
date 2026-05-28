#' @importFrom lme4 glmer VarCorr ranef
#' @importFrom dplyr `%>%` filter pull all_of
#' @importFrom tidyr pivot_longer
#' @importFrom tibble tibble
#' @importFrom ggplot2 ggplot aes geom_point geom_errorbar geom_hline
#' @importFrom ggplot2 labs theme_bw theme element_text element_blank
#' @importFrom stats qnorm
#'
#' @export
ILHTEdif <- function(resp_mat,
                     group,
                     subject_ids = NULL,
                     alpha       = 0.05,
                     nAGQ        = 1,
                     purify      = FALSE,
                     match       = c("none", "total", "restscore"),
                     maxIter     = 2) {
  # 1) Input checks
  resp_df <- as.data.frame(resp_mat)
  n_sub   <- nrow(resp_df)
  if (!all(unlist(resp_df) %in% c(0,1))) {
    stop("All entries in resp_mat must be 0 or 1.")
  }
  if (length(group) != n_sub) {
    stop("'group' must be length nrow(resp_mat)")
  }
  if (is.null(subject_ids)) {
    subject_ids <- seq_len(n_sub)
  } else if (length(subject_ids) != n_sub) {
    stop("'subject_ids' must have length nrow(resp_mat)")
  }

  # 2) Prepare data.frame
  resp_df$subject <- factor(subject_ids)
  resp_df$group   <- if (is.factor(group)) group else factor(group)
  match <- match.arg(match)
  flagged <- NULL

  # 3) Iterative purification / fitting
  for (iter in seq_len(if (purify) maxIter else 1)) {
    dat <- resp_df

    # a) Compute matching score if requested
    if (match != "none") {
      items_for_score <- setdiff(names(dat), c("subject","group"))
      if (match == "restscore" && iter > 1) {
        items_for_score <- setdiff(items_for_score, flagged)
      }
      dat$matchscore <- rowSums(dat[ , items_for_score, drop = FALSE])
    }

    # b) Dynamically detect item columns
    item_cols <- setdiff(names(dat), c("subject","group","matchscore"))

    # c) Pivot to long
    long_dat <- dat %>%
      pivot_longer(
        cols      = all_of(item_cols),
        names_to  = "item",
        values_to = "resp"
      )

    # d) Build formula
    covar <- ""
    if (match == "total" || (match == "restscore" && iter > 1)) {
      covar <- "+ matchscore"
    }
    form <- as.formula(paste0(
      "resp ~ group ", covar,
      " + (1 | subject) + (1 + group | item)"
    ))

    # e) Fit model
    model <- glmer(
      form,
      data   = long_dat,
      family = binomial,
      nAGQ   = nAGQ
    )

    # f) Extract item-level random slopes via ranef()
    re_item_mat <- ranef(model)[["item"]]
    slope_col   <- setdiff(colnames(re_item_mat), "(Intercept)")
    item_re <- tibble::tibble(
      item = rownames(re_item_mat),
      DIF  = re_item_mat[, slope_col]
    )

    # g) Compute threshold
    vc      <- VarCorr(model)[["item"]]
    sd_zeta <- attr(vc, "stddev")[slope_col]
    crit    <- qnorm(1 - alpha/2) * sd_zeta

    # h) Flag outliers
    outliers <- item_re %>% filter(abs(DIF) > crit) %>% pull(item)
    if (!purify || identical(outliers, flagged) || iter == maxIter) {
      break
    }
    flagged <- outliers
  }

  # 4) Final outputs
  itemSig <- item_re %>% filter(abs(DIF) > crit)
  p <- ggplot(item_re, aes(x = item, y = DIF)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = DIF - crit, ymax = DIF + crit), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    x = "Item",
    y = expression(zeta[i] ~ "(DIF)" ~ "+/-" ~ "1.96*SD")
  ) +
  theme_bw() +
  theme(
    axis.text.x        = element_text(angle = 45, hjust = 1),
    panel.grid.major.x = element_blank()
  )

  list(
    model   = model,
    itemDIF = item_re,
    itemSig = itemSig,
    crit    = crit,
    plot    = p
  )
}

