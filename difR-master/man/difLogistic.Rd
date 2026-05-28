\name{difLogistic}
\alias{difLogistic}
\alias{print.Logistic}
\alias{plot.Logistic}
\title{Logistic regression DIF method}
\usage{
difLogistic(
  Data,
  group,
  focal.name,
  anchor = NULL,
  member.type = "group",
  match = "score",
  type = "both",
  criterion = "LRT",
  alpha = 0.05,
  all.cov = FALSE,
  purify = FALSE,
  nrIter = 10,
  p.adjust.method = NULL,
  puriadjType = "simple",
  save.output = FALSE,
  output = c("out", "default")
)

\method{plot}{Logistic}(
  x,
  plot = "lrStat",
  item = 1,
  itemFit = "best",
  pch = 8,
  number = TRUE,
  col = "red",
  colIC = rep("black", 2),
  ltyIC = c(1, 2),
  save.plot = FALSE,
  save.options = c("plot", "default", "pdf"),
  group.names = NULL,
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
which corresponds to the focal group. Ignored if \code{member.type} is not
\code{"group"}.}

\item{anchor}{either \code{NULL} (default) or a vector of item names (or
identifiers) to specify the anchor items. Ignored if \code{match} is not
\code{"score"}. See \bold{Details}.}

\item{member.type}{character: either \code{"group"} (default) to specify
that group membership is made of two groups, or \code{"cont"} to indicate
that group membership is based on a continuous criterion. See \bold{Details}.}

\item{match}{specifies the type of matching criterion. Can be either
\code{"score"} (default) to compute the test score, or any continuous or
discrete variable with the same length as the number of rows of
\code{Data}. See \bold{Details}.}

\item{type}{a character string specifying which DIF effects must be tested.
Possible values are \code{"both"} (default), \code{"udif"} and
\code{"nudif"}. See \bold{Details}.}

\item{criterion}{a character string specifying which DIF statistic is
computed. Possible values are \code{"LRT"} (default) or \code{"Wald"}. See
\bold{Details}.}

\item{alpha}{numeric: significance level (default is 0.05).}

\item{all.cov}{logical: should \emph{all} covariance matrices of model
parameter estimates be returned (as lists) for both nested models and all
items? (default is \code{FALSE}).}

\item{purify}{logical: should the method be used iteratively to purify the
set of anchor items? (default is \code{FALSE}). Ignored if \code{match} is not
\code{"score"}.}

\item{nrIter}{numeric: the maximal number of iterations in the item
purification process. (default is 10).}

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

\item{x}{the result from a \code{"Logistik"} class object.}

\item{plot}{character: the type of plot, either \code{"lrStat"} (default)
or \code{"itemCurve"}. See \bold{Details}.}

\item{item}{numeric or character: either the number or the name of the item
for which logistic curves are plotted. Used only when \code{plot = "itemCurve"}.}

\item{itemFit}{character: the model to be selected for drawing the item
curves. Possible values are \code{"best"} (default) for drawing from the
best of the two models, and \code{"null"} for using fitted parameters of
the null model \eqn{M_0}. Not used if \code{"plot"} is \code{"lrStat"}. See
\bold{Details}.}

\item{pch, col}{type of usual \code{pch} and \code{col} graphical options.}

\item{number}{logical: should the item number identification be printed
(default is \code{TRUE}).}

\item{colIC, ltyIC}{vectors of two elements of the usual \code{col} and
\code{lty} arguments for logistic curves. Used only when
\code{plot = "itemCurve"}.}

\item{save.plot}{logical: should the plot be saved into a separate file?
(default is \code{FALSE}).}

\item{save.options}{character: a vector of three components. The first
component is the name of the output file, the second component is either
the file path or \code{"default"} (default value), and the third component
is the file extension, either \code{"pdf"} (default) or \code{"jpeg"}. See
\bold{Details}.}

\item{group.names}{either \code{NULL} (default) or a vector of two
character strings giving the names of the reference group and the focal
group (in this order) for display in the legend. Ignored if \code{plot} is
\code{"lrStat"}.}

\item{...}{other generic parameters for the \code{plot} or the \code{print}
functions.}
}
\value{
A list of class \code{"Logistic"} with the following arguments:
\describe{
  \item{Logistik}{the values of the logistic regression statistics.}
  \item{p.value}{the vector of p-values for the logistic regression statistics.}
  \item{logitPar}{a matrix with one row per item and four columns, holding the fitted parameters of the best model (among the two tested models) for each item.}
  \item{logitSe}{a matrix with one row per item and four columns, holding the standard errors of the fitted parameters of the best model (among the two tested models) for each item.}
  \item{parM0}{the matrix of fitted parameters of the null model \eqn{M_0}, as returned by the \code{\link{Logistik}} command.}
  \item{seM0}{the matrix of standard error of fitted parameters of the null model \eqn{M_0}, as returned by the \code{\link{Logistik}} command.}
  \item{cov.M0}{either \code{NULL} (if \code{all.cov} argument is \code{FALSE}) or a list of covariance matrices of parameter estimates of the "full" model (\eqn{M_0}) for each item (if \code{all.cov} argument is \code{TRUE}).}
  \item{cov.M1}{either \code{NULL} (if \code{all.cov} argument is \code{FALSE}) or a list of covariance matrices of parameter estimates of the "reduced" model (\eqn{M_1}) for each item (if \code{all.cov} argument is \code{TRUE}).}
  \item{deltaR2}{the differences in Nagelkerke's \eqn{R^2} coefficients. See \bold{Details}.}
  \item{alpha}{the value of \code{alpha} argument.}
  \item{thr}{the threshold (cut-score) for DIF detection.}
  \item{DIFitems}{either the column indicators for the items which were detected as DIF items, or \code{"No DIF item detected"}.}
  \item{member.type}{the value of the \code{member.type} argument.}
  \item{match}{a character string, either \code{"score"} or \code{"matching variable"} depending on the \code{match} argument.}
  \item{type}{the value of \code{type} argument.}
  \item{p.adjust.method}{the value of the \code{p.adjust.method} argument.}
  \item{adjusted.p}{either \code{NULL} or the vector of adjusted p-values for multiple comparisons.}
  \item{purification}{the value of \code{purify} option.}
  \item{nrPur}{the number of iterations in the item purification process. Returned only if \code{purify} is \code{TRUE}.}
  \item{difPur}{a binary matrix with one row per iteration in the item purification process and one column per item. Zeros and ones in the \emph{i}-th row refer to items which were classified respectively as non-DIF and DIF items at the (\emph{i}-1)-th step. The first row corresponds to the initial classification of the items. Returned only if \code{purify} is \code{TRUE}.}
  \item{convergence}{logical indicating whether the iterative item purification process stopped before the maximal number of \code{nrItem} allowed iterations. Returned only if \code{purify} is \code{TRUE}.}
  \item{puriadjType}{the value of \code{puriadjType} option. Returned only when \code{purify} is \code{TRUE}.}
  \item{names}{the names of the items.}
  \item{anchor.names}{the value of the \code{anchor} argument.}
  \item{criterion}{the value of the \code{criterion} argument.}
  \item{save.output}{the value of the \code{save.output} argument.}
  \item{output}{the value of the \code{output} argument.}
}
}
\description{
Performs DIF detection using logistic regression method.
}
\details{
The logistic regression method (Swaminathan & Rogers, 1990) allows for
detecting both uniform and non-uniform differential item functioning
without requiring an item response model approach. It consists in fitting a
logistic model with the matching criterion, the group membership and an
interaction between both as covariates. The statistical significance of the
parameters related to group membership and the group-score interaction is
then evaluated by means of either the likelihood-ratio test or the Wald
test. The argument \code{type} permits to test either both uniform and
nonuniform effects simultaneously (\code{type = "both"}), only uniform DIF
effect (\code{type = "udif"}) or only nonuniform DIF effect
(\code{type = "nudif"}). The argument \code{criterion} permits to select
either the likelihood ratio test (\code{criterion = "LRT"}) or the Wald test
(\code{criterion = "Wald"}). See \code{\link{Logistik}} for further details.

The group membership can be either a vector of two distinct values, one for
the reference group and one for the focal group, or a continuous or
discrete variable that acts as the "group" membership variable. In the
former case, the \code{member.type} argument is set to \code{"group"} and
the \code{focal.name} defines which value in the \code{group} variable
stands for the focal group. In the latter case, \code{member.type} is set
to \code{"cont"}, \code{focal.name} is ignored and each value of the
\code{group} represents one "group" of data (that is, the DIF effects are
investigated among participants relying on different values of some
discrete or continuous trait). See \code{\link{Logistik}} for further
details.

The matching criterion can be either the test score or any other continuous
or discrete variable to be passed in the \code{\link{Logistik}} function.
This is specified by the \code{match} argument. By default, it takes the
value \code{"score"} and the test score (i.e. raw score) is computed. The
second option is to assign to \code{match} a vector of continuous or
discrete numeric values, which acts as the matching criterion. Note that
for consistency this vector should not belong to the \code{Data} matrix.

The \code{Data} is a matrix whose rows correspond to the subjects and
columns to the items. In addition, \code{Data} can hold the vector of group
membership. If so, \code{group} indicates the column of \code{Data} which
corresponds to the group membership, either by specifying its name or by
giving the column number. Otherwise, \code{group} must be a vector of same
length as \code{nrow(Data)}.

Missing values are allowed for item responses (not for group membership)
but must be coded as \code{NA} values. They are discarded from the fitting
of the logistic models (see \code{\link{glm}} for further details).

The threshold (or cut-score) for classifying items as DIF is computed as
the quantile of the chi-squared distribution with lower-tail probability of
one minus \code{alpha} and with one (if \code{type = "udif"} or
\code{type = "nudif"}) or two (if \code{type = "both"}) degrees of freedom.

Item purification can be performed by setting \code{purify} to \code{TRUE}.
Purification works as follows: if at least one item is detected as
functioning differently at the first step of the process, then the data set
of the next step consists in all items that are currently anchor (DIF free)
items, plus the tested item (if necessary). The process stops when either
two successive applications of the method yield the same classifications of
the items (Clauser & Mazor, 1998), or when \code{nrIter} iterations are
run without obtaining two successive identical classifications. In the
latter case a warning message is printed. Note that purification is
possible only if the test score is considered as the matching criterion.
Thus, \code{purify} is ignored when \code{match} is not \code{"score"}.

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
items and DIF results are returned only for the latter. By default it is
\code{NULL} so that no anchor item is specified. Note also that item
purification is not activated when anchor items are provided (even if
\code{purify} is set to \code{TRUE}). Moreover, if the \code{match}
argument is not set to \code{"score"}, anchor items will not be taken into
account even if \code{anchor} is not \code{NULL}.

The measures of effect size are provided by the difference \eqn{\Delta R^2}
between the \eqn{R^2} coefficients of the two nested models (Nagelkerke,
1991; Gomez-Benito, Dolores Hidalgo & Padilla, 2009). The effect sizes
are classified as "negligible", "moderate" or "large". Two scales are
available, one from Zumbo and Thomas (1997) and one from Jodoin and Gierl
(2001). The output displays the \eqn{\Delta R^2} measures, together with
the two classifications.

The output of the \code{difLogistic()} function, as displayed by the
\code{print.Logistic} function, can be stored in a text file provided that
\code{save.output} is set to \code{TRUE} (the default value \code{FALSE}
does not execute the storage). In this case, the name of the text file must
be given as a character string into the first component of the
\code{output} argument (default name is \code{"out"}), and the path for
saving the text file can be given through the second component of
\code{output}. The default value is \code{"default"}, meaning that the file
will be saved in the current working directory. Any other path can be
specified as a character string: see the \bold{Examples} section for an
illustration.

Two types of plots are available. The first one is obtained by setting
\code{plot = "lrStat"} and it is the default option. The likelihood ratio
statistics are displayed on the Y axis, for each item. The detection
threshold is displayed by a horizontal line, and items flagged as DIF are
printed with the color defined by argument \code{col}. By default, items
are spotted with their number identification (\code{number = TRUE});
otherwise they are simply drawn as dots whose form is given by the option
\code{pch}.

The other type of plot is obtained by setting \code{plot = "itemCurve"}. In
this case, the fitted logistic curves are displayed for one specific item
set by the argument \code{item}. The latter argument can hold either the
name of the item or its number identification. If the argument
\code{itemFit} takes the value \code{"best"}, the curves are drawn
according to the output of the best model among \eqn{M_0} and \eqn{M_1}.
That is, two curves are drawn if the item is flagged as DIF, and only one
if the item is flagged as non-DIF. If \code{itemFit} takes the value
\code{"null"}, then the two curves are drawn from the fitted parameters of
the null model \eqn{M_0}. See \code{\link{Logistik}} for further details on
the models. The colors and types of traits for these curves are defined by
means of the arguments \code{colIC} and \code{ltyIC} respectively. These
are set as vectors of length 2, the first element for the reference group
and the second for the focal group. Finally, the argument
\code{group.names} permits to display the names of the reference and focal
groups (instead of "Reference" and "Focal") in the legend.

Both types of plots can be stored in a figure file, either in PDF or JPEG
format. Fixing \code{save.plot} to \code{TRUE} allows this process. The
figure is defined through the components of \code{save.options}. The first
two components perform similarly as those of the \code{output} argument.
The third component is the figure format, with allowed values \code{"pdf"}
(default) for PDF file and \code{"jpeg"} for JPEG file.
}
\examples{

\dontrun{

 # Loading of the verbal data
 data(verbal)

 # Excluding the "Anger" variable
 anger <- verbal[, colnames(verbal) == "Anger"]
 verbal <- verbal[, colnames(verbal) != "Anger"]

 # Testing both DIF effects simultaneously
 # Three equivalent settings of the data matrix and the group membership
 r <- difLogistic(verbal, group = 25, focal.name = 1)
 difLogistic(verbal, group = "Gender", focal.name = 1)
 difLogistic(verbal[, 1:24], group = verbal[, 25], focal.name = 1)

 # Returning all covariance matrices of model parameters
 difLogistic(verbal, group = 25, focal.name = 1, all.cov = TRUE)

 # Testing both DIF effects with the Wald test
 r2 <- difLogistic(verbal, group = 25, focal.name = 1, criterion = "Wald")

 # Testing nonuniform DIF effect
 difLogistic(verbal, group = 25, focal.name = 1, type = "nudif")

 # Testing uniform DIF effect
 difLogistic(verbal, group = 25, focal.name = 1, type = "udif")

 # Multiple comparisons adjustment using Benjamini-Hochberg method
 difLogistic(verbal, group = 25, focal.name = 1, p.adjust.method = "BH")

 # With item purification
 difLogistic(verbal, group = "Gender", focal.name = 1, purify = TRUE)
 difLogistic(verbal, group = "Gender", focal.name = 1, purify = TRUE, nrIter = 5)

 # With combination of item purification and multiple comparisons adjustment
 difLogistic(verbal, group = "Gender", focal.name = 1, purify = TRUE,
             p.adjust.method = "BH", puriadjType = "simple")
 difLogistic(verbal, group = "Gender", focal.name = 1, purify = TRUE,
             p.adjust.method = "BH", puriadjType = "combined")

 # With items 1 to 5 set as anchor items
 difLogistic(verbal, group = 25, focal.name = 1, anchor = 1:5)

 # Using anger trait score as the matching criterion
 difLogistic(verbal,group = 25, focal.name = 1, match = anger)

 # Using trait anger score as the group variable (i.e. testing
 # for DIF with respect to trait anger score)
 difLogistic(verbal[, 1:24], group = anger, member.type = "cont")

 # Saving the output into the "Lresults.txt" file (and default path)
 r <- difLogistic(verbal, group = 25, focal.name = 1, save.output = TRUE,
           output = c("Lresults", "default"))

 # Graphical devices
 plot(r)
 plot(r2)
 plot(r, plot = "itemCurve", item = 1)
 plot(r, plot = "itemCurve", item = 1, itemFit = "null")
 plot(r, plot = "itemCurve", item = 6)
 plot(r, plot = "itemCurve", item = 6, itemFit = "null")

 # Plotting results and saving it in a PDF figure
 plot(r, save.plot = TRUE, save.options = c("plot", "default", "pdf"))

 # Changing the path, JPEG figure
 path <- "c:/Program Files/"
 plot(r, save.plot = TRUE, save.options = c("plot", path, "jpeg"))
}

}
\references{
Clauser, B.E. and Mazor, K.M. (1998). Using statistical
procedures to identify differential item functioning test items.
\emph{Educational Measurement: Issues and Practice, 17}, 31--44.

Finch, W.H. and French, B. (2007). Detection of crossing differential item
functioning: a comparison of four methods. \emph{Educational and
Psychological Measurement, 67}, 565--582, \doi{10.1177/0013164406296975}

Gomez-Benito, J., Dolores Hidalgo, M. and Padilla, J.-L. (2009). Efficacy
of effect size measures in logistic regression: An application for
detecting DIF. \emph{Methodology, 5}, 18--25, \doi{10.1027/1614-2241.5.1.18}

Hidalgo, M. D. and Lopez-Pina, J.A. (2004). Differential item functioning
detection and effect size: A comparison between logistic regression and
Mantel-Haenszel procedures. \emph{Educational and Psychological
Measurement, 64}, 903--915, \doi{10.1177/0013164403261769}

Hladká, A., Martinková, P., and Magis, D. (2023). Combining item purification
and multiple comparison adjustment methods in detection of differential item
functioning. \emph{Multivariate Behavioral Research, 59}(1), 46--61,
\doi{10.1080/00273171.2023.2205393}

Jodoin, M. G. and Gierl, M. J. (2001). Evaluating Type I error and power
rates using an effect size measure with logistic regression procedure for
DIF detection. \emph{Applied Measurement in Education, 14}, 329--349,
\doi{10.1207/S15324818AME1404_2}

Kim, J., and Oshima, T. C. (2013). Effect of multiple testing adjustment in
differential item functioning detection. \emph{Educational and
Psychological Measurement, 73}, 458--470, \doi{10.1177/0013164412467033}

Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general
framework and an R package for the detection of dichotomous differential
item functioning. \emph{Behavior Research Methods, 42}, 847--862,
\doi{10.3758/BRM.42.3.847}

Nagelkerke, N. J. D. (1991). A note on a general definition of the
coefficient of determination. \emph{Biometrika, 78}, 691--692,
\doi{10.1093/biomet/78.3.691}

Swaminathan, H. and Rogers, H. J. (1990). Detecting differential item
functioning using logistic regression procedures. \emph{Journal of
Educational Measurement, 27}, 361--370, \doi{10.1111/j.1745-3984.1990.tb00754.x}

Zumbo, B.D. (1999). \emph{A handbook on the theory and methods of
differential item functioning (DIF): logistic regression modelling as a
unitary framework for binary and Likert-type (ordinal) item scores}.
Ottawa, ON: Directorate of Human Resources Research and Evaluation,
Department of National Defense.

Zumbo, B. D. and Thomas, D. R. (1997). \emph{A measure of effect size for a
model-based approach for studying DIF}. Prince George, Canada: University
of Northern British Columbia, Edgeworth Laboratory for Quantitative
Behavioral Science.
}
\seealso{
\code{\link{Logistik}}, \code{\link{dichoDif}}
}
\author{
David Magis \cr
Data science consultant at IQVIA Belux \cr
Brussels, Belgium \cr

Sebastien Beland \cr
Faculte des sciences de l'education \cr
Universite de Montreal (Canada) \cr
\email{sebastien.beland@umontreal.ca} \cr

Gilles Raiche \cr Universite du
Quebec a Montreal \cr
\email{raiche.gilles@uqam.ca} \cr

Adela Hladka (nee Drabinova) \cr
Institute of Computer Science of the Czech Academy of Sciences \cr 
\email{hladka@cs.cas.cz} \cr
}
