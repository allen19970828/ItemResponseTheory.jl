\name{sibTest}
\alias{sibTest}

\title{SIBTEST DIF statistic}

\description{
 Calculates the SIBTEST statistics for DIF detection.
 }

\usage{
sibTest(data, member, anchor = 1:ncol(data), type = "udif")
 }

\arguments{
 \item{data}{numeric: the data matrix (one row per subject, one column per item).}
 \item{member}{numeric or factor: the vector of group membership. Can either take two distinct values (zero for the reference group and one for the focal group) or be a continuous vector. See \bold{Details}.}
 \item{anchor}{a vector of integer values specifying which items (all by default) are currently considered as anchor (DIF free) items. See \bold{Details}.}
 \item{type}{a character string specifying which DIF effects must be tested. Possible values are \code{"udif"} (default) and \code{"nudif"}. See \bold{Details}.}
}


\value{
 A list with six components:
 \item{Beta}{the values of the Beta SIBTEST statistics.}
 \item{SE}{the standard errors of \code{Beta} values.}
 \item{X2}{the values of X^2 statistics for SIBTEST method.}
 \item{df}{the degrees of freedom for each \code{X2} statistic.}
 \item{p.value}{the p-values of the SIBTEST statistics.}
\item{type}{the value of the \code{type} argument.}
 }


\details{
 This command computes the SIBTEST Beta coefficients and relatif DIF statistics, both for uniform (Shealy and Stout, 1993) and nonuniform (or crossing-SIBTEST; Chalmers, 2018) DIF effects. It forms the basic command of \code{difSIBTEST} function and is specifically designed for this call. This function provides a wrapper to the \code{\link[mirt]{SIBTEST}} function from the \bold{mirt} package (Chalmers, 2012) to fit within the \code{difR} framework (Magis et al., 2010). Therefore, if you are using this function for publication purposes please cite Chalmers (2018; 2012).

  The data are passed through the \code{data} argument, with one row per subject and one column per item.

 The vector of group membership, specified with \code{member} argument, must hold only zeros and ones, a value of zero corresponding to the reference group and a value of one to the focal group.

 Option \code{anchor} sets the items which are considered as anchor items for computing the test scores and related SIBTEST DIF statistics. \code{anchor} must hold integer values specifying the column numbers of the corresponding anchor items.
If all columns of \code{data} are specified as anchor items, then all items are tested for DIF with the all-other-items-as-anchor strategy. If a smaller set of items is defined as the anchor set, then only items outside the \code{anchor} set will be tested for DIF; items belonging to this anchor set are not tested and corresponding \code{NA} values are returned instead.
It is mainly designed to perform item purification.

 The output contains: the SIBTEST Beta statistics and related standard errors; the \code{X2} statistics that follow an asymptotic chi-square distribution; the degrees of freedom and the corresponding p-values. The default \code{type} value is also returned.}

\references{
Chalmers, R. P. (2012). mirt: A Multidimensional item response
  theory package for the R environment. \emph{Journal of Statistical Software, 48(6)}, 1-29. \doi{10.18637/jss.v048.i06}

Chalmers, R. P. (2018). Improving the Crossing-SIBTEST statistic for detecting non-uniform DIF. \emph{Psychometrika, 83}(2), 376--386. \doi{10.1007/s11336-017-9583-8}

 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

Shealy, R. and Stout, W. (1993). A model-based standardization approach that separates true bias/DIF from group ability differences and detect test bias/DTF as well as item bias/DIF. \emph{Psychometrika, 58}, 159-194. \doi{10.1007/BF02294572}
}

\author{
    David Magis \cr
    Data science consultant at IQVIA Belux \cr
    Brussels, Belgium \cr
 }


\seealso{
 \code{\link{difSIBTEST}}, \code{\link{dichoDif}}
}

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)

 # Testing uniform DIF with all items
 sibTest(verbal[,1:24], verbal[,26])

 # Testing nonuniform DIF with all items
 sibTest(verbal[,1:24], verbal[,26], type = "nudif")

 # Removing item 6 from the set of anchor items
 sibTest(verbal[,1:24], verbal[,26], anchor = c(1:5, 7:24))

 # Considering items 3 to 9 as the set of anchor items
 sibTest(verbal[,1:24], verbal[,26], anchor = 3:9)

 }
 }
