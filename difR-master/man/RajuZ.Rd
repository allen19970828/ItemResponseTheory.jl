\name{RajuZ}
\alias{RajuZ}

\title{Raju's area DIF statistic}

\description{
 Calculates the Raju's statistics for DIF detection. 
 }

\usage{
RajuZ(mR, mF, signed = FALSE)
 }

\arguments{
 \item{mR}{numeric: the matrix of item parameter estimates (one row per item) for the reference group. See \bold{Details}.}
 \item{mF}{numeric: the matrix of item parameter estimates (one row per item) for the focal group. See \bold{Details}.}
 \item{signed}{logical: should the \emph{signed} area be computed, or the \emph{unsigned} (i.e. in absolute value) ara?
               Default is \code{FALSE}, i.e. the unsigned area. See \bold{Details}.}
}

\value{
 A list with two components:
 \item{res}{a matrix with one row per item and three columns, holding respectively Raju's area between the two item characteristic curves, its 
 standard error and the Raju DIF statistic (the latter being the ratio of the first two columns).}
 \item{signed}{the value of the \code{signed} argument.}
}
 
\details{
 This command computes the Raju's area statistic (Raju, 1988, 1990) in the specific framework of differential item functioning. It forms the basic command 
 of \code{\link{difRaju}} and is specifically designed for this call.

 The matrices \code{mR} and \code{mF} must have the same format as the output of the command \code{\link{itemParEst}} and one the possible models (1PL, 2PL
 or constrained 3PL). The number of columns therefore equals two, five or six, respectively. Note that the unconstrained 3PL model cannot be used in this 
 method: all pseudo-guessing parameters must be equal in both groups of subjects. Moreover, item parameters of the focal must be on the  same scale of that 
 of the reference group. If not, make use of e.g. equal means anchoring (Cook and Eignor, 1991) and \code{\link{itemRescale}} to transform them adequately. 

 By default, the \emph{unsigned} area, given by Equation (57) in Raju (1990), is computed. It makes use of Equations (14), (15), (23) and
 (46) for the numerator, and Equations (17), (33) to (39), and (52) for the denominator of the \emph{Z} statistic. However, the
 \emph{signed} area, given by Equation (56) in Raju (1990), can be used instead. In this case, Equations (14), (21) and (44) are used
 for the numerator, and Equations (17), (25) and (48) for the denominator. The choice of the type of area is fixed by the logical
 \emph{signed} argument, with default value \code{FALSE}. 
}

\references{
 Cook, L. L. and Eignor, D. R. (1991). An NCME instructional module on IRT equating methods. \emph{Educational Measurement: Issues and Practice, 10}, 37-45.
 
 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

 Raju, N.S. (1988). The area between two item characteristic curves. \emph{Psychometrika, 53}, 495-502. \doi{10.1007/BF02294403}

 Raju, N. S. (1990). Determining the significance of estimated signed and unsigned areas between two item response functions. \emph{Applied Psychological Measurement, 14}, 197-207. \doi{10.1177/014662169001400208}
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
 \code{\link{itemParEst}}, \code{\link{itemRescale}}, \code{\link{difRaju}}, \code{\link{dichoDif}}
}

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)
 attach(verbal)

 # Splitting the data into reference and focal groups
 nF <- sum(Gender)
 nR <- nrow(verbal)-nF
 data.ref <- verbal[,1:24][order(Gender),][1:nR,]
 data.focal <- verbal[,1:24][order(Gender),][(nR+1):(nR+nF),]

 # Pre-estimation of the item parameters (1PL model)
 mR <- itemParEst(data.ref,model = "1PL")
 mF <- itemParEst(data.focal,model = "1PL")
 mF <- itemRescale(mR, mF)

 # Signed and unsigned Raju statistics
 RajuZ(mR, mF)
 RajuZ(mR, mF, signed = TRUE)

 # Pre-estimation of the item parameters (2PL model)
 mR <- itemParEst(data.ref, model = "2PL")
 mF <- itemParEst(data.focal, model = "2PL")
 mF <- itemRescale(mR, mF)

 # Signed and unsigned Raju statistics
 RajuZ(mR, mF)
 RajuZ(mR, mF, signed = TRUE)
 
 # Pre-estimation of the item parameters (constrained 3PL model)
 mR <- itemParEst(data.ref, model = "3PL", c = 0.05)
 mF <- itemParEst(data.focal, model = "3PL", c =0 .05)
 mF <- itemRescale(mR, mF)
 
 # Signed and unsigned Raju statistics
 RajuZ(mR, mF)
 RajuZ(mR, mF, signed = TRUE)
 }
 }
