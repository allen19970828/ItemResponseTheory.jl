\name{difTID}
\alias{difTID}
\alias{print.TID}
\alias{plot.TID}

\title{Transformed Item Difficulties (TID) DIF method}

\description{
 Performs DIF detection using Transformed Item Difficulties (TID) method. 
 }

\usage{
difTID(Data, group, focal.name, thrTID = 1.5, purify = FALSE, purType = "IPP1", 
  	nrIter = 10, alpha = 0.05, extreme = "constraint", 
  	const.range = c(0.001, 0.999), nrAdd = 1, save.output = FALSE, 
  	output = c("out", "default"))  
\method{print}{TID}(x, only.final = TRUE, ...)
\method{plot}{TID}(x, plot = "dist",pch = 2, pch.mult = 17, axis.draw = TRUE, 
  	thr.draw = FALSE, dif.draw = c(1, 3), print.corr = FALSE, xlim = NULL, 
  	ylim = NULL, xlab = NULL, ylab = NULL, main = NULL, col = "red", 
  	number = TRUE, save.plot = FALSE, save.options = c("plot", 
  	"default", "pdf"), ...)
 }

\arguments{
 \item{Data}{numeric: either the data matrix only, or the data matrix plus the vector of group membership. See \bold{Details}.}
 \item{group}{numeric or character: either the vector of group membership or the column indicator (within \code{Data}) of group membership. See \bold{Details}.}
 \item{focal.name}{numeric or character indicating the level of \code{group} which corresponds to the focal group.}
 \item{thrTID}{either the threshold for detecting DIF items (default is 1.5) or \code{"norm"}.}
 \item{purify}{logical: should the method be used iteratively to purify the set of anchor items? (default is FALSE).}
 \item{purType}{character: the type of purification process to be run. Possible values are \code{"IPP1"} (default), \code{"IPP2"} and \code{"IPP3"}. Ignored if \code{purify} is \code{FALSE}. See \bold{Details}.}
 \item{nrIter}{numeric: the maximal number of iterations in the item purification process (default is 10).}
 \item{alpha}{numeric: the significance level for calculating the detection threshold (default is 0.05). Ignored if \code{thrTID} is numeric.}
 \item{extreme}{character: the method used to modify the extreme proportions. Possible values are \code{"constraint"} (default) or \code{"add"}. See \bold{Details}.}
 \item{const.range}{numeric: a vector of two constraining proportions. Default values are 0.001 and 0.999. Ignored if \code{extreme} is \code{"add"}.}
 \item{nrAdd}{integer: the number of successes and the number of failures to add to the data in order to adjust the proportions. Default value is 1. Ignored if \code{extreme} is \code{"constraint"}.}
 \item{save.output}{logical: should the output be saved into a text file? (Default is \code{FALSE}).}
 \item{output}{character: a vector of two components. The first component is the name of the output file, the second component is either the file path or \code{"default"} (default value). See \bold{Details}.}
 \item{x}{the result from a \code{TID} class object.}
 \item{only.final}{logical: should only the first and last steps of the purification process be printed? (default is \code{TRUE}. If \code{FALSE} all perpendicular distances, parameters of the major axis, and detection thresholds are printed additionally. Ignored if \code{purify} is \code{FALSE}.}
 \item{plot}{character: either \code{"dist"} (default) to display the perpendicular distances, or \code{"delta"} for the Delta plot. See \bold{Details}.}
 \item{pch}{integer: the usual point character type for point display. Default value is 2, that is, Delta points are
drawn as empty triangles.}
 \item{pch.mult}{integer: the type of point to be used for superposing onto Delta points that correspond to several items. Default value is 17, that is, full black traingles are drawn onto existing Delta plots wherein multiple items are located.}
 \item{axis.draw}{logical: should the major axis be drawn? (default is \code{TRUE}). If so, it will be drawn as a solid
line.}
 \item{thr.draw}{logical: should the upper and lower bounds for DIF detection be drawn? (default is \code{FALSE}). If
\code{TRUE}, they will be drawn as dashed lines.}
 \item{dif.draw}{numeric: a vector of two integer values to specify how the DIF items should be displayed. The first component of \code{dif.draw} is the type of point (i.e. the usual \code{pch} argument) and the second component determines the point size (i.e. the usual \code{cex} argument). Default values are 1 and 3, meaning that empty circles of three times the usual size are drawn around the Delta points of items
flagged as DIF.}
 \item{print.corr}{logical: should the sample correlation of Delta scores be printed? (default is \code{FALSE}). If
\code{TRUE}, it is printed in upper-left corner of the plot.}
 \item{xlim, ylim, xlab, ylab, main}{either the usual plot arguments \code{xlim}, \code{ylim}, \code{xlab}, \code{ylab} and \code{main}, or \code{NULL} (default value for all arguments). If \code{NULL}, the X and Y axis limits are computed from the range of Delta scores, the X and Y axis labels are \code{"Reference group"} and \code{"Focal group"} respectively, and no main title is produced.}
\item{col}{character: the color type for the items. Used only when \code{plot} is \code{"dist"}.}
 \item{number}{logical: should the item number identification be printed (default is \code{TRUE}).}
 \item{save.plot}{logical: should the plot be saved into a separate file? (default is \code{FALSE}).}
 \item{save.options}{character: a vector of three components. The first component is the name of the output file, the second component is either the file path or \code{"default"} (default value), and the third component is the file extension, either \code{"pdf"} (default) or \code{"jpeg"}. See \bold{Details}.}
 \item{...}{other generic parameters for the \code{plot} or the \code{print} functions.}
 }

\value{
A list of class "TID" with the following arguments:
  \item{Props}{the matrix of proportions of correct responses, or \code{NA} if \code{type} is \code{"delta"}.}
  \item{adjProps}{the restricted proportions, in the same format as the output \code{Props} matrix, or \code{NA} if \code{type} is \code{"delta"}.}
  \item{Deltas}{the matrix of Delta scores.}
  \item{Dist}{a matrix with perpendicular distances, one row per item and one column per run of the Delta plot. If \code{purify} is \code{FALSE}, only a single column is returned.}
  \item{axis.par}{a matrix with two columns, holding respectively the intercepts and the slope parameters of the major axis. Each row refers to one step of the purification process. If \code{purify} is \code{FALSE}, only a single row is returned.}
  \item{nrIter}{the number of iterations invloved in the purification process. Returned only if \code{purify} is \code{TRUE}.}
  \item{maxIter}{the value of the \code{maxIter} argument. Returned only if \code{purify} is \code{TRUE}.}
  \item{convergence}{a logical value indicating whether convergence was reached in the purification process. Returned only if \code{purify} is \code{TRUE}.}
  \item{difPur}{a matrix with one column per item and one row per iteration in the purification process, holding zeros and ones to indicate which items were flagged as DIF or not at each step of the process. Returned only if \code{purify} is \code{TRUE}.}
  \item{thr}{a vector of successive threshold values used during the purification process. If \code{purify} is \code{FALSE}, a single value is returned.}
  \item{rule}{a character value indicating whether the threshold was \code{"fixed"} by the user (i.e. by setting \code{thr} to a numeric value) or whether it was computed by normal approximation (i.e. by setting \code{thr} to \code{"norm"}).}
  \item{purType}{the value of the \code{purType} argument. Returned only if \code{purify} is \code{TRUE}.}
  \item{DIFitems}{either \code{"No DIF item detected"} or an integer vector with the items that were flagged as DIF.}
  \item{adjust.extreme}{the value of the \code{extreme} argument.}
  \item{const.range}{the value of the \code{const.range} argument.}
  \item{nrAdd}{the value of the \code{nrAdd} argument.}
  \item{purify}{the value of the \code{purify} argument.}
  \item{alpha}{the value of the \code{alpha} argument.}
  \item{save.output}{the value of the \code{save.output} argument.}
  \item{output}{the value of the \code{output} argument.}
\item{names}{either the names of the items (defined by the column names of the \code{Data} matrix) or the series of integers from one to the number of items.}
\item{number}{a boolean value, being \code{TRUE} if the item names are simply their number in the \code{Data} matrix, or \code{FALSE} if real item names are available in the \code{names} element.}
 }
 

\details{
 The Transformed Item Difficulties (TID) method, also known as Angoff's Delta method (Angoff, 1982; Angoff and Ford, 1973) allows for detecting uniform differential item functioning without requiring an item response model approach. The presnt implementation relies on the \code{\link[deltaPlotR]{deltaPlot}} and \code{\link[deltaPlotR]{diagPlot}} functions from package\bold{deltaPlotR} (Magis and Facon, 2014).
 
 The \code{Data} is a matrix whose rows correspond to the subjects and columns to the items. In addition, \code{Data} can hold the vector of group membership. If so, \code{group} indicates the column of \code{Data} which corresponds to the group membership, either by specifying its name or by giving the column number. Otherwise, \code{group} must be a vector of same length as \code{nrow(Data)}.
 
 Missing values are allowed for item responses (not for group membership) but must be coded as \code{NA} values. They are discarded from the computation of
 proportions of success.

 The vector of group membership must hold only two different values, either as numeric or character. The focal group is defined by the value of the argument \code{focal.name}. 

The threshold for flaging items as DIF can be of two types and is specified by the \code{thr} argument.
\enumerate{
\item It can be fixed to some arbitrary positive value by the user, for instance 1.5 (Angoff and Ford, 1973). In this 
case, \code{thr} takes the required numeric threshold value.
\item Alternatively, it can be derived from the bivariate normal approximation of the Delta points (Magis and Facon, 2012). In this case, \code{thr} must be given the character value \code{"norm"} (which is the default value).
This threshold equals
\deqn{\Phi^{-1}(1-\alpha/2) \; \sqrt{\frac{b^2\,{s_0}^2-2\,b\,s_{01}+{s_1}^2}{b^2+1}}}
where \eqn{\Phi} is the density of the standard normal distribution, \eqn{\alpha} is the significance level (set by the argument \code{alpha} with default value 0.05), \eqn{b} is the slope parameter of the major axis, \eqn{s_0} and \eqn{s_1}
are the sample standard deviations of the Delta scores in the reference group and the focal group, respecively, and
\eqn{s_{01}} is the sample covariance of the Delta scores (see Magis and Facon, 2012, for further details).
}
 
Item purification can be performed by setting the argument \code{purify} to \code{TRUE} (by default it is \code{FALSE} so 
no purification is performed). The item purification process (IPP) starts when at least one item was flagged as DIF after
the first run of the Delta plot, and proceeds as follows.
\enumerate{
\item The intercept and slope parameters of the major axis are re-calculated by removing all DIF that are currently 
flagged as DIF. This yields updated values \eqn{a^*}, \eqn{b^*}, \eqn{s_0^*}, \eqn{s_1^*} and \eqn{s_{01}^*} of the 
intercept and slope parameters, sample stanbdard deviations and sample covariance of the Delta scores.
\item Perpendicular distances (for all items) are updated with respect to the updated major axis.
\item Detection threshold is also updated. Three possible updates are possible: see below.
\item All items are now tested for the presence of DIF, given the updated perpendicular distances and major axis.
\item If the set of items flagged as DIF is the same as the one from the previous loop, stop the process. Otherwise go
back to step 1.
}

Unlike traditional DIF methods, the detection threshold may also be updated since it depends on the sample estimates (when 
the normal approximation is considered). Three approaches are currently implemented and are specified by the \code{purType} argument.
\enumerate{
\item Method 1 (\code{purType=="IPP1"}): the same threshold is used throughout the purification process, it is not
iteratively updated. The threshold is the one obtained after the first run of the Delta plot.
\item Method 2 (\code{purType=="IPP2"}): only the slope parameter is updated in the threshold formula. By this way, one keeps the full data structure (i.e. neither the sample variances nor the sample covariance of the Delta scores are 
modified) but only the slope parameter is adjusted to lessen the impact of DIF items.
\item Method 3 (\code{purType=="IPP3"}): all adjusted parameters are plugged in the threshold formula. This approach
completely discards the effect of items flagged as DIF from the computation of the threshold.
}
See Magis and Facon (2013) for further details. Note that purification can also be performed with fixed threshold (i.e.
specified by the user), but then only IPP1 process is performed.

In order to avoid possible infinite loops in the purification process, a maximal number of iterations must be specified
through the argument \code{maxIter}. The default maximal number of iterations is 10. 

The output contains all input information, the Delta scores and perpendicular distances, the parameter of the major axis
and the items flagged as DIF (if none, a character sentence is returned). In addition, the detection threshold and the
type of threshold (fixed or normal approximation) is provided. 

If item purification was run, several additional elements are returned: the number of iterations, a logical indicator
whether the convergence was reached (or not, meaning that the process stopped because of reaching the maximal number of 
allowed iterations), a matrix with indicators of which items were flagged as DIF at each iteration, and the type of item
purification process. Moreover, perpendicular distances are returned in a matrix format (one column per iteration), as
well as successive major axis parameters (one row per iteration) and successive thresholds (as a vector).

The output is managed and printed in a more user-friendly way. When item purification is performed, only the first and
last steps are displayed. Specifying the argument \code{only.final} to \code{FALSE} prints in addition all intermediate steps of the process (successive perpendicular distances, parameters of the major axis, and detection thresholds).

 The output of the \code{difTID}, as displayed by the \code{print.TID} function, can be stored in a text file provided that \code{save.output} is set to \code{TRUE} 
 (the default value \code{FALSE} does not execute the storage). In this case, the name of the text file must be given as a character string into the first component
 of the \code{output} argument (default name is \code{"out"}), and the path for saving the text file can be given through the second component of \code{output}. The default value is \code{"default"}, meaning that the file will be saved in the current working directory. Any other path can be specified as a character string: see the \bold{Examples} section for an illustration.

 Two types of plots are available through the \code{plot.TID} function. If the argument \code{plot} is set to \code{"dist"} (the default value), then the perpendicular distances are represented on the Y axis of a scatter plot, with each item on the X axis. If \code{plot} is set to \code{"delta"}, the Delta plot is returned. In the latter, all particular options can be found from the \code{\link[deltaPlotR]{diagPlot}} function.
Also, the plot can be stored in a figure file, either in PDF or JPEG format. Fixing \code{save.plot} to \code{TRUE} allows this process. The figure is defined through the components of \code{save.options}. The first two components perform similarly as those of the \code{output} argument.
 The third component is the figure format, with allowed values \code{"pdf"} (default) for PDF file and \code{"jpeg"} for JPEG file.
 }

\references{
 Angoff, W. H. (1982). Use of difficulty and discrimination indices for detecting item bias. In R. A. Berck (Ed.), \emph{Handbook of methods for detecting item bias} (pp. 96-116). Baltimore, MD: Johns Hopkins University Press.

 Angoff, W. H., and Ford, S. F. (1973). Item-race interaction on a test of scholastic aptitude. \emph{Journal of Educational Measurement, 2}, 95-106. \doi{10.1111/j.1745-3984.1973.tb00787.x}

Magis, D., and Facon, B. (2012). Angoff's Delta method revisited: improving the DIF detection under small samples.
\emph{British Journal of Mathematical and Statistical Psychology, 65}, 302-321. \doi{10.1111/j.2044-8317.2011.02025.x}

Magis, D., and Facon, B. (2013). Item purification does not always improve DIF detection: a counter-example with Angoff's Delta plot. \emph{Educational and Psychological Measurement, 73}, 293-311. \doi{10.1177/0013164412451903}

Magis, D. and Facon, B. (2014). \emph{deltaPlotR}: An R Package for Differential Item Functioning Analysis with Angoff's Delta Plot. \emph{Journal of Statistical Software, Code Snippets, 59(1)}, 1-19. \doi{10.18637/jss.v059.c01}
 }
 

\author{
    David Magis \cr
    Data science consultant at IQVIA Belux \cr
    Brussels, Belgium \cr
 }


\seealso{
 \code{\link[deltaPlotR]{deltaPlot}}, \code{\link[deltaPlotR]{diagPlot}}, \code{\link{dichoDif}}
 }

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)

 # Excluding the "Anger" variable
 verbal <- verbal[colnames(verbal) != "Anger"]

 # Three equivalent settings of the data matrix and the group membership
 r <- difTID(verbal, group = 25, focal.name = 1)
 difTID(verbal, group = "Gender", focal.name = 1)
 difTID(verbal[,1:24], group = verbal[,25], focal.name = 1)

 # With item purification and threshold 1
 r2 <- difTID(verbal, group = "Gender", focal.name = 1, purify = TRUE, thrTID = 1)

 # Saving the output into the "TIDresults.txt" file (and default path)
 difTID(verbal, group = 25, focal.name = 1, save.output = TRUE, 
   output = c("TIDresults", "default"))

 # Graphical devices
 plot(r2)
 plot(r2, plot = "delta")

 # Plotting results and saving it in a PDF figure
 plot(r2, save.plot = TRUE, save.options = c("plot", "default", "pdf"))

 # Changing the path, JPEG figure
 path <- "c:/Program Files/"
 plot(r2, save.plot = TRUE, save.options = c("plot", path, "jpeg"))
}
 }



