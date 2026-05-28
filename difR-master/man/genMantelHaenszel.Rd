\name{genMantelHaenszel}
\alias{genMantelHaenszel}

\title{Generalized Mantel-Haenszel DIF statistic}

\description{
 Calculates the generalized Mantel-Haenszel statistics for DIF detection among multiple groups. 
}

\usage{
genMantelHaenszel(data, member, match = "score", anchor = 1:ncol(data))
}

\arguments{
 \item{data}{numeric: the data matrix (one row per subject, one column per item).}
 \item{member}{numeric: the vector of group membership with zero and positive integer entries only. See \bold{Details}.}
 \item{match}{specifies the type of matching criterion. Can be either \code{"score"} (default) to compute the test score, or any continuous or discrete variable with the same length as the number of rows of \code{data}. See \bold{Details}.}
 \item{anchor}{a vector of integer values specifying which items (all by default) are currently considered as anchor (DIF free) items. See \bold{Details}.}
}

\value{
A vector with the values of the generalized Mantel-Haenszel DIF statistics.
 }
 
\details{
 This command computes the generalized Mantel-Haenszel statistic (Somes, 1986) in the specific framework of differential item functioning. It forms the basic command
 of \code{\link{difGMH}} and is specifically designed for this call.

 The data are passed through the \code{data} argument, with one row per subject and one column per item. Missing values are allowed but must be coded as \code{NA}
 values. They are discarded from sum-score computation.

 The vector of group membership, specified with \code{member} argument, must hold only zeros and positive integers. The value zero corresponds to the reference group,
 and each positive integer value corresponds to one focal group. At least two different positive integers must be supplied.

 The matching criterion can be either the test score or any other continuous or discrete variable to be passed in the \code{genMantelHaenszel} function. This is specified by the \code{match} argument. By default, it takes the value \code{"score"} and the test score (i.e. raw score) is computed. The second option is to assign to \code{match} a vector of continuous or discrete numeric values, which acts as the matching criterion. Note that for consistency this vector should not belong to the \code{data} matrix.

 Option \code{anchor} sets the items which are considered as anchor items for computing generalized Mantel-Haenszel statistics. Items other than the anchor items and
 the tested item are discarded. \code{anchor} must hold integer values specifying the column numbers of the corresponding anchor items. It is primarily designed to
 perform item purification.
}

\references{
 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

 Penfield, R. D. (2001). Assessing differential item functioning among multiple groups: a comparison of three Mantel-Haenszel procedures. \emph{Applied Measurement in Education, 14}, 235-259. \doi{10.1207/S15324818AME1403_3}

 Somes, G. W. (1986). The generalized Mantel-Haenszel statistic. \emph{The American Statistician, 40}, 106-108. \doi{10.2307/2684866}
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
 \code{\link{difGMH}}
}

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)
 attach(verbal)

 # Creating four groups according to gender (0 or 1) and trait anger
 # score ("Low" or "High")
 # Reference group: women with low trait anger score (<=20)
 group <- rep(0, nrow(verbal))
 group[Anger>20 & Gender==0] <- 1
 group[Anger<=20 & Gender==1] <- 2
 group[Anger>20 & Gender==1] <- 3

 # Without continuity correction
 genMantelHaenszel(verbal[,1:24], group)

 # Removing item 6 from the set of anchor items
 genMantelHaenszel(verbal[,1:24], group, anchor = c(1:5, 7:24))
 }
 }




