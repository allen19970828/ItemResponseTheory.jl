\name{lassoDIF.CV}
\alias{lassoDIF.CV}

\title{Detection of Differential Item Functioning Using the Lasso Approach: Selection of Optimal \eqn{\lambda} via Cross-Validation}

\description{
Performs DIF detection using a lasso-penalized logistic regression model for dichotomous items and selects the optimal penalty parameter \eqn{\lambda} via cross-validation.
}

\usage{
lassoDIF.CV(Data, group, nfold = 5, lambda = NULL, ...)
}

\arguments{\item{...}{Additional arguments passed to internal methods.}

  \item{Data}{A numeric data frame or matrix: either only the item responses or the item responses with a group membership column.}
  \item{group}{A numeric or character vector: either a vector of group membership or a column index/name indicating group membership in \code{Data}.}
  \item{nfold}{Integer: the number of folds used in cross-validation. Default is 5.}
  \item{lambda}{Optional numeric vector of \eqn{\lambda} values to be used in the penalization path. If \code{NULL}, a default sequence is used.}
}

\value{
A list with the following components:
  \item{DIFitems}{Indices of items flagged as exhibiting DIF.}
  \item{DIFpars}{Matrix of estimated DIF parameters for each item.}
  \item{crit.value}{Cross-validation criterion values (deviance) across the \eqn{\lambda} path.}
  \item{crit.type}{The type of criterion used, here \code{"cv"}.}
  \item{lambda}{Vector of \eqn{\lambda} values considered.}
  \item{opt.lambda}{The optimal \eqn{\lambda} value selected via cross-validation.}
  \item{glmnet.fit}{Fitted \code{glmnet} model object.}
}

\details{
This function detects uniform differential item functioning (DIF) using a lasso-penalized logistic regression model and selects the penalty parameter \eqn{\lambda^*} that minimizes cross-validation error. For this selected value, the function returns the estimated DIF parameters for all items and flags those with non-zero DIF effects.

Note: The performance of the method depends on choices such as the number of folds and the grid of \eqn{\lambda} values. We strongly recommend testing different configurations to assess the robustness of the results before interpretation.
}

\references{
Magis, D., Tuerlinckx, F., & De Boeck, P. (2015). Detection of Differential Item Functioning Using the Lasso Approach. Journal of Educational and Behavioral Statistics, 40(2), 111–135. https://doi.org/10.3102/1076998614559747
 }

\author{
    David Magis \cr
    Data science consultant at IQVIA Belux \cr
    Brussels, Belgium \cr
    Carl F. Falk \cr
    Department of Psychology \cr
    McGill University (Canada)  \cr
    \email{carl.falk@mcgill.ca}, \url{https://www.mcgill.ca/psychology/carl-f-falk} \cr
    Sebastien Beland \cr
    Faculte des sciences de l'education \cr
    Universite de Montreal (Canada) \cr
    \email{sebastien.beland@umontreal.ca} \cr
 }

\examples{
\dontrun{

# With the Verbal data set

data(verbal)

Dat    <-verbal[,1:20]
Member <-verbal[,26]

# Using cross-validation
set.seed(1234) 

cv.res <- lassoDIF.CV(Dat, Member, nfold=5)
cv.res

# With simulated data

It   <- 15 # number of items
ItDIFa <- NULL
ItDIFb <- c(1,3)
NR   <- 100 # number of responses for group 1 (reference)
NF   <- 100 # number of responses for group 2 (focal)
a    <- rep(1,It)          # for tests: runif(It,0.2,.5)  
b    <- rnorm(It,1,.5)  
Gb   <- rep(2,2)           # Group value for U-DIF
Ga   <- 0                  # Group value for NU-DIF: need to be fix to 0 for U-DIF
Out1 <- SimDichoDif(It,ItDIFa,ItDIFb,NR,NF,a,b,Ga,Gb)
Dat<-Out1$data[,1:15]
Member<-Out1$data[,16]

set.seed(1234) # appears to be sensitive to random number seed

cv.res <- lassoDIF.CV(Dat, Member, nfold=5)
cv.res

 }
 }



