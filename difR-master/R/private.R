# Resolves the user-supplied anchor argument and returns validated anchor item
# indices (further used for computation of the match) along with the set of
# items to be tested (item_tested). In the case anchor is NULL or all items,
# all items are used for computation of match but all are also used for testing.
# Otherwise, anchor are used for computation and rest of them are used for
# testing.
.resolve_anchor <- function(anchor, Data) {
  m <- ncol(Data)
  items <- seq_len(m)

  if (is.null(anchor) || all(items %in% anchor)) {
    tested_items <- items
    ANCHOR <- items
  } else if (is.numeric(anchor)) {
    if (any(anchor < 1 | anchor > m)) {
      stop("Numeric 'anchor' values must be valid column indices within 'Data'.", call. = FALSE)
    }
    ANCHOR <- sort(unique(anchor))
    tested_items <- setdiff(items, ANCHOR)
  } else if (is.character(anchor)) {
    ANCHOR <- base::match(anchor, colnames(Data))
    if (any(is.na(ANCHOR))) {
      stop("Some anchor item names not found in 'Data'.", call. = FALSE)
    }
    ANCHOR <- sort(unique(ANCHOR))
    tested_items <- setdiff(items, ANCHOR)
  } else {
    stop("'anchor' must be either NULL, numeric (column indices), or character (column names).", call. = FALSE)
  }

  return(list(ANCHOR = ANCHOR, tested_items = tested_items))
}

# Validates and extracts the grouping variable from Data, standardizes input
# formats, checks group structure (binary factor or numeric), and returns the
# cleaned data matrix and group vector.
.resolve_group <- function(Data, group, focal.name, member.type) {
  # 0. standardize Data into a data.frame
  if (is.vector(Data)) {
    DATA <- data.frame(Item1 = Data)
  } else if (is.matrix(Data) || is.data.frame(Data)) {
    DATA <- as.data.frame(Data)
  } else {
    stop("'Data' must be a vector, matrix, or data.frame.", call. = FALSE)
  }

  # 1. group is a column index or name
  if (length(group) == 1L) {
    if (is.numeric(group)) {
      if (group < 1 || group > ncol(DATA))
        stop("'group' index is out of bounds.", call. = FALSE)
      GROUP <- DATA[[group]]
      DATA  <- DATA[, -group, drop = FALSE]
    } else if (is.character(group)) {
      col_idx <- base::match(group, colnames(DATA))
      if (is.na(col_idx))
        stop(sprintf("Column '%s' not found in 'Data'.", group), call. = FALSE)
      GROUP <- DATA[[col_idx]]
      DATA  <- DATA[, -col_idx, drop = FALSE]
    } else {
      stop("'group' must be a column name or index, or a vector of group values.", call. = FALSE)
    }
    # 2. group is a vector
  } else {
    if (length(group) != nrow(DATA)) {
      stop("'group' must be of length equal to the number of rows in 'Data'.", call. = FALSE)
    }
    # group is a standalone vector
    GROUP <- group
  }

  if (member.type == "group") {
    GROUP <- as.factor(GROUP)
    if (nlevels(GROUP) != 2L) {
      stop("'group' must have exactly two levels when member.type = 'group'.", call. = FALSE)
    }
    if (!focal.name %in% levels(GROUP)) {
      stop("'focal.name' must be a valid value from 'group'.", call. = FALSE)
    }
    GROUP <- stats::relevel(GROUP, ref = setdiff(levels(GROUP), as.character(focal.name))[1])
  } else {
    if (!is.numeric(GROUP))
      stop("'group' must be numeric when member.type = 'cont'.", call. = FALSE)
  }
  return(list(GROUP = GROUP, DATA = DATA))
}

# Constructs the item-dependent matching variable based on the specified match
# argument (score, z-score, restscore, numeric vector, or matrix/data.frame) and
# returns a full matrix of match values for each item.
.build_match <- function(match, Data, anchor, tested_items) {
  DATA <- Data[, anchor, drop = FALSE]
  m <- ncol(Data)
  n <- nrow(Data)
  MATCH <- as.data.frame(matrix(NA, nrow = nrow(Data), ncol = ncol(Data)))

  # 1. match is predefined character option
  if (is.character(match) && match[1] %in% c("score", "zscore")) {
    # anchor items with item currently tested (as described in documentation)
    MATCH[, tested_items] <- sapply(tested_items, function(item) {
      item_anchor <- union(anchor, item)
      DATA <- Data[, item_anchor, drop = FALSE]
      # DATA <- Data[, anchor, drop = FALSE]
      rowSums(DATA, na.rm = TRUE)
    })
    if (match[1] == "zscore") {
      MATCH[, tested_items] <- sapply(tested_items, function(item) as.numeric(scale(MATCH[, item])))
    }
  } else if (is.character(match) && match[1] == "restscore") {
    MATCH[, tested_items] <- sapply(tested_items, function(item) {
      rest_anchor <- setdiff(anchor, item)
      if (length(rest_anchor) == 0) {
        stop("No items left to compute matching criterion. Try to re-specify anchor or match arguments. ", call. = FALSE)
      } else {
        DATA <- Data[, rest_anchor, drop = FALSE]
        rowSums(DATA, na.rm = TRUE)
      }
    })
    # 2. match is numeric vector
  } else if (is.numeric(match) && is.null(dim(match))) {
    if (length(match) != n) {
      stop("'match' vector must have length nrow(Data).", call. = FALSE)
    }
    MATCH <- as.data.frame(replicate(m, match))
    # 3. match is numeric matrix or data.frame
  } else if ((is.numeric(match) && !is.null(dim(match))) || is.data.frame(match)) {
    if (any(dim(match) != dim(Data))) {
      if (nrow(match) == n && ncol(match) == 1) {
        MATCH <- as.data.frame(replicate(m, match))
      } else {
        stop("'match' matrix/data.frame must have the same dimensions as 'Data'.", call. = FALSE)
      }
    } else {
      MATCH <- as.data.frame(match)
    }
  } else {
    stop("'match' must be either 'score', 'zscore', 'cscore', 'czscore',
        a numeric vector of length equal to the number of rows in 'Data', or
        a numeric matrix of the same dimension as 'Data'.", call. = FALSE)
  }
  MATCH <- as.data.frame(MATCH)
  colnames(MATCH) <- paste0("MATCH", 1:m)

  return(MATCH)
}

# Determines which p-value adjustment methods to apply during and after item
# purification, based on the user’s settings for p.adjust.method, purify, and
# puriadjType
.resolve_p.adjust <- function(p.adjust.method, purify, puriadjType) {
  p.adjust.method <- .check_character(p.adjust.method, p.adjust.methods)
  if (purify) {
    if (is.null(p.adjust.method)) {
      puri.adj.method <- "none"
      adj.method <- "none"
    } else if (puriadjType == "simple") {
      puri.adj.method <- "none"
      adj.method <- p.adjust.method
    } else { # combined
      puri.adj.method <- p.adjust.method
      adj.method <- p.adjust.method
    }
  } else {
    puri.adj.method <- "none"
    adj.method <- ifelse(is.null(p.adjust.method), "none", p.adjust.method)
  }
  return(list(puri.adj.method = puri.adj.method, adj.method = adj.method))
}

# Ensures that an argument is a single logical value and throws an
# informative error otherwise.
.check_logical <- function(arg) {
  name <- deparse(substitute(arg))
  if (!is.logical(arg) || length(arg) != 1) {
    stop(sprintf("'%s' must be a single logical value (TRUE or FALSE).", name), call. = FALSE)
  }
  return(arg)
}

# Validates that an argument is a single numeric value within specified bounds,
# producing an informative error if out of range.
.check_numeric <- function(arg, low, upp = Inf) {
  name <- deparse(substitute(arg))
  if (!is.numeric(arg) || length(arg) != 1 || arg < low || arg > upp) {
    bounds <- if (upp == Inf) {
      sprintf("greater than %s", low)
    } else {
      sprintf("between %s and %s.", low, upp)
    }
    stop(paste0(sprintf("'%s' must be a single numeric value ", name), bounds), call. = FALSE)
  }
  return(arg)
}

# Validates that a character argument matches allowable choices
# (optionally multiple), returning NULL for NULL input and producing a custom
# informative error otherwise.
.check_character <- function(arg, choices, several.ok = FALSE) {
  if (is.null(arg)) {
    return(NULL)
  }

  name <- deparse(substitute(arg))
  out <- try(match.arg(arg, choices, several.ok = several.ok), silent = TRUE)

  if (inherits(out, "try-error")) {
    n_vals <- length(choices)
    choices <- paste0("'", choices, "'")
    chcs <- paste0(paste0(choices[seq(n_vals - 1)], collapse = ", "), ifelse(n_vals == 2, " or ", ", or "), values[n_vals], ".")
    stop(paste0(sprintf("'%s' must be either ", name), chcs), call. = FALSE)
  }
  return(out)
}

