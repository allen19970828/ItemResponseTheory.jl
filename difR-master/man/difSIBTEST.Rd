\name{difSIBTEST}
\alias{difSIBTEST}
\alias{print.SIBTEST}
\alias{plot.SIBTEST}
\title{SIBTEST and Crossing-SIBTEST DIF method}
\usage{
difSIBTEST(
  Data,
  group,
  focal.name,
  type = "udif",
  anchor = NULL,
  alpha = 0.05,
  purify = FALSE,
  nrIter = 10,
  p.adjust.method = NULL,
  puriadjType = "simple",
  save.output = FALSE,
  output = c("out", "default")
)

\method{plot}{SIBTEST}(
  x,
  pch = 8,
  number = TRUE,
  col = "red",
  save.plot = FALSE,
  save.options = c("plot", "default", "pdf"),
  ...
)
}
\arguments{
\item{Data}{numeric: either the data matrix only, or the data matrix plus
the vector of group membership. See \bold{Details}.}

\item{group}{numeric or character: either the vector of group membership or
the column indicator (within \code{Data}) of group membership. See
\bold{Details}.}

\item{focal.name}{numeric or character indicating the level of \code{group}
which corresponds to the focal group.}

\item{type}{character: the type of DIF effect to test. Possible values are
\code{"udif"} (default) for uniform DIF using SIBTEST, or \code{"nudif"}
for nonuniform DIF using Crossing-SIBTEST (CSIBTEST).}

\item{anchor}{either \code{NULL} (default) or a vector of item names (or
identifiers) to specify the anchor items. See \bold{Details}.}

\item{alpha}{numeric: significance level (default is 0.05).}

\item{purify}{logical: should the method be used iteratively to purify the
set of anchor items? (default is \code{FALSE}).}

\item{nrIter}{numeric: the maximal number of iterations in the item
purification process (default is 10).}

\item{p.adjust.method}{either \code{NULL} (default) or the acronym of the
method for p-value adjustment for multiple comparisons. See \bold{Details}.}

\item{puriadjType}{character: type of combination of the item purification
and the method for p-value adjustment for multiple comparisons. Either
\code{"simple"} for the item purification followed by the selected
p-adjustment method (default) or \code{"combined"} for the p-adjustment
method applied in each iteration of item purification. For details, see
Hladká, Martinková, and Magis (2024). Argument is ignored when
\code{purify} is \code{FALSE} or \code{p.adjust.method} is \code{NULL}.}

\item{save.output}{logical: should the output be saved into a text file?
(default is \code{FALSE}).}

\item{output}{character: a vector of two components. The first component is
the name of the output file, the second component is either the file path
or \code{"default"} (default value). See \bold{Details}.}

\item{x}{the result from a \code{"SIBTEST"} class object.}

\item{pch, col}{type of usual \code{pch} and \code{col} graphical options.}

\item{number}{logical: should the item number identification be printed
(default is \code{TRUE}).}

\item{save.plot}{logical: should the plot be saved into a separate file?
(default is \code{FALSE}).}

\item{save.options}{character: a vector of three components. The first
component is the name of the output file, the second component is either
the file path or \code{"default"} (default value), and the third component
is the file extension, either \code{"pdf"} (default) or \code{"jpeg"}. See
\bold{Details}.}

\item{...}{other generic parameters for the \code{plot} or the \code{print}
functions.}
}
\value{
A list of class \code{"SIBTEST"} with the following arguments:
\describe{
  \item{Beta}{the values of the SIBTEST Beta values.}
  \item{SE}{the standard errors of the Beta values.}
  \item{X2}{the values of the SIBTEST or Crossing-SITBTEST chi-square statistics.}
  \item{df}{the degrees of freedom for \code{X2} statistics.}
  \item{p.value}{the p-values for the SIBTEST or Crossing-SIBTEST statistics.}
  \item{type}{the value of the \code{type} argument.}
  \item{alpha}{the value of \code{alpha} argument.}
  \item{DIFitems}{either the column indicators of the items which were detected as DIF items, or \code{"No DIF item detected"}.}
  \item{p.adjust.method}{the value of the \code{p.adjust.method} argument.}
  \item{adjusted.p}{either \code{NULL} or the vector of adjusted p-values for multiple comparisons.}
  \item{purification}{the value of \code{purify} option.}
  \item{nrPur}{the number of iterations in the item purification process. Returned only if \code{purify} is \code{TRUE}.}
  \item{difPur}{a binary matrix with one row per iteration in the item purification process and one column per item. Zeros and ones in the \emph{i}-th row refer to items which were classified respectively as non-DIF and DIF items at the (\emph{i}-1)-th step. The first row corresponds to the initial classification of the items. Returned only if \code{purify} is \code{TRUE}.}
  \item{convergence}{logical indicating whether the iterative item purification process stopped before the maximal number \code{nrIter} of allowed iterations. Returned only if \code{purify} is \code{TRUE}.}
  \item{puriadjType}{the value of \code{puriadjType} option. Returned only when \code{purify} is \code{TRUE}.}
  \item{names}{the names of the items or \code{NULL} if the items have no name.}
  \item{anchor.names}{the value of the \code{anchor} argument.}
  \item{save.output}{the value of the \code{save.output} argument.}
  \item{output}{the value of the \code{output} argument.}
}
}
\description{
Performs DIF detection using SIBTEST (Shealy & Stout, 1993) or the
modified Crossing-SIBTEST method (Chalmers, 2018).
}
\details{
The SIBTEST method (Shealy & Stout, 1993) allows for detecting uniform
differential item functioning without requiring an item response model
approach. Its modified version, the Crossing-SIBTEST (Chalmers, 2018; Li
& Stout, 1996), focuses on nonuniform DIF instead. This function provides
a wrapper to the \code{\link[mirt]{SIBTEST}} function from the \bold{mirt}
package (Chalmers, 2012) to fit within the \code{difR} framework (Magis et
al., 2010). Therefore, if you are using this function for publication
purposes please cite Chalmers (2018; 2012) and Magis et al. (2010).

The \code{Data} is a matrix whose rows correspond to the subjects and
columns to the items. In addition, \code{Data} can hold the vector of group
membership. If so, \code{group} indicates the column of \code{Data} which
corresponds to the group membership, either by specifying its name or by
giving the column number. Otherwise, \code{group} must be a vector of same
length as \code{nrow(Data)}.

The vector of group membership must hold only two different values, either
as numeric or character. The focal group is defined by the value of the
argument \code{focal.name}.

The type of DIF effect, uniform through SIBTEST or nonuniform through
Crossing-SIBTEST, is determined by the \code{type} argument. By default it
is \code{"udif"} for uniform DIF, and may take the value \code{"nudif"} for
nonuniform DIF.

The threshold (or cut-score) for classifying items as DIF is computed as
the quantile of the chi-square distribution with lower-tail probability of
one minus \code{alpha} and with one degree of freedom. Note that the
degrees of freedom are also returned by the \code{df} argument.

Item purification can be performed by setting \code{purify} to \code{TRUE}.
Purification works as follows: if at least one item was detected as
functioning differently at some step of the process, then the data set of
the next step consists in all items that are currently anchor (DIF free)
items, plus the tested item (if necessary). The process stops when either
two successive applications of the method yield the same classifications of
the items (Clauser & Mazor, 1998), or when \code{nrIter} iterations are
run without obtaining two successive identical classifications. In the
latter case a warning message is printed.

Adjustment for multiple comparisons is possible with the argument
\code{p.adjust.method}. The latter must be an acronym of one of the
available adjustment methods of the \code{\link{p.adjust}} function.
According to Kim and Oshima (2013), Holm and Benjamini-Hochberg adjustments
(set respectively by \code{"Holm"} and \code{"BH"}) perform best for DIF
purposes. See \code{\link{p.adjust}} function for further details. Note
that item purification is performed on original statistics and p-values; in
case of adjustment for multiple comparisons this is performed \emph{after}
item purification.

A pre-specified set of anchor items can be provided through the
\code{anchor} argument. It must be a vector of either item names (which
must match exactly the column names of \code{Data} argument) or integer
values (specifying the column numbers for item identification). In case
anchor items are provided, they are used to compute the test score
(matching criterion), including also the tested item. None of the anchor
items are tested for DIF: the output separates anchor items and tested
items and DIF results are returned only for the latter. Note also that item
purification is not activated when anchor items are provided (even if
\code{purify} is set to \code{TRUE}). By default it is \code{NULL} so that
no anchor item is specified.

The output of the \code{difSIBTEST}, as displayed by the
\code{print.SIBTEST} function, can be stored in a text file provided that
\code{save.output} is set to \code{TRUE} (the default value \code{FALSE}
does not execute the storage). In this case, the name of the text file must
be given as a character string into the first component of the
\code{output} argument (default name is \code{"out"}), and the path for
saving the text file can be given through the second component of
\code{output}. The default value is \code{"default"}, meaning that the file
will be saved in the current working directory. Any other path can be
specified as a character string: see the \bold{Examples} section for an
illustration.

The \code{plot.SIBTEST} function displays the DIF statistics in a plot,
with each item on the X axis. The type of point and the color are fixed by
the usual \code{pch} and \code{col} arguments. Option \code{number} permits
to display the item numbers instead. Also, the plot can be stored in a
figure file, either in PDF or JPEG format. Fixing \code{save.plot} to
\code{TRUE} allows this process. The figure is defined through the
components of \code{save.options}. The first two components perform
similarly as those of the \code{output} argument. The third component is
the figure format, with allowed values \code{"pdf"} (default) for PDF file
and \code{"jpeg"} for JPEG file. Note that no plot is returned for exact
inference.
}
\examples{

\dontrun{

 # Loading of the verbal data
 data(verbal)

 # Excluding the "Anger" variable
 verbal <- verbal[colnames(verbal) != "Anger"]

 # Three equivalent settings of the data matrix and the group membership
 r <- difSIBTEST(verbal, group = 25, focal.name = 1)
 difSIBTEST(verbal, group = "Gender", focal.name = 1)
 difSIBTEST(verbal[, 1:24], group = verbal[, 25], focal.name = 1)

 # Test for nonuniform DIF
 difSIBTEST(verbal, group = 25, focal.name = 1, type = "nudif")

 # Multiple comparisons adjustment using Benjamini-Hochberg method
 difSIBTEST(verbal, group = 25, focal.name = 1, p.adjust.method = "BH")

 # With item purification
 difSIBTEST(verbal, group = 25, focal.name = 1, purify = TRUE)
 r2 <- difSIBTEST(verbal, group = 25, focal.name = 1, purify = TRUE, nrIter = 5)

 # With combination of item purification and multiple comparisons adjustment
 difSIBTEST(verbal, group = 25, focal.name = 1, purify = TRUE,
            p.adjust.method = "BH", puriadjType = "simple")
 difSIBTEST(verbal, group = 25, focal.name = 1, purify = TRUE,
            p.adjust.method = "BH", puriadjType = "combined")

 # With items 1 to 5 set as anchor items
 difSIBTEST(verbal, group = "Gender", focal.name = 1, anchor = 1:5)
 difSIBTEST(verbal, group = "Gender", focal.name = 1, anchor = 1:5, purify = TRUE)

 # Saving the output into the "SIBresults.txt" file (and default path)
 r <- difSIBTEST(verbal, group = 25, focal.name = 1, save.output = TRUE,
                 output = c("SIBresults","default"))

 # Graphical devices
 plot(r)
 plot(r2)

 # Plotting results and saving it in a PDF figure
 plot(r, save.plot = TRUE, save.options = c("plot", "default", "pdf"))

 # Changing the path, JPEG figure
 path <- "c:/Program Files/"
 plot(r, save.plot = TRUE, save.options = c("plot", path, "jpeg"))
}
}
\references{
Chalmers, R. P. (2012). mirt: A Multidimensional item response theory
package for the R environment. \emph{Journal of Statistical Software,
48(6)}, 1--29, \doi{10.18637/jss.v048.i06}

Chalmers, R. P. (2018). Improving the Crossing-SIBTEST statistic for
detecting non-uniform DIF. \emph{Psychometrika, 83}(2), 376--386,
\doi{10.1007/s11336-017-9583-8}

Hladká, A., Martinková, P., and Magis, D. (2023). Combining item purification
and multiple comparison adjustment methods in detection of differential item
functioning. \emph{Multivariate Behavioral Research, 59}(1), 46--61,
\doi{10.1080/00273171.2023.2205393}

Kim, J., and Oshima, T. C. (2013). Effect of multiple testing adjustment in
differential item functioning detection. \emph{Educational and
Psychological Measurement, 73}, 458--470, \doi{10.1177/0013164412467033}

Li, H.-H., and Stout, W. (1996). A new procedure for detection of crossing
DIF. \emph{Psychometrika, 61}, 647--677, \doi{10.1007/BF02294041}

Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general
framework and an R package for the detection of dichotomous differential
item functioning. \emph{Behavior Research Methods, 42}, 847--862,
\doi{10.3758/BRM.42.3.847}

Shealy, R. and Stout, W. (1993). A model-based standardization approach
that separates true bias/DIF from group ability differences and detect test
bias/DTF as well as item bias/DIF. \emph{Psychometrika, 58}, 159--194,
\doi{10.1007/BF02294572}
}
\seealso{
\code{\link{sibTest}}, \code{\link{dichoDif}}, \code{\link{p.adjust}}
}
\author{
David Magis \cr
Data science consultant at IQVIA Belux \cr
Brussels, Belgium\cr
Adela Hladka (nee Drabinova) \cr
Institute of Computer Science of the Czech Academy of Sciences \cr 
\email{hladka@cs.cas.cz} \cr
}
