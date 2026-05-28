\name{itemPar1PL}
\alias{itemPar1PL}

\title{Item parameter estimation for DIF detection using Rasch (1PL) model}

\description{
 Fits the Rasch (1PL) model and returns related item parameter estimates.
 }

\usage{
itemPar1PL(data, engine = "ltm", discr = 1)
 }

\arguments{
 \item{data}{numeric: the data matrix.}
 \item{engine}{character: the engine for estimating the 1PL model, either \code{"ltm"} (default) or \code{"lme4"}.}
 \item{discr}{either \code{NULL} or a real positive value for the common discrimination parameter (default is 1). Not used if \code{engine} is \code{"lme4"}.
             See \bold{Details}.}
 }

\value{
 A matrix with one row per item and two columns, the first one with item parameter estimates and the second one with the related standard errors.
 }
 
\details{
 \code{itemPar1PL} permits to get item parameter estimates from the Rasch or 1PL model. The output is ordered such that it can be directly used
 with the general \code{\link{itemParEst}} command, as well as the methods of Lord (\code{\link{difLord}}) and Raju (\code{\link{difRaju}}) and
 Generalized Lord's (\code{\link{difGenLord}}) to detect differential item functioning.

 The \code{data} is a matrix whose rows correspond to the subjects and columns to the items. 

 Missing values are allowed but must be coded as \code{NA} values. They are discarded for item parameter estimation.
 
 The estimation engine is set by the \code{engine} argument. By default (\code{engine="ltm"}), the Rasch model is fitted using marginal maximum likelihood, by means of 
 the function \code{rasch} from the \code{ltm} package (Rizopoulos, 2006). The other option, \code{engine="lme4"}, permits to fit the Rasch model as a generalized 
 linear mixed model, by means of the \code{glmer} function of the \code{lme4} package (Bates and Maechler, 2009).

 With the \code{"ltm"} engine, the common discrimination parameter is set equal to 1 by default. It is possible to fix another value through the argument\code{discr}.
 Alternatively, this common discrimination parameter can be estimated (though not returned) by fixing \code{discr} to \code{NULL}. See the functionalities of 
 \code{\link[ltm:rasch]{rasch}} command for further details.
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
 \code{\link{itemPar2PL}}, \code{\link{itemPar3PL}}, \code{\link{itemPar3PLconst}}, \code{\link{itemParEst}}, \code{\link{difLord}}, \code{\link{difRaju}}, 

\code{\link{difGenLord}}
 }

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)
 
 # Getting item parameter estimates ('ltm' engine)
 itemPar1PL(verbal[, 1:24])

 # Estimating the common discrimination parameter instead
 itemPar1PL(verbal[, 1:24], discr = NULL)

 # Getting item parameter estimates ('lme4' engine) 
 itemPar1PL(verbal[, 1:24], engine = "lme4")
 }
 }

