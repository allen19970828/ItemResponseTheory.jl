\name{liu_agresti_ccor}
\alias{liu_agresti_ccor}

\title{Liu--Agresti Common Cumulative Odds Ratio}

\description{
Computes the Liu--Agresti estimate of the common cumulative odds ratio (\eqn{\Psi}) and its log (\eqn{\alpha = \log \Psi}) for ordinal data from two independent groups. This statistic quantifies the direction and strength of ordinal association between groups. The implementation follows Section 2 of Liu & Agresti (1996), treating the \strong{first} level of \code{group} as the \emph{reference}.
}

\usage{
liu_agresti_ccor(responses, group, strata = NULL,
                 se = c("liu_agresti","bootstrap","naive"),
                 B = 1000, seed = NULL, eps = 1e-12)
}

\arguments{
  \item{responses}{A numeric vector (typically coded as consecutive integers, e.g., 1 to 5 for a Likert-type scale) or an ordered factor of ordinal item responses. Numeric inputs are internally converted to an ordered factor via \code{sort(unique(responses))}.}
  \item{group}{A grouping vector indicating the group to which each observation belongs. It must contain exactly two unique values (e.g., \code{"ref"} and \code{"foc"}). \strong{The first level is the reference} (compared to the second).}
  \item{strata}{Optional factor/character of length \code{n} giving strata (matching blocks). If \code{NULL}, a single stratum is used.}
  \item{se}{Standard-error method: \code{"liu_agresti"} (delta with multinomial variance; recommended), \code{"bootstrap"} (percentile CI on \eqn{\log \Psi}), or \code{"naive"} (simple large-sample SE on \eqn{\log \Psi}).}
  \item{B}{Number of bootstrap replicates when \code{se = "bootstrap"}.}
  \item{seed}{Optional RNG seed for bootstrap reproducibility.}
  \item{eps}{Small numerical constant for stability (avoids zero divisions).}
}

\value{
A named vector (class \code{"liu_agresti_ccor"}) returning the following elements (the first three mirror the original concise summary, additional fields follow for inference):
  \item{Psi_hat}{The Liu--Agresti estimate of the common cumulative odds ratio (\eqn{\widehat{\Psi}}).}
  \item{Alpha_hat}{\eqn{\log(\widehat{\Psi})}.}
  \item{SE_log_Psi}{The standard error of \eqn{\log(\widehat{\Psi})}, which can be used to construct confidence intervals or conduct hypothesis testing.}
  \item{z}{Wald statistic based on \eqn{\log(\widehat{\Psi})}.}
  \item{p_two_sided}{Two-sided p-value associated with the Wald statistic.}
  \item{CI_log_lower}{Lower bound of the 95\% confidence interval for \eqn{\log(\Psi)}.}
  \item{CI_log_upper}{Upper bound of the 95\% confidence interval for \eqn{\log(\Psi)}.}
}

\details{
This function creates a contingency table of dimension \eqn{2 \times C}, where \eqn{C} denotes the number of distinct ordinal response categories. It computes cumulative marginal frequencies and estimates the odds ratio using Liu and Agresti's formulation (1996). The variance of the log-transformed estimate is computed according to their Eq.~3.

Formally, letting cumulation be over \eqn{Y \le j}, and with \eqn{N_k = n_{1k} + n_{2k}} for stratum \eqn{k}, the estimator is
\deqn{\widehat{\Psi}=\frac{\sum_k \sum_{j=1}^{C-1} (a_{jk} d_{jk})/N_k}{\sum_k \sum_{j=1}^{C-1} (b_{jk} c_{jk})/N_k},}
with the \strong{first} level of \code{group} as the \emph{reference} and the second as the \emph{focal}. The estimator reduces to the standard Mantel--Haenszel odds ratio when \eqn{C = 2}.

The estimate \eqn{\widehat{\Psi}} is based on cumulative frequencies and is designed for ordinal response categories. It quantifies the association between group membership and the likelihood of higher category responses.

Strata in which at least one of the two groups is completely absent are skipped in the computation of the estimator.

The function is not designed to handle missing values; observations with \code{NA} should be removed prior to use.

If one of the response categories is completely absent from one group, then the cumulative margins used in the computation may contain zero values. In such cases, either the numerator or the denominator of the Liu--Agresti formula will be zero, making the estimate numerically unstable. When this occurs, the estimate may be \code{0}, \code{Inf}, or \code{NaN}, and users should carefully inspect the output and, if necessary, collapse sparse categories or strata.

When strata are very small or categories are extremely sparse, consider \code{se = "bootstrap"} for more robust interval estimation.
}

\references{
Liu, I., & Agresti, A. (1996). Mantel--Haenszel-Type Inference for Cumulative Odds Ratios with a Stratified Ordinal Response. \emph{Biometrics}, 52(4), 1223--1234.
}

\seealso{
\code{\link[stats]{mantelhaen.test}} (binary case), \code{\link[ordinal]{clm}}, \code{\link[VGAM]{vglm}} for parametric cumulative logit models.
}

\author{
Sebastien Beland \cr
Faculte des sciences de l'education \cr
Universite de Montreal (Canada) \cr
\email{sebastien.beland@umontreal.ca}
}

\examples{
# Simulated balanced example
set.seed(123)

group <- rep(c("ref", "foc"), each = 100)
stopifnot(length(group) == 200)

responses <- sample(1:4, size = length(group), replace = TRUE)
stopifnot(length(responses) == length(group))

liu_agresti_ccor(as.integer(responses), factor(group))
}


