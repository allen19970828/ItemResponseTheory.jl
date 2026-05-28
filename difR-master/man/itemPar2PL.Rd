\name{itemPar2PL}
\alias{itemPar2PL}

\title{Item parameter estimation for DIF detection using 2PL model}

\description{
 Fits the 2PL model and returns related item parameter estimates, standard errors and covariances between item parameters.
 }

\usage{
itemPar2PL(data)
 }

\arguments{
\item{data}{numeric: the data matrix.}
}

\value{
 A matrix with one row per item and five columns: the estimates of item discrimination \emph{a} and difficulty \emph{b} parameters, the 
 related standard errors \emph{se(a)} and \emph{se(b)}, and the covariances \emph{cov(a,b)}, in this order.
}
 
\details{
 \code{itemPar2PL} permits to get item parameter estimates from the 2PL model. The output is ordered such that it can be directly used
 with the general \code{\link{itemParEst}} command, as well as the methods of Lord (\code{\link{difLord}}) and Raju (\code{\link{difRaju}}) 
 and Generalized Lord's (\code{\link{difGenLord}}) to detect differential item functioning.

 The \code{data} is a matrix whose rows correspond to the subjects and columns to the items.

 Missing values are allowed but must be coded as \code{NA} values. They are discarded for item parameter estimation.
  
 The 2PL model is fitted using marginal maximum likelihood by means of the functions from the \code{ltm} package (Rizopoulos, 2006). 
 }

\note{
 The 2PL model is fitted under the linear parametrization in \code{ltm}, the covariance matrix is extracted with the \code{vcov()} function, and final standard errors and covariances are derived by the Delta method. See Rizopoulos (2006) for further details, and the \code{Note.pdf} document in the \code{difR} package for mathematical details.
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
    \email{raiche.gilles@uqam.ca} \cr 
 }


\seealso{
 \code{\link{itemPar1PL}}, \code{\link{itemPar3PL}}, \code{\link{itemPar3PLconst}}, \code{\link{itemParEst}}, \code{\link{difLord}}, \code{\link{difRaju}}, 

 \code{\link{difGenLord}}
 }

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)

 # Getting item parameter estimates
 itemPar2PL(verbal[,1:24])
 }
 }

