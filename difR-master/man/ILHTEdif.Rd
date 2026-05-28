\name{ILHTEdif}
\alias{ILHTEdif}
\title{Detect DIF via the IL-HTE mixed model}
\encoding{UTF-8}

\description{
Implements the Modeling item-level heterogeneous treatment effects (IL-HTE) mixed model
for differential item functioning (DIF) with optional total- or rest-score purification.
The model is
\deqn{\operatorname{logit}\{P(Y_{ij}=1)\} = \theta_j + b_i + \zeta_i T_j,}
with an item location term
\deqn{\theta_j = \beta_0 + \beta_1 T_j + \varepsilon_j,}
and subject-specific random effects \eqn{(b_i, \zeta_i)} jointly normal.
Here \eqn{T_j} is an indicator of group membership for the item-specific effect.
}

\usage{
ILHTEdif(resp_mat, group, subject_ids = NULL, alpha = 0.05,
         nAGQ = 1, purify = FALSE,
         match = c("none", "total", "restscore"),
         maxIter = 2)
}

\arguments{
  \item{resp_mat}{A numeric \code{matrix} or \code{data.frame} of binary responses (0/1),
  rows = subjects, columns = items.}
  \item{group}{A vector of length \code{nrow(resp_mat)} indicating group membership
  (factor with two levels or numeric 0/1; the second level is treated as the focal group).}
  \item{subject_ids}{Optional vector of subject IDs (length \code{nrow(resp_mat)});
  defaults to \code{1:nrow(resp_mat)}.}
  \item{alpha}{Numeric in \eqn{(0,1)}. Two-sided significance level used to form the
  decision threshold \eqn{\pm z_{1-\alpha/2}\,\mathrm{SD}(\zeta)}.}
  \item{nAGQ}{Integer. Number of adaptive Gauss--Hermite quadrature points passed to
  \code{\link[lme4]{glmer}}. \code{1} is typically accurate; \code{0} (Laplace) is faster.}
  \item{purify}{Logical. If \code{TRUE}, perform iterative purification up to \code{maxIter}
  by recomputing the matching score after removing flagged items.}
  \item{match}{Character. Matching method: \code{"none"} (no matching covariate),
  \code{"total"} (total score over all items), or \code{"restscore"} (total excluding
  currently flagged items in later purification iterations).}
  \item{maxIter}{Integer. Maximum number of purification iterations (default \code{2}).}
}

\details{
Let \eqn{Y_{ij}\in\{0,1\}} be the response of subject \eqn{i} to item \eqn{j}. The proposed IL-HTE model
is fitted via a generalized linear mixed model (GLMM):
\deqn{\operatorname{logit}\{P(Y_{ij}=1)\} = \theta_j + b_i + \zeta_i T_j + \gamma S_i,}
where \eqn{b_i} is a subject intercept, \eqn{\zeta_i} a subject-specific group slope (random effect),
\eqn{T_j} encodes the focal-vs-reference group effect at the item level, and \eqn{S_i} is an optional
matching score (total or rest-score). The item location \eqn{\theta_j} is modeled as
\deqn{\theta_j = \beta_0 + \beta_1 T_j + \varepsilon_j}
with \eqn{\varepsilon_j} random across items.
Random effects \eqn{(b_i, \zeta_i)} are assumed jointly normal with unstructured covariance.

Iterative purification, when enabled, proceeds by (i) fitting the GLMM, (ii) flagging items with
\eqn{|\hat{\zeta}_j| > \mathrm{crit}} where \code{crit = qnorm(1 - alpha/2) * SD(zeta)} is obtained from the
random-effect standard deviation, (iii) recomputing the matching score excluding flagged items
(\code{match = "restscore"}) or including all items (\code{match = "total"}), and (iv) refitting until
convergence or \code{maxIter} iterations.

Note: the estimation process can be long.
}

\value{
A list with components:
\describe{
  \item{model}{Fitted \code{\link[lme4]{glmer}} object (final iteration).}
  \item{itemDIF}{\code{data.frame} with item IDs and random-slope estimates
                 \eqn{\hat{\zeta}_j}.}
  \item{itemSig}{Subset of \code{itemDIF} where \eqn{|\hat{\zeta}_j| > \mathrm{crit}}.}
  \item{crit}{Numeric. Decision threshold
              \eqn{z_{1-\alpha/2}\times \mathrm{SD}(\zeta)}.}
  \item{plot}{A \code{\link[ggplot2]{ggplot}} object showing \eqn{\hat{\zeta}_j} with
              \eqn{\pm} threshold.}
}
}


\seealso{
\code{\link[lme4]{glmer}}, \code{\link[stats]{qnorm}}, \code{\link[ggplot2]{ggplot}}
}

\note{
\itemize{
  \item The function expects binary responses. Any entry outside \{0,1\} triggers an error.
  \item With \code{purify = TRUE} and \code{match = "restscore"}, flagged items are excluded from
        the matching score in subsequent iterations.
  \item Setting \code{nAGQ = 0} can substantially reduce run time at a small accuracy cost.
}
}

\references{
 Gilbert, J. B. (2024). Modeling item-level heterogeneous treatment effects: A tutorial with the glmer function from the lme4 package in R. \emph{Behavior Research Methods, 56}, 5055–5067. \doi{https://doi.org/10.3758/s13428-023-02245-8}
}

\author{   
Sebastien Beland \cr
Faculte des sciences de l'education \cr
Universite de Montreal (Canada) \cr
\email{sebastien.beland@umontreal.ca}\cr 
Josh Gilbert\cr 
Harvard Graduate School of Education\cr
Harvard University (USA)\cr
\email{josh.b.gilbert@gmail.com}\cr
}

\examples{

## Not run: 
# With real data

data(verbal)
Data <- verbal[,1:24]
group <- verbal[,24]

\donttest{

res1 <- ILHTEdif(
  resp_mat    = Data,
  group       = group,
  alpha       = 0.05
)

# With simulate data, forcing NF = NR

set.seed(2025)
NR <- 300
sim <- SimDichoDif(
  It     = 20,
  ItDIFa = c(2, 5),
  ItDIFb = c(8, 12),
  NR     = NR,
  NF     = NR,         # Same size for NF and NR
  a      = rep(1, 20),
  b      = rnorm(20, 0, 1),
  Ga     = c(0.5, -0.5),
  Gb     = c(1, -1)
)

# Extract response matrix and group vector
resp_mat    <- sim$data[, 1:20]
group       <- factor(sim$data[, 21], labels = c("Ref", "Focal"))
subject_ids <- seq_len(nrow(resp_mat))

# Run the DIF analysis
res2 <- ILHTEdif(
  resp_mat    = resp_mat,
  group       = group,
  subject_ids = subject_ids,
  alpha       = 0.05
)

# With rest score
res3 <- ILHTEdif(
     resp_mat    = resp_mat,
     group       = group,
     subject_ids = subject_ids,
     alpha       = 0.05,
     nAGQ        = 1,
     purify      = FALSE,           # activate purification
     match       = "restscore",    
     maxIter     = 3               # up to 3 purification passes
 )

# With purification

res4 <- ILHTEdif(
     resp_mat    = resp_mat,
     group       = group,
     subject_ids = subject_ids,
     alpha       = 0.05,
     nAGQ        = 1,
     purify      = TRUE,           # activate purification
     match       = "total",    
     maxIter     = 3               # up to 3 purification passes
 )


# View results for res2
print(res2$itemDIF)   # all Zeta estimates
print(res2$itemSig)   # those beyond ±1.96·SD
print(res2$plot)      # plot of Zeta ±1.96·SD
}
## End(Not run)
}