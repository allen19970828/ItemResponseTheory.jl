\name{difMantel.poly}
\alias{difMantel.poly}
\title{Mantel Differential Item Functioning Detection for Polytomous Items}
\description{
Implements Mantel's (1963) chi-square test for detecting DIF in polytomous (ordinal) items, with optional iterative purification and Liu–Agresti (1996) cumulative common odds ratios per item.
}
\usage{
difMantel.poly(data, group, focal.name, ref.name,
               match = "score", sig.level = 0.05,
               purify = FALSE, max.iter = 10)
}
\arguments{
  \item{data}{Matrix or data frame of polytomous item responses (one row per subject, one column per item).}
  \item{group}{Vector or factor indicating group membership (same length as \code{nrow(data)}). The function internally reorders levels so that \code{ref.name} is the reference and \code{focal.name} the focal group.}
  \item{focal.name}{Value in \code{group} corresponding to the focal group.}
  \item{ref.name}{Value in \code{group} corresponding to the reference group.}
  \item{match}{Matching variable: \code{"score"} (total score) or \code{"restscore"} (total score excluding the tested item).}
  \item{sig.level}{Significance level used during purification (default \code{0.05}).}
  \item{purify}{Logical. If \code{TRUE} and \code{match="score"}, performs iterative purification by removing flagged items from the anchor set until convergence or \code{max.iter} is reached. Ignored when \code{match="restscore"}.}
  \item{max.iter}{Maximum number of purification iterations (default \code{10}).}
}
\value{
A \code{data.frame} with \emph{one row per item} and the following columns:
  \item{Stat}{Mantel chi-square statistic (1 df), conditioning on the chosen matching score.}
  \item{p.value}{Associated p-value.}
  \item{p.adj}{Holm-adjusted p-value across items.}
  \item{Psi_hat}{Liu–Agresti cumulative common odds ratio estimate \eqn{\hat\Psi}.}
  \item{Alpha_hat}{\eqn{\log(\hat\Psi)}.}
  \item{SE_log_Psi}{Standard error of \eqn{\log(\hat\Psi)} (large-sample Liu–Agresti).}
  \item{rho.spear}{Spearman correlation between the item score and the matching score (score or restscore).}
  \item{LA.valid}{Logical flag indicating whether Liu–Agresti estimates were computable for the item (e.g., sufficient data in both groups across strata).}
}
\details{
For each item, the Mantel statistic is computed on ordinal responses while conditioning on a matching score. When \code{match="score"}, the total test score is used; when \code{match="restscore"}, the current item is excluded from the matching score to reduce contamination.

Cumulative common odds ratios (Liu & Agresti, 1996) are computed \emph{conditional on the same strata} (the matching score) and reported along with their standard errors via the Liu–Agresti delta method. Internally, the function coerces \code{group} to have levels \code{c(ref.name, focal.name)} to ensure coherent sign/orientation of \eqn{\log(\Psi)}.

When \code{purify=TRUE} (and \code{match="score"}), the anchor set excludes items flagged as DIF at level \code{sig.level}. Iterations stop when the set stabilizes or \code{max.iter} is reached. The final result is returned, with attributes \code{"iterations"} and \code{"final_anchors"} set when purification was performed.

\strong{Notes.}
(i) Liu–Agresti estimates are computed only when both groups are observed within strata with sufficient counts; otherwise \code{LA.valid=FALSE}. 
(ii) Missing responses should be handled prior to analysis (e.g., listwise deletion); this function does not impute missing values.
}
\references{
Mantel, N. (1963). Chi-square tests with one degree of freedom: Extensions of the Mantel–Haenszel procedure. \emph{Journal of the American Statistical Association}, 58, 690–700.

Liu, I., & Agresti, A. (1996). Mantel–Haenszel-type inference for cumulative odds ratios with a stratified ordinal response. \emph{Biometrics}, 52(4), 1223–1234.
}
\seealso{
  \code{\link{liu_agresti_ccor}}, \code{\link[stats]{mantelhaen.test}}
}
\author{
Sebastien Beland\\
Faculte des sciences de l'education, Université de Montreal (Canada)\\
\email{sebastien.beland@umontreal.ca}
}
\examples{
\dontrun{
# Real data example
data(SCS)
# Without purification
difMantel.poly(data = SCS[, 1:10], group = SCS$Gender, focal.name = 1, 
ref.name = 2, purify = FALSE)

# Without purification and restscore
difMantel.poly(data = SCS[, 1:10], group = SCS$Gender, focal.name = 1, 
ref.name = 2, purify = TRUE,match = "restscore")

# With purification
difMantel.poly(data = SCS[, 1:10], group = SCS$Gender, focal.name = 1, 
ref.name = 2, purify = TRUE)

# With simulated data

set.seed(1234)

# original item parameters
a <- rlnorm(10, -0.5)  # slopes
b <- runif(10, -2, 2)  # difficulty
d <- list()
d[[1]] <- c(0, 2, .5, -.15, -1.1)
d[[2]] <- c(0, 2, .25, -.45, -.75)
d[[3]] <- c(0, 1, .5, -.65, -1)
d[[4]] <- c(0, 2, .5, -.85, -2)
d[[5]] <- c(0, 1, .25, -.05, -1)
d[[6]] <- c(0, 2, .5, -.95, -1)
d[[7]] <- c(0, 1, .25, -.35, -2)
d[[8]] <- c(0, 2, .5, -.15, -1)
d[[9]] <- c(0, 1, .25, -.25, -2)
d[[10]] <- c(0, 2, .5, -.35, -1)

# Uniform DIF
It <- 10; NR <- 1000; NF <- 1000
ItDIFa <- NULL; Ga <- NULL
ItDIFb <- c(1, 3)
Gb <- rep(.5, 2)

Out.Unif <- SimPolyDif(It, ItDIFa, ItDIFb, NR, NF, a, b, d,
                       ncat = 5, Ga = Ga, Gb = Gb)
Out.Unif$ipars
Data <- Out.Unif$data

# Without purification and rest score
difMantel.poly(data = Data[, 1:10], group = Data$group, focal.name = "G1", 
ref.name = "G2", purify = FALSE,match = "restscore")

# With purification
difMantel.poly(data = Data[, 1:10], group = Data$group, focal.name = "G1", 
ref.name = "G2", purify = TRUE)

# We implemented a specific S3 plot method: plot.Logistic. It can be used as follows:
res <- difMantel.poly(data = Data[, 1:10], group = Data$group, focal.name = "G1", 
ref.name = "G2", purify = FALSE)
plot.MHPoly(res)
}
}














