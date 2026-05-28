\name{difPolyLogistic}
\alias{difPolyLogistic}

\title{Logistic regression DIF statistics for polytomous (ordinal) items}

\description{Computes DIF detection using logistic regression models for ordinal (polytomous) items.}

\usage{
difPolyLogistic(Data, group, focal.name, anchor = NULL, member.type = "group",
match = "score", type = "both", criterion = "LRT", alpha = 0.05, all.cov=FALSE,
purify = FALSE, nrIter = 10, p.adjust.method = NULL, save.output = FALSE,
output = c("out", "default"))
}

\arguments{
\item{Data}{a data frame or matrix: one row per respondent, one column per item. Items must be coded as ordinal variables.}
\item{group}{a vector or column index/name from Data: specifies group membership.}
\item{focal.name}{the label identifying the focal group (ignored if \code{member.type = "cont"}).}
\item{anchor}{a vector of column indices or names specifying anchor (non-DIF) items. If \code{NULL} and \code{purify = FALSE}, all items are used as anchors. Ignored if \code{match} is not \code{"score"}.}
\item{member.type}{\code{"group"} (default) if \code{group} is categorical; \code{"cont"} if \code{group} is continuous.}
\item{match}{matching criterion. Use \code{"score"} for test score, \code{"restscore"} for item-excluded score, or provide an external continuous/discrete vector.}
\item{type}{DIF type to test: \code{"both"} (default), \code{"udif"} (uniform DIF only), or \code{"nudif"} (non-uniform DIF only).}
\item{criterion}{test statistic: \code{"LRT"} (default) for likelihood ratio test or \code{"Wald"} for Wald test.}
\item{alpha}{significance level for DIF detection (default = 0.05).}
\item{all.cov}{logical: whether to return full covariance matrices of the parameter estimates. Default is \code{FALSE}.}
\item{purify}{logical: whether to apply iterative purification to refine anchor items (default = \code{FALSE}). Requires \code{match = "score"}.}
\item{nrIter}{maximum number of iterations for purification (default = 10).}
\item{p.adjust.method}{method for p-value adjustment across items (e.g., \code{"BH"}, \code{"bonferroni"}). Default = \code{NULL}.}
\item{save.output}{logical: if \code{TRUE}, saves output to a text file.}
\item{output}{character vector: \code{output\[1]} is the filename (without extension), \code{output\[2]} is the directory path (or \code{"default"} for working directory).}
}

\value{
Returns an object of class \code{"Logistic"}, a list with elements:
\item{LogistikPoly}{numeric vector of DIF test statistics for each item.}
\item{p.value}{p-values associated with each test statistic.}
\item{logitPar}{matrix of estimated parameters for best-fitting models (per item).}
\item{logitSe}{matrix of standard errors for \code{logitPar}.}
\item{parM0, seM0}{parameter estimates and SEs for the null model (no DIF).}
\item{cov.M0, cov.M1}{covariance matrices for null and full models (if \code{all.cov = TRUE}).}
\item{deltaR2}{effect sizes (McKelvey & Zavoina \eqn{R^2}) per item.}
\item{alpha, thr}{alpha value and corresponding statistical threshold.}
\item{DIFitems}{indices of items detected as DIF (or \code{"No DIF item detected"}).}
\item{type, criterion, match, member.type}{echoed inputs.}
\item{p.adjust.method, adjusted.p}{if adjustment requested, adjusted p-values and method used.}
\item{purification, nrPur, difPur, convergence}{details of the purification process.}
\item{names, anchor.names}{item names and anchor items used.}
\item{save.output, output}{output options echoed.}
}

\details{
The function fits cumulative ordinal logistic regression models (via \code{VGAM::vglm}) to detect DIF in polytomous items.

Three nested models are fit per item and compared to assess DIF:
\itemize{
  \item \eqn{M_0}: No DIF (only match effect)
  \item \eqn{M_1}: Uniform DIF (match + group)
  \item \eqn{M_2}: Uniform + non-uniform DIF (match + group + interaction)
}
\eqn{M_0}, \eqn{M_1}, and \eqn{M_2} are compared using either likelihood-ratio or Wald tests, depending on the \code{criterion} argument.

When \code{match = "restscore"}, the matching variable is defined as the sum score excluding the item being tested.

When \code{purify = TRUE}, the algorithm iteratively refines the anchor set by excluding detected DIF items and updating scores.

This function handles both group-based DIF (\code{member.type = "group"}) and DIF based on continuous moderators (\code{member.type = "cont"}).

For each item, the DIF analysis is performed using only complete cases. Respondents with missing data on the item being tested, the matching variable, or the group variable are excluded from the estimation for that item.

For very strong predictors (e.g., matching variables that nearly perfectly separate response categories), the underlying ordinal regression models may become numerically unstable. This can result in extreme coefficients, saturation warnings, and possibly negative pseudo-R² values. These cases reflect data properties rather than programming errors.
}

\references{
Zumbo, B. D. (1999). \emph{A Handbook on the Theory and Methods of Differential Item Functioning (DIF): Logistic Regression Modeling as a Unitary Framework for Binary and Likert-Type (Ordinal) Item Scores}. Ottawa, ON: Department of National Defense.

Zumbo, B. D. & Thomas, D. R. (1997). A measure of effect size for a model-based approach for studying DIF. \emph{Educational and Psychological Measurement, 57}(4), 679-688.
}

\author{
    Sebastien Beland \cr
    Faculte des sciences de l'education \cr
    Universite de Montreal (Canada) \cr
    \email{sebastien.beland@umontreal.ca} \cr
}

\seealso{\code{LogistikPoly}, \code{VGAM::vglm}}

\examples{
\dontrun{

# With real data

data(SCS)

# Without item purification
difPolyLogistic(SCS[,1:10], group=SCS[,11], 
focal.name = "1", purify=FALSE)  

# Without item purification and the rest score
difPolyLogistic(SCS[,1:10], group=SCS[,11], 
focal.name = "1", purify=FALSE,, match = "restscore") 

# With item purification
difPolyLogistic(SCS[,1:10], group=SCS[,11], 
focal.name = "1", purify=TRUE)

# With item purification
difPolyLogistic(SCS[,1:10], group=SCS[,11], 
focal.name = "1", purify=TRUE)

# With item purification with LRT criterion
difPolyLogistic(SCS[,1:10], group=SCS[,11], 
focal.name = "1", purify=TRUE, criterion = "LRT") 

# With item purification with LRT criterion and alpha = 0.01
difPolyLogistic(SCS[,1:10], group=SCS[,11], 
focal.name = "1", purify=TRUE, criterion = "LRT", alpha = 0.01) 

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

# Without item purification
difPolyLogistic(Out.Unif$data[,1:10], group=Out.Unif$data[,11], 
focal.name = "G1", purify=FALSE)  

# Without item purification and restscore
difPolyLogistic(Out.Unif$data[,1:10], group=Out.Unif$data[,11], 
focal.name = "G1", purify=FALSE, match = "restscore")  

# With item purification
difPolyLogistic(Out.Unif$data[,1:10], group=Out.Unif$data[,11], 
focal.name = "G1", purify=TRUE) 

# With item purification with LRT criterion
difPolyLogistic(Out.Unif$data[,1:10], group=Out.Unif$data[,11], 
focal.name = "G1", purify=TRUE, criterion = "LRT") 

# With item purification with LRT criterion and alpha = 0.01
difPolyLogistic(Out.Unif$data[,1:10], group=Out.Unif$data[,11], 
focal.name = "G1", purify=TRUE, criterion = "LRT", alpha = 0.01)  

# We implemented a specific S3 plot method: plot.Logistic. It can be used as follows

res <- difPolyLogistic(Out.Unif$data[,1:10], group=Out.Unif$data[,11], 
focal.name = "G1", purify=FALSE)
plot.Logistic(res)

 }
 }
