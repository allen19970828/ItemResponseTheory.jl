\name{itemParEst}
\alias{itemParEst}

\title{Item parameter estimation for DIF detection}

\description{
 Fits a specified logistic IRT model and returns related item parameter estimates.
 }

\usage{
itemParEst(data, model, c = NULL, engine = "ltm", discr = 1)
 }

\arguments{
 \item{data}{numeric: the data matrix.}
 \item{model}{character: the IRT model to be fitted (either \code{"1PL"}, \code{"2PL"} or \code{"3PL"}).}
 \item{c}{optional numeric value or vector giving the values of the constrained pseudo-guessing parameters. See \bold{Details}.}
 \item{engine}{character: the engine for estimating the 1PL model, either \code{"ltm"} (default) or \code{"lme4"}.}
 \item{discr}{either \code{NULL} or a real positive value for the common discrimination parameter (default is 1). Used only if \code{model} is \code{"1PL"}
              and \code{engine} is \code{"ltm"}. See \bold{Details}.}
 }

\value{
 A matrix with one row per item and at most nine columns, with item parameter estimates, standard errors and covariances, if any. See \bold{Details}.
 }
 
\details{
 \code{itemParEst} permits to get item parameter estimates of some pre-specified logistic IRT model, together with estimates of 
 the standard errors and the covariances between item parameters, if any. The output is ordered such that it can be directly used
 with the methods of Lord (\code{\link{difLord}}) and Raju (\code{\link{difRaju}}) and Generalized Lord's (\code{\link{difGenLord}}) 
 to detect differential item functioning.

 The \code{data} is a matrix whose rows correspond to the subjects and columns to the items. 

 Missing values are allowed but must be coded as \code{NA} values. They are discarded for item parameter estimation.
  
 If the model is not the 1PL model, or if \code{engine} is equal to \code{"ltm"}, the selected IRT model is fitted using marginal maximum likelihood
 by means of the functions from the \code{ltm} package (Rizopoulos, 2006). Otherwise, the 1PL model is fitted as a generalized 
 linear mixed model, by means of the \code{glmer} function of the \code{lme4} package (Bates and Maechler, 2009). With the \code{"ltm"} engine, the 
 common discrimination parameter can be either fixed to a constant value using the \code{discr} argument, or it can be estimated (though not returned) 
 by specifying \code{discr} to \code{NULL}. The default value of the common discrimination is 1.

 The 3PL model can be fitted either unconstrained or by fixing the pseudo-guessing values. In the latter case the argument \code{c} 
 holds either a numeric vector of same length of the number of items, with one value per item pseudo-guessing parameter, or a single value which
 is duplicated for all the items. If \code{c} is different from \code{NULL} then the 3PL model is always fitted (whatever the value of \code{model}).

 Each row of the output matrix corresponds to one item of the \code{data} set; the number of columns depends on the fitted model. At most,
 nine columns are produced, with the unconstrained 3PL model. The order of the columns is the following: first, the estimates of item discrimination 
 \emph{a}, difficulty \emph{b} and pseudo-guessing \emph{c}; second,  the corresponding standard errors \emph{se(a)}, \emph{se(b)} and \emph{se(c)}; 
 finally, the covariances between the item parameters, \emph{cov(a,b)}, \emph{cov(a,c)} and \emph{cov(b,c)}. 
 
 If the 2PL model is fitted, only five columns are displayed: \emph{a}, \emph{b}, \emph{se(a)}, \emph{se(b)} and \emph{cov(a,b)}. 
 In case of the 1PL model, only \emph{b} and \emph{se(b)} are returned. If the constrained 3PL is considered, the output matrix holds six columns, 
 the first five being identical to those from the 2PL model, and the last one holds the fixed pseudo-guessing parameters.
 }

\note{
 Whenever making use of the \code{ltm} package to fit the IRT models, the linear parametrization is used, the covariance matrix is extracted with the \code{vcov()} function, and final standard errors and covariances are derived by the Delta method. See Rizopoulos (2006) for further details, and the \code{Note.pdf} document in the \code{difR} package for mathematical details.
}


\references{ 
 Bates, D. and Maechler, M. (2009). lme4: Linear mixed-effects models using S4 classes. R package version 0.999375-31. http://CRAN.R-project.org/package=lme4

 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

 Rizopoulos, D. (2006). ltm: An R package for latent variable modelling and item response theory analyses. \emph{Journal of Statistical Software, 17}, 1--25. \doi{10.18637/jss.v017.i05}
 }


\author{
    David Magis \cr
    Data science consultant at IQVIA Belux \cr
    Brussels, Belgium \cr
    Sebastien Beland \cr
    Faculte des sciences de l'education \cr
    Universite de Montreal (Canada) \cr
    \email{sebastien.beland@umontreal.ca} \cr
    Gilles Raiche \cr
    Universite du Quebec a Montreal \cr
    \email{raiche.gilles@uqam.ca} \cr 
 }


\seealso{
 \code{\link{itemPar1PL}}, \code{\link{itemPar2PL}}, \code{\link{itemPar3PL}}, \code{\link{itemPar3PLconst}}, \code{\link{difLord}}, \code{\link{difRaju}}, 

 \code{\link{difGenLord}}
 }

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)

 # Estimation of the item parameters (1PL model, "ltm" engine)
 items.1PL <- itemParEst(verbal[,1:24], model = "1PL")

 # Estimation of the item parameters (1PL model, "ltm" engine,
 # estimated common discrimination parameter)
 items.1PL <- itemParEst(verbal[,1:24], model = "1PL", discr = NULL)

 # Estimation of the item parameters (1PL model, "lme4" engine)
 items.1PL <- itemParEst(verbal[,1:24], model = "1PL", engine = "lme4")

 # Estimation of the item parameters (2PL model)
 items.2PL <- itemParEst(verbal[,1:24], model = "2PL")

 # Estimation of the item parameters (3PL model)
 # items.3PL <- itemParEst(verbal[,1:24], model = "3PL")

 # Constraining all pseudo-guessing values to be equal to 0.05
 items.3PLc <- itemParEst(verbal[,1:24], model = "3PL", c = 0.05)
}
}
