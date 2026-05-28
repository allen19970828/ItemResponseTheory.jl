\name{stdPDIF}
\alias{stdPDIF}

\title{Standardization DIF statistic}

\description{
  Calculates standardized P-difference statistics for DIF detection. 
 }

\usage{
stdPDIF(data, member, match = "score", anchor = 1:ncol(data), stdWeight = "focal")
 }
 
\arguments{
 \item{data}{numeric: the data matrix (one row per subject, one column per item).}
 \item{member}{numeric: the vector of group membership with zero and one entries only. See \bold{Details}.}
  \item{match}{specifies the type of matching criterion. Can be either \code{"score"} (default) to compute the test score, or any continuous or discrete variable with the same length as the number of rows of \code{data}. See \bold{Details}.}
\item{anchor}{a vector of integer values specifying which items (all by default) are currently considered as anchor (DIF free) items. See \bold{Details}.}
 \item{stdWeight}{character: the type of weights used for the standardized P-DIF statistic. Possible values are \code{"focal"} (default),
                  \code{"reference"} and \code{"total"}. See \bold{Details}.}
}

\value{
A list with three arguments:
 \item{resStd}{the vector of the standardized P-DIF statistics.}
 \item{resAlpha}{the vector of standardized alpha values.}
 \item{match}{a character string, either \code{"score"} or \code{"matching variable"} depending on the \code{match} argument.}
}
 
\details{
 This command computes the standardized P-DIF statistic in the specific framework of differential item functioning (Dorans and Kulick, 1986). It forms the basic
 command of \code{\link{difStd}} and is specifically designed for this call. In addition, the standardized alpha values (Dorans, 1989) are also computed as a basis
 for effect size calculation.

 The standardized P-DIF statistic is a weighted average of the difference in proportions of successes in the reference group and in the focal group. The average is
 computed across the test score strata. The weights can be of three kinds (Dorans, 1989; Dorans and Kulick, 1986) and are specified through the \code{stdWeight} 
 argument: the proportion of focal groups examinees within each stratum (\code{stdWeight="focal"}), the proportion of reference group examinees within each stratum
 (\code{stdWeight="reference"}), and the proportion of examinees (from both groups) within each stratum (\code{stdWeight="total"}). By default, the weights are
 built from the focal group. 
 
 Similarly to the 'alpha' estimates of the common odds ratio for the Mantel-Haenszel method (see \code{\link{mantelHaenszel}}), the \emph{standardized alpha values}
 can be computed as rough measures of effect sizes, after a transformation to the Delta Scale (Holland, 1985). See Dorans (1989, p.228, Eqn.15) for further details. 
 
 The data are passed through the \code{data} argument, with one row per subject and one column per item. Missing values are allowed but must be coded as \code{NA}
 values. They are discarded from sum-score computation.
  
 The vector of group membership, specified with \code{member} argument, must hold only zeros and ones, a value of zero corresponding to the reference group and a
 value of one to the focal group.
 
 The matching criterion can be either the test score or any other continuous or discrete variable to be passed in the \code{stdPDIF} function. This is specified by the \code{match} argument. By default, it takes the value \code{"score"} and the test score (i.e. raw score) is computed. The second option is to assign to \code{match} a vector of continuous or discrete numeric values, which acts as the matching criterion. Note that for consistency this vector should not belong to the \code{data} matrix.

 Option \code{anchor} sets the items which are considered as anchor items for computing standardized P-DIF statistics. Items other than the anchor items and the
 tested item are discarded. \code{anchor} must hold integer values specifying the column numbers of the corresponding anchor items. It is mainly designed to
 perform item purification.
}

\references{
 Dorans, N. J. (1989). Two new approaches to assessing differential item functioning. Standardization and the Mantel-Haenszel method. \emph{Applied Measurement in
 Education, 2}, 217-233. \doi{10.1207/s15324818ame0203_3}
 
 Dorans, N. J. and Kulick, E. (1986). Demonstrating the utility of the standardization approach to assessing unexpected differential item performance on the Scholastic Aptitude Test. \emph{Journal of Educational Measurement, 23}, 355-368. \doi{10.1111/j.1745-3984.1986.tb00255.x}

 Holland, P. W. (1985, October). \emph{On the study of differential item performance without IRT}. Paper presented at the meeting of 
 Military Testing Association, San Diego (CA).  

 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}
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
 \code{\link{difStd}}, \code{\link{dichoDif}}, \code{\link{mantelHaenszel}}
 }

\examples{
 \dontrun{
 # Loading of the verbal data
 data(verbal)

 # All items as anchor items
 stdPDIF(verbal[,1:24], verbal[,26])

 # All items as anchor items, reference group weights
 stdPDIF(verbal[,1:24], verbal[,26], stdWeight = "reference")

 # All items as anchor items, both groups' weights
 stdPDIF(verbal[,1:24], verbal[,26], stdWeight = "total")

 # Removing item 6 from the set of anchor items
 stdPDIF(verbal[,1:24], verbal[,26], anchor = c(1:5,7:24))
 }
 }
