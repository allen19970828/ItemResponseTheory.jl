\name{breslowDay}
\alias{breslowDay}


\title{Breslow-Day DIF statistic}

\description{
 Computes Breslow-Day statistics for DIF detection. 
 }

\usage{
breslowDay(data, member, match = "score", anchor = 1:ncol(data), 
     BDstat = "BD")
 }

\arguments{
 \item{data}{numeric: the data matrix (one row per subject, one column per item).}
 \item{member}{numeric: the vector of group membership with zero and one entries only. See \bold{Details}.}
 \item{match}{specifies the type of matching criterion. Can be either \code{"score"} (default) to compute the test score, or any continuous or discrete variable with the same length as the number of rows of \code{data}. See \bold{Details}.}
 \item{anchor}{a vector of integer values specifying which items (all by default) are currently considered as anchor (DIF free) items. See \bold{Details}.}
 \item{BDstat}{character specifying the DIF statistic to be used. Possible values are \code{"BD"} (default) and \code{"trend"}. See \bold{Details}.}
 }
 
\value{
 A list with three arguments:
 \item{res}{A matrix with one row per item and three columns: the first one contains the Breslow-Day statistic values, the second column indicates 
 the degrees of freedom, and the last column displays the asymptotic \emph{p}-values.}
 \item{BDstat}{the value of the \code{BDstat} argument.}
\item{match}{a character string, either \code{"score"} or \code{"matching variable"} depending on the \code{match} argument.}
}


\details{
 \code{breslowDay} computes one of the Breslow-Day statistics (1980) in the specific framework of differential item functioning. It forms the basic command 
 of \code{\link{difBD}} and is specifically designed for this call.
 
 The data are supplied by the \code{data} argument, with one row per subject and one column per item. Missing values are allowed but must be coded as \code{NA}
 values. They are discarded from sum-score computation.
  
 The vector of group membership, specified by the \code{member} argument, must hold only zeros and ones, a value of zero corresponding to the
 reference group and a value of one to the focal group.

 The matching criterion can be either the test score or any other continuous or discrete variable to be passed in the \code{breslowDay} function. This is specified by the \code{match} argument. By default, it takes the value \code{"score"} and the test score (i.e. raw score) is computed. The second option is to assign to \code{match} a vector of continuous or discrete numeric values, which acts as the matching criterion. Note that for consistency this vector should not belong to the \code{data} matrix.

 Option \code{anchor} sets the items which are considered as anchor items for computing Breslow-Day DIF statistics. Items other than the anchor items and
 the tested item are discarded. \code{anchor} must hold integer values specifying the column numbers of the corresponding anchor items. It is 
 primarily designed to perform item purification.

 Two test statistics are available: the usual Breslow-Day statistic for testing homogeneous association (Aguerri, Galibert, Attorresi and Maranon, 2009)
 and the trend test statistic for assessing some monotonic trend in the odss ratios (Penfield, 2003). The DIF statistic is supplied by the \code{BDstat} argument, 
 with values \code{"BD"} (default) for the usual statistic and \code{"trend"} for the trend test statistic.
}


\references{
Aguerri, M.E., Galibert, M.S., Attorresi, H.F. and Maranon, P.P. (2009). Erroneous detection of nonuniform DIF using the Breslow-Day test in a short test. \emph{Quality and Quantity, 43}, 35-44. \doi{10.1007/s11135-007-9130-2}

Breslow, N.E. and Day, N.E. (1980). \emph{Statistical methods in cancer research, vol. I: The analysis of case-control studies}. Scientific Publication No 32. International Agency for Research on Cancer, Lyon, France.

Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

Penfield, R.D. (2003). Application of the Breslow-Day test of trend in odds ratio heterogeneity to the detection of nonuniform DIF. \emph{Alberta Journal of 
Educational Research, 49}, 231-243.
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
\code{\link{difBD}}, \code{\link{dichoDif}}
 }

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)

 # With all items as anchor items
 breslowDay(verbal[,1:24], verbal[,26])

 # With all items as anchor items and trend
 # test statistic
 breslowDay(verbal[,1:24], verbal[,26], BDstat = "trend")

 # Removing item 3 from the set of anchor items
 breslowDay(verbal[,1:24], verbal[,26], anchor = c(1:5, 7:24))
}
}

