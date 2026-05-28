\name{difContinuous}
\alias{difContinuous}
\title{Detection of DIF for continuous items via linear regression}
\description{
Detects differential item functioning (DIF) for items with continuous responses
using nested linear regression models. The function provides optional
item purification and p-value adjustment, and returns results in a
\code{"Continuous"} object.
}
\usage{
difContinuous(
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
)
}
\arguments{
  \item{Data}{
    A numeric matrix or data frame of item responses with \eqn{N} rows (persons)
    and \eqn{M} columns (items). All columns must be numeric (continuous items).
  }
  \item{group}{
    The grouping/membership variable. It can be:
    \itemize{
      \item a vector of length \eqn{N},
      \item or a character string naming a column in \code{Data}.
    }
    When \code{member.type = "group"}, \code{group} should define two groups
    (e.g., factor with two levels or 0/1 coding). When
    \code{member.type = "cont"}, \code{group} is treated as continuous.
  }
  \item{focal.name}{
    Character string specifying the focal group (reference group is the other level)
    when \code{member.type = "group"}.
    Ignored when \code{member.type = "cont"}.
  }
  \item{anchor}{
    Integer vector (or \code{NULL}) specifying anchor items used to build the
    matching variable. Anchor items are not tested for DIF. If \code{NULL}, all
    non-flagged items are potential anchors, but all are tested for DIF.
    If \code{anchor} set is provided, purification is not performed.
  }
  \item{member.type}{
    Type of membership variable: \code{"group"} (categorical, two groups) or
    \code{"cont"} (continuous covariate).
  }
  \item{match}{
    Matching variable specification passed to the internal matching builder.
    Common options include \code{"score"} (total score on anchor items and the
    tested item), \code{"zscore"} (standardized \code{"score"}), or
    \code{"restscore"} (total anchor score without the tested item).
    Matching can also be a numeric a vector of length \eqn{N} or a numeric
    matrix/data.frame with the same dimensions as \code{Data} (\eqn{N \times
    M}; each column is item-specific matching criterion).
  }
  \item{type}{
    DIF effect tested:
    \describe{
      \item{\code{"udif"}}{uniform DIF (group main effect).}
      \item{\code{"nudif"}}{non-uniform DIF (interaction effect).}
      \item{\code{"both"}}{joint test of uniform and non-uniform DIF.}
    }
  }
  \item{criterion}{
    Test used for nested-model comparison:
    \describe{
      \item{\code{"F"}}{nested \eqn{F} test.}
      \item{\code{"Wald"}}{Wald chi-square test based on dropped terms.}
    }
  }
  \item{alpha}{
    Significance level for DIF detection and purification. Must be in (0, 1).
  }
  \item{all.cov}{
    Logical; if \code{TRUE}, returns variance--covariance matrices for parameters
    for both full and reduced models for each tested item.
  }
  \item{purify}{
    Logical; if \code{TRUE}, performs iterative item purification by updating anchor
    items across iterations. Purification is allowed only when
    \code{match} is \code{"score"} or \code{"zscore"}, and \code{anchor = NULL}.
  }
  \item{nrIter}{
    Maximum number of purification iterations. Non-negative integer.
  }
  \item{p.adjust.method}{
    Optional character string specifying a p-value adjustment method as in
    \code{\link[stats]{p.adjust}} (e.g., \code{"holm"}, \code{"bonferroni"},
    \code{"BH"}). If \code{NULL}, no adjustment is performed.
  }
  \item{puriadjType}{
    When \code{purify = TRUE}, specifies how p-value adjustment is handled:
    \describe{
      \item{\code{"simple"}}{adjusts p-values within each purification step.}
      \item{\code{"combined"}}{adjusts p-values across the full purification process.}
    }
  }
  \item{save.output}{
    Logical; if \code{TRUE}, the printed result is saved to a text file.
  }
  \item{output}{
    Character vector controlling the output file when \code{save.output = TRUE}.
    The first element is the base file name (without extension). The second element
    is either \code{"default"} (current working directory) or a custom path.
  }
}
\details{
The function internally calls \code{\link{Continuous}} to fit, for each tested item,
a full linear model (M1) and a reduced model (M0) depending on \code{type}.
Test statistics are computed using \code{criterion}.

If \code{purify = FALSE}, DIF testing is performed once using the specified anchors.
If \code{purify = TRUE} and allowed by the matching option, purification proceeds as follows:
\enumerate{
  \item Run DIF once with all items as anchors.
  \item Flag items with adjusted p-values below \code{alpha} as DIF.
  \item Recompute matching scores using only non-DIF items as anchors.
  \item Repeat until convergence or \code{nrIter} is reached.
}
During purification, a \code{difPur} matrix is stored, indicating DIF status by step.

For items finally flagged as DIF, parameter estimates and standard errors returned in
\code{lmPar} and \code{lmSe} correspond to the reduced model (M0), as in the behavior of
other \code{difR}-style regression DIF functions.
}
\value{
An object of class \code{"Continuous"} with components:

\describe{
  \item{Stat}{Numeric vector of test statistics per item (non-tested items are \code{NA}).}
  \item{p.value}{Numeric vector of raw p-values per item.}
  \item{lmPar}{\eqn{M \times 4} matrix of parameter estimates shown for each item
               (M1 for non-DIF, M0 for DIF).}
  \item{lmSe}{\eqn{M \times 4} matrix of standard errors corresponding to \code{lmPar}.}
  \item{parM0, seM0}{\eqn{M \times 4} matrices of estimates and SEs for reduced models.}
  \item{covM0, covM1}{Lists of covariance matrices for M0 and M1 (only if \code{all.cov = TRUE}).}
  \item{deltaR2}{Numeric vector of \eqn{\Delta R^2} per item.}
  \item{alpha}{Significance level used.}
  \item{thr}{Critical value of the chosen test at level \code{alpha}.}
  \item{DIFitems}{Either a character string \code{"No DIF item detected"} or an integer
                  vector of flagged items.}
  \item{member.type, match, type, criterion}{Echoed specifications used in the analysis.}
  \item{p.adjust.method}{Adjustment method requested (possibly \code{NULL}).}
  \item{adjusted.p}{Adjusted p-values if \code{p.adjust.method} is not \code{NULL};
                    otherwise \code{NULL}.}
  \item{purification}{Logical indicating whether purification was performed.}
  \item{nrPur}{Number of purification iterations effectively run (if applicable).}
  \item{puriadjType}{Purification adjustment type (if applicable).}
  \item{difPur}{Matrix tracking DIF status by purification step (if applicable).}
  \item{convergence}{Logical indicating whether purification converged.}
  \item{names}{Item names (column names of \code{Data}).}
  \item{anchor.names}{Anchor specification as provided (or \code{NULL} under purification).}
  \item{save.output, output}{Echoed saving options.}
  \item{Data, group}{Final processed data matrix and grouping variable used.}
}
}
\author{
Adela Hladka (nee Drabinova) \cr
Institute of Computer Science of the Czech Academy of Sciences \cr
\email{hladka@cs.cas.cz} \cr
Sebastien Beland \cr
Faculte des sciences de l'education \cr
Universite de Montreal (Canada) \cr
\email{sebastien.beland@umontreal.ca} \cr
}
\seealso{
\code{\link{Continuous}},
\code{\link[difR]{difLogistic}}.
}
\examples{
 set.seed(123)
  n <- 300                            # sample size
  group <- rep(c(0, 1), each = n / 2) # binary group membership variable
  theta <- rnorm(n)                   # latent trait

  # generating 5 continuous items with noise
  Data <- data.frame(
    Item1 = 0.5 * theta + rnorm(n),                        # No DIF
    Item2 = 0.4 * theta + 0.3 * group + rnorm(n),          # Uniform DIF
    Item3 = 0.6 * theta + 0.6 * theta * group + rnorm(n),  # Non-uniform DIF
    Item4 = 0.4 * theta + rnorm(n),                        # No DIF
    Item5 = 0.4 * theta - 0.4 * group + rnorm(n)           # Uniform DIF
  )

  # various matching criteria
  difContinuous(Data, group, focal.name = 1)
  difContinuous(Data, group, focal.name = 1, match = rowSums(Data))
  difContinuous(Data, group, focal.name = 1, match = as.data.frame(replicate(5, rowSums(Data))))
  difContinuous(Data, group, focal.name = 1, match = "zscore")
  difContinuous(Data, group, focal.name = 1, match = "restscore")
  difContinuous(Data, group, focal.name = 1, match = theta)

  # DIF detection with linear model, anchor items
  difContinuous(Data, group, focal.name = 1, anchor = c(1, 4))
  difContinuous(Data, group, focal.name = 1, anchor = paste0("Item", c(1, 4)))

  # DIF detection with linear model, different type of DIF
  difContinuous(Data, group, focal.name = 1, type = "both")
  difContinuous(Data, group, focal.name = 1, type = "udif")
  difContinuous(Data, group, focal.name = 1, type = "nudif")

  # DIF detection with linear model, different test criterion
  difContinuous(Data, group, focal.name = 1, criterion = "F")
  difContinuous(Data, group, focal.name = 1, criterion = "Wald")

  # DIF detection with linear model, item purification and multiple comparison corrections
  difContinuous(Data, group, focal.name = 1, purify = TRUE)
  difContinuous(Data, group, focal.name = 1, p.adjust.method = "BH")
  difContinuous(Data, group, focal.name = 1, purify = TRUE,
              p.adjust.method = "holm", puriadjType = "simple")

  difContinuous(Data, group, focal.name = 1, purify = TRUE,
              p.adjust.method = "holm", puriadjType = "combined")

}
\keyword{models}
\keyword{univar}
