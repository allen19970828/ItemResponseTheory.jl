\name{Continuous}
\alias{Continuous}
\title{Detection of DIF for continuous item scores using linear regression}
\description{
Performs differential item functioning (DIF) detection for items with
continuous responses using nested linear regression models.
The procedure is an analogue of logistic-regression DIF methods for
dichotomous/ordinal items, but relies on \code{\link[stats]{lm}}.
}
\usage{
Continuous(DATA, GROUP, member.type = c("group", "cont"),
           match = "score", type = c("both", "udif", "nudif"),
           criterion = c("F", "Wald"),
           anchor = seq_len(ncol(DATA)),
           tested_items = seq_len(ncol(DATA)),
           all.cov = FALSE)
}
\arguments{
  \item{DATA}{
    A numeric matrix or data frame of item responses with
    \eqn{N} rows (persons) and \eqn{M} columns (items).
    Each column is treated as a continuous dependent variable.
  }
  \item{GROUP}{
    A vector of length \eqn{N} defining the membership variable.
    If \code{member.type = "group"}, \code{GROUP} should represent two groups
    (e.g., a factor with two levels or a 0/1 numeric coding).
    If \code{member.type = "cont"}, \code{GROUP} is treated as a continuous
    covariate and enters the model linearly.
  }
  \item{member.type}{
    Character string specifying the type of membership variable.
    \code{"group"} for a categorical grouping variable, or
    \code{"cont"} for a continuous membership covariate.
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
    Defines the DIF effect tested:
    \describe{
      \item{\code{"udif"}}{uniform DIF only (group main effect).}
      \item{\code{"nudif"}}{non-uniform DIF only (interaction effect).}
      \item{\code{"both"}}{tests uniform and non-uniform DIF jointly.}
    }
  }
  \item{criterion}{
    Test criterion used to compare nested models:
    \describe{
      \item{\code{"F"}}{nested-model \eqn{F} test via \code{anova(M0, M1)}.}
      \item{\code{"Wald"}}{Wald chi-square test based on dropped coefficients.}
    }
  }
  \item{anchor}{
    Integer vector indicating anchor items used to build the matching variable.
    Default is all items.
  }
  \item{tested_items}{
    Integer vector indicating which items are tested for DIF.
    Default is all items.
  }
  \item{all.cov}{
    Logical; if \code{TRUE}, variance--covariance matrices of parameters for
    both models are returned for each tested item. Default is \code{FALSE}.
  }
}
\details{
For each tested item \eqn{i}, two nested linear models are fitted:
\describe{
  \item{Full model (M1)}{
    \code{y ~ MATCH + GROUP + MATCH:GROUP} when \code{type = "both"}  \cr
    \code{y ~ MATCH + GROUP} when \code{type = "udif"}  \cr
    \code{y ~ MATCH + GROUP + MATCH:GROUP} when \code{type = "nudif"}, \cr
    depending on \code{type}.
  }
  \item{Reduced model (M0)}{
    Drops the terms corresponding to the DIF effect(s) being tested.
     \code{y ~ MATCH} when \code{type = "both"}  \cr
     \code{y ~ MATCH} when \code{type = "udif"}  \cr
     \code{y ~ MATCH + GROUP} when \code{type = "nudif"}, \cr
  }
}

The test statistic is:
\itemize{
  \item an \eqn{F} statistic from nested regression comparison when
  \code{criterion = "F"};
  \item a Wald chi-square statistic when \code{criterion = "Wald"}.
}

The change in explained variance, \eqn{\Delta R^2}, is computed as the
difference in \eqn{R^2} between M1 and M0.

Coefficient tables are mapped to fixed slots:
\code{(Intercept)}, \code{MATCH}, \code{GROUP}, and \code{MATCH:GROUP},
to ensure stable output even if \code{GROUP} is internally expanded
(e.g., \code{GROUP1}).
}
\value{
A list with components:
\describe{
  \item{stat}{Numeric vector of length \eqn{M} containing test statistics for
               each tested item (non-tested items are \code{NA}).}
  \item{parM1}{\eqn{M \times 4} matrix of parameter estimates for full models
               (M1), columns \code{(Intercept)}, \code{MATCH}, \code{GROUP},
               \code{MATCH:GROUP}.}
  \item{seM1}{\eqn{M \times 4} matrix of standard errors for full models (M1).}
  \item{covM1}{List of length \eqn{M} with covariance matrices for M1
               (only if \code{all.cov = TRUE}).}
  \item{parM0}{\eqn{M \times 4} matrix of parameter estimates for reduced models
               (M0).}
  \item{seM0}{\eqn{M \times 4} matrix of standard errors for reduced models (M0).}
  \item{covM0}{List of length \eqn{M} with covariance matrices for M0
               (only if \code{all.cov = TRUE}).}
  \item{deltaR2}{Numeric vector of length \eqn{M} giving
                 \eqn{\Delta R^2 = R^2_{M1} - R^2_{M0}} for each tested item.}
  \item{match}{Character string describing the matching option used.}
}
}

\seealso{
\code{\link[difR]{difContinuous}}, \code{\link[difR]{difLogistic}}.
}

\examples{
## Toy example with continuous items
set.seed(123)
N <- 400
M <- 8

## Simulate a continuous "ability"
theta <- rnorm(N)

## Two groups
GROUP <- rep(0:1, each = N/2)

## Continuous item scores (no DIF)
DATA <- sapply(1:M, function(j){
  0.5 + 1.0 * theta + rnorm(N, sd = 1)
})

## Add uniform DIF to item 3
DATA[, 3] <- DATA[, 3] + 0.6 * GROUP

## Run Continuous DIF detection
res <- Continuous(DATA = DATA, GROUP = GROUP,
                  match = "score", type = "both",
                  criterion = "F")

res$stat
res$deltaR2
}
\keyword{models}
\keyword{univar}
