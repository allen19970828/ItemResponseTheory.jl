\name{lassoDIF.ABWIC}
\alias{lassoDIF.ABWIC}

\title{Detection of Differential Item Functioning Using the Lasso Approach: Selection of Optimal \eqn{\lambda} Value}

\description{
Performs DIF detection using a lasso-penalized logistic regression model for dichotomous items and selects the optimal value of the penalty parameter \eqn{\lambda} using an information criterion.
}

\usage{
lassoDIF.ABWIC(Data, group, type = "AIC", N = NULL, lambda = NULL, ...)
}

\arguments{\item{...}{Additional arguments passed to internal methods.}
  \item{Data}{A numeric data frame or matrix: either only the item responses or the item responses with a group membership column.}
  \item{group}{A numeric or character vector: either a vector of group membership or a column index/name indicating group membership in \code{Data}.}
  \item{type}{Character string indicating the criterion used to select the optimal \eqn{\lambda} value. Must be one of \code{"AIC"}, \code{"BIC"}, or \code{"WIC"}.}
  \item{N}{Integer: total sample size. If \code{NULL}, it is inferred from the number of rows in \code{Data}.}
  \item{lambda}{Optional numeric vector of \eqn{\lambda} values to be used in the penalization path. If \code{NULL}, a default sequence is used.}
}

\value{
A list with the following components:
  \item{DIFitems}{Indices of items flagged as exhibiting DIF.}
  \item{DIFpars}{Matrix of estimated DIF parameters for each item.}
  \item{crit.value}{Numeric vector of criterion values (e.g., AIC or BIC) across the \eqn{\lambda} path.}
  \item{crit.type}{The criterion used to select the optimal \eqn{\lambda} (either \code{"AIC"}, \code{"BIC"}, or \code{"WIC"}).}
  \item{lambda}{Vector of \eqn{\lambda} values considered.}
  \item{opt.lambda}{The optimal \eqn{\lambda} value selected.}
  \item{glmnet.fit}{Fitted \code{glmnet} model object.}
}

\details{
This function detects uniform DIF using a penalized logistic regression model based on the 2PL model. The model includes item-by-group interaction terms that are subject to lasso penalization. The optimal \eqn{\lambda} value is selected based on either the AIC, BIC, or WIC criterion.

For the selected \eqn{\lambda^*}, the function returns DIF parameters for all items, and flags items whose corresponding DIF parameters are non-zero.

Note: the function's behavior is sensitive to input parameters (e.g., criterion type, sample size, \eqn{\lambda} grid). It is strongly recommended to explore different settings and validate findings before interpreting DIF detection results.
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

# Using AIC for selection
lassoDIF.ABWIC(Dat, Member, type="AIC")

# Using BIC for selection
lassoDIF.ABWIC(Dat, Member, type="BIC")

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
Out1 <- SimDichoDif(It,ItDIFa,ItDIFb,
NR,NF,a,b,Ga,Gb)
Dat<-Out1$data[,1:15]
Member<-Out1$data[,16]

# Using AIC for selection
lassoDIF.ABWIC(Dat, Member, type="AIC")

# Using BIC for selection
lassoDIF.ABWIC(Dat, Member, type="BIC")

# This plot shows how the estimated DIF effects for each item evolve
# as the lasso penalty (lambda) increases

aic.res <- lassoDIF.ABWIC(Dat, Member, type="AIC")
plot_lasso_paths(aic.res$glmnet.fit)
bic.res <- lassoDIF.ABWIC(Dat, Member, type="BIC")
plot_lasso_paths(bic.res$glmnet.fit)

 }
 }



