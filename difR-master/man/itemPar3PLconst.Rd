\name{itemPar3PLconst}
\alias{itemPar3PLconst}

\title{Item parameter estimation for DIF detection using constrained 3PL model}

\description{
 Fits the 3PL model with constrained pseudo-guessing values and returns related item parameter estimates.
}

\usage{
itemPar3PLconst(data, c=rep(0,ncol(data)))
}

\arguments{
 \item{data}{numeric: the data matrix.}
 \item{c}{numeric value or vector of constrained pseudo-guessing parameters. See \bold{Details}.}
}

\value{
 A matrix with one row per item and six columns: the item discrimination \emph{a} and difficulty estimates \emph{b}, the corresponding standard errors \emph{se(a)} and \emph{se(b)}, 
 the covariances \emph{cov(a,b)} and the constrained pseudo-guessing values \emph{c}.
}
 
\details{
 \code{itemPar3PLconst} permits to get item parameter estimates from the 3PL model for which the pseudo-guessing parameters are constrained to some fixed values. 
 The output is ordered such that it can be directly used with the general \code{\link{itemParEst}} command, as well as the methods of Lord (\code{\link{difLord}}) 
 and Raju (\code{\link{difRaju}}) and Generalized Lord's (\code{\link{difGenLord}}) to detect differential item functioning. 

 The output is similar to that of \code{\link{itemPar2PL}} method to fit the 2PL model; an additional column is included and holds the fixed pseudo-guessing 
 parameter values.

 The \code{data} is a matrix whose rows correspond to the subjects and columns to the items. 

 Missing values are allowed but must be coded as \code{NA} values. They are discarded for item parameter estimation.

 The argument \code{c} can be either a single numeric value or a numeric vector of the same length of the number of items. In the former case, the pseudo-guessing
 parameters are considered to be all identical to the given \code{c} value; otherwise \code{c} is directly used to constraint these parameters.
  
 The constrained 3PL model is fitted using marginal maximum likelihood by means of the functions from the \code{ltm} package (Rizopoulos, 2006).
}

\note{
 The constrained 3PL model is fitted under the linear parametrization in \code{tpm}, the covariance matrix is extracted with the \code{vcov()} function, and final standard errors and covariances are derived by the Delta method. See Rizopoulos (2006) for further details, and the \code{Note.pdf} document in the \code{difR} package for mathematical details.
}

\references{ 
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
    \email{raiche.gilles@uqam.ca}\cr 
 }

   
\seealso{
 \code{\link{itemPar1PL}}, \code{\link{itemPar2PL}}, \code{\link{itemPar3PL}}, \code{\link{itemParEst}}, \code{\link{difLord}}, \code{\link{difRaju}}, 

 \code{\link{difGenLord}}
 }

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)

 # Constraining all pseudo-guessing parameters to be equal to 0.05
 itemPar3PLconst(verbal[,1:24], c = 0.05)

 # Constraining pseudo-guessing values to  0.1 for the first 10 items,
 # and to 0.05 for the remaining ones
 itemPar3PLconst(verbal[,1:24], c = c(rep(0.1, 10), rep(0.05, 14)))
 }
 }
