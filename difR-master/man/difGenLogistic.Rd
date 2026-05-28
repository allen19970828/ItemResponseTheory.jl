\name{difGenLogistic}
\alias{difGenLogistic}
\alias{print.genLogistic}
\alias{plot.genLogistic}

\title{Generalized logistic regression DIF method}

\description{
  Performs DIF detection among multiple groups using generalized 
  logistic regression method.
 }

\usage{
difGenLogistic(Data, group, focal.names, anchor = NULL, match = "score", 
 	type = "both", criterion = "LRT", alpha = 0.05, purify = FALSE, nrIter = 10,
 	p.adjust.method = NULL, save.output = FALSE, output = c("out", "default"))
\method{print}{genLogistic}(x, ...)
\method{plot}{genLogistic}(x, plot = "lrStat", item = 1, itemFit = "best",pch = 8, number = TRUE,
  	col = "red", colIC = rep("black", length(x$focal.names)+1),
  	ltyIC = 1:(length(x$focal.names)+1), title = NULL, save.plot = FALSE, 
  	save.options = c("plot", "default", "pdf"), ref.name = NULL, ...)
 }
 
\arguments{
 \item{Data}{numeric: either the data matrix only, or the data matrix plus the vector of group membership. See \bold{Details}.}
 \item{group}{numeric or character: either the vector of group membership or the column indicator (within \code{data}) of group membership. See \bold{Details}.}
 \item{focal.names}{numeric or character vector indicating the levels of \code{group} which correspond to the focal groups.}
\item{anchor}{either \code{NULL} (default) or a vector of item names (or identifiers) to specify the anchor items. Ignored if \code{match} is not \code{"score"}. See \bold{Details}.}
 \item{match}{specifies the type of matching criterion. Can be either \code{"score"} (default) to compute the test score, or any continuous or discrete variable with the same length as the number of rows of \code{Data}. See \bold{Details}.}
 \item{type}{a character string specifying which DIF effects must be tested. Possible values are \code{"both"} (default), \code{"udif"} and \code{"nudif"}.
            See \bold{Details}.}
 \item{criterion}{character: the type of test statistic used to detect DIF items. Possible values are \code{"LRT"} (default) and \code{"Wald"}. See \bold{Details}.}
 \item{alpha}{numeric: significance level (default is 0.05).}
 \item{purify}{logical: should the method be used iteratively to purify the set of anchor items? (default is FALSE).}
 \item{nrIter}{numeric: the maximal number of iterations in the item purification process (default is 10).}
\item{p.adjust.method}{either \code{NULL} (default) or the acronym of the method for p-value adjustment for multiple comparisons. See \bold{Details}.}
 \item{save.output}{logical: should the output be saved into a text file? (Default is \code{FALSE}).}
 \item{output}{character: a vector of two components. The first component is the name of the output file, the second component is either the file path or
              \code{"default"} (default value). See \bold{Details}.}
 \item{x}{the result from a \code{Logistik} class object.}
 \item{plot}{character: the type of plot, either \code{"lrStat"} or \code{"itemCurve"}. See \bold{Details}.}
 \item{item}{numeric or character: either the number or the name of the item for which logistic curves are plotted. Use only when \code{plot="itemCurve"}.}
 \item{itemFit}{character: the model to be selected for drawing the item curves. Possible values are \code{"best"} (default) for drawing from the best of the two
                models, and \code{"null"} for using fitted parameters of the null model \eqn{M_0}. Not used if \code{"plot"} is \code{"lrStat"}. See \bold{Details}.}
 \item{pch, col}{type of usual \code{pch} and \code{col} graphical options.}
 \item{number}{logical: should the item number identification be printed (default is \code{TRUE}).}
 \item{colIC, ltyIC}{vectors of elements of the usual \code{col} and \code{lty} arguments for logistic curves. Used only when \code{plot="itemCurve"}.}
 \item{title}{either a character string with the title of the plot, or \code{NULL} (default), for which a specific title is automatically displayed.}
 \item{save.plot}{logical: should the plot be saved into a separate file? (default is \code{FALSE}).}
 \item{save.options}{character: a vector of three components. The first component is the name of the output file, the second component is either the file path or
                    \code{"default"} (default value), and the third component is the file extension, either \code{"pdf"} (default) or \code{"jpeg"}. See
                    \bold{Details}.}
 \item{ref.name}{either \code{NULL}(default) or a character string for the name of the reference group (to be used instead of "Reference" in the legend). Ignored 
                if \code{plot} is \code{"lrStat"}.}
 \item{...}{other generic parameters for the \code{plot} or the \code{print} functions.}
}


\value{
A list of class "genLogistic" with the following arguments:
  \item{genLogistik}{the values of the generalized logistic regression statistics.}
 \item{p.value}{the vector of p-values for the generalized logistic regression statistics.}
 \item{logitPar}{a matrix with one row per item and \eqn{2+J*2} columns, holding the fitted parameters of the best model (among the two tested models) for each
                 item.}
  \item{parM0}{the matrix of fitted parameters of the null model \eqn{M_0}, as returned by the \code{\link{Logistik}} command.}
  \item{covMat}{a 3-dimensional matrix of size \emph{p} x \emph{p} x \emph{K}, where \emph{p} is the number of estimated parameters and \emph{K} is the number of
               items, holding the \emph{p} x \emph{p} covariance matrices of the estimated parameters (one matrix for each tested item).}
  \item{deltaR2}{the differences in Nagelkerke's \eqn{R^2} coefficients. See \bold{Details}.}
  \item{alpha}{the value of \code{alpha} argument.}
  \item{thr}{the threshold (cut-score) for DIF detection.}
  \item{DIFitems}{either the column indicators for the items which were detected as DIF items, or "No DIF item detected".}
  \item{type}{the value of \code{type} argument.}
\item{p.adjust.method}{the value of the \code{p.adjust.method} argument.}
\item{adjusted.p}{either \code{NULL} or the vector of adjusted p-values for multiple comparisons.}
  \item{purification}{the value of \code{purify} option.} 
  \item{nrPur}{the number of iterations in the item purification process. Returned only if \code{purify} is \code{TRUE}.}
  \item{difPur}{a binary matrix with one row per iteration in the item purification process and one column per item. Zeros and ones in the \emph{i}-th 
  row refer to items which were classified respectively as non-DIF and DIF items at the (\emph{i}-1)-th step. The first row corresponds to the initial
  classification of the items. Returned only if \code{purify} is \code{TRUE}.}
  \item{convergence}{logical indicating whether the iterative item purification process stopped before the maximal number of \code{nrItem} allowed iterations. 
  Returned only if \code{purify} is \code{TRUE}.}
  \item{names}{the names of the items.}
 \item{anchor.names}{the value of the \code{anchor} argument.}
  \item{focal.names}{the value of \code{focal.names} argument.}
  \item{criterion}{the value of the \code{criterion} argument.}
  \item{save.output}{the value of the \code{save.output} argument.}
  \item{output}{the value of the \code{output} argument.}
 }


\details{
 The generalized logistic regression method (Magis, Raiche, Beland and Gerard, 2011) allows for detecting both uniform and non-uniform differential item
 functioning among multiple groups without requiring an item response model approach. It consists in fitting a logistic model with the matching criterion,
 the group membership and an interaction between both as covariates. The statistical significance of the parameters
 related to group membership and the group-score interaction is then evaluated by means of the usual likelihood-ratio
 test. The argument \code{type} permits to test either both uniform and nonuniform effects simultaneously (\code{type="both"}), only uniform
 DIF effect (\code{type="udif"}) or only nonuniform DIF effect (\code{type="nudif"}). The identification of DIF items can be performed with
 either the Wald test or the likelihood  ratio test, by setting the \code{criterion} argument to \code{"Wald"} or \code{"LRT"} respectively.
 See \code{\link{genLogistik}} for further details.
 
 The matching criterion can be either the test score or any other continuous or discrete variable to be passed in the \code{\link{genLogistik}} function. This is specified by the \code{match} argument. By default, it takes the value \code{"score"} and the test score (i.e. raw score) is computed. The second option is to assign to \code{match} a vector of continuous or discrete numeric values, which acts as the matching criterion. Note that for consistency this vector should not belong to the \code{Data} matrix.

 The \code{Data} is a matrix whose rows correspond to the subjects and columns to the items. In addition, \code{Data} can hold the vector of group membership.
 If so, \code{group} indicates the column of \code{Data} which corresponds to the group membership, either by specifying its name or by giving the column number.
 Otherwise, \code{group} must be a vector of same length as \code{nrow(Data)}.
 
 Missing values are allowed for item responses (not for group membership) but must be coded as \code{NA} values. They are discarded from the fitting of the
 logistic models (see \code{\link{glm}} for further details).

 The vector of group membership must hold at least three values, either as numeric or character. The focal groups are defined by the values of the 
 argument \code{focal.names}. If there is a unique focal group, then \code{difGenLogistic} returns the output of \code{\link{difLogistic}}.
 
 The threshold (or cut-score) for classifying items as DIF is computed as the quantile of the chi-squared distribution with lower-tail
 probability of one minus \code{alpha} and with \emph{J} (if \code{type="udif"} or \code{type="nudif"}) or \emph{2J} (if \code{type="both"}) degrees of
 freedom (\emph{J} is the number of focal groups).
 
 Item purification can be performed by setting \code{purify} to \code{TRUE}. Purification works as follows: if at least one item is detected as functioning 
 differently at the first step of the process, then the data set of the next step consists in all items that are currently anchor (DIF free) items, plus the 
 tested item (if necessary). The process stops when either two successive applications of the method yield the same classifications of the items
 (Clauser and Mazor, 1998), or when \code{nrIter} iterations are run without obtaining two successive identical classifications. In the latter case a warning message is printed. 

Adjustment for multiple comparisons is possible with the argument \code{p.adjust.method}. The latter must be an acronym of one of the available adjustment methods of the \code{\link{p.adjust}} function. According to Kim and Oshima (2013), Holm and Benjamini-Hochberg adjustments (set respectively by \code{"Holm"} and \code{"BH"}) perform best for DIF purposes. See \code{\link{p.adjust}} function for further details. Note that item purification is performed on original statistics and p-values; in case of adjustment for multiple comparisons this is performed \emph{after} item purification.

A pre-specified set of anchor items can be provided through the \code{anchor} argument. It must be a vector of either item names (which must match exactly the column names of \code{Data} argument) or integer values (specifying the column numbers for item identification). In case anchor items are provided, they are used to compute the test score (matching criterion), including also the tested item. None of the anchor items are tested for DIF: the output separates anchor items and tested items and DIF results are returned only for the latter. By default it is \code{NULL} so that no anchor item is specified. Note also that item purification is not activated when anchor items are provided (even if \code{purify} is set to \code{TRUE}). Moreover, if the \code{match} argument is not set to \code{"score"}, anchor items will not be taken into account even if \code{anchor} is not \code{NULL}. 

 The measures of effect size are provided by the difference \eqn{\Delta R^2} between the \eqn{R^2} coefficients of the two nested models (Nagelkerke, 1991; Gomez-Benito, Dolores Hidalgo and Padilla, 2009). The effect sizes are classified as "negligible", "moderate" or "large". Two scales are available, one from Zumbo and Thomas (1997) and one from Jodoin and Gierl (2001). The output displays the \eqn{\Delta R^2} measures, together with the two classifications.

 The output of the \code{difGenLogistic}, as displayed by the \code{print.genLogistic} function, can be stored in a text file provided that \code{save.output} is set
 to \code{TRUE} (the default value \code{FALSE} does not execute the storage). In this case, the name of the text file must be given as a character string into the
 first component of the \code{output} argument (default name is \code{"out"}), and the path for saving the text file can be given through the second component of
 \code{output}. The default value is \code{"default"}, meaning that the file will be saved in the current working directory. Any other path can be specified as a
 character string: see the \bold{Examples} section for an illustration.

 Two types of plots are available. The first one is obtained by setting \code{plot="lrStat"} and it is the default option. The likelihood ratio statistics are
 displayed on the Y axis, for each item. The detection threshold is displayed by a horizontal line, and items flagged as DIF are printed with the color defined by
 argument \code{col}. By default, items are spotted with their number identification (\code{number=TRUE}); otherwise they are simply drawn as dots whose form is
 given by the option \code{pch}.

 The other type of plot is obtained by setting \code{plot="itemCurve"}. In this case, the fitted logistic curves are displayed for one specific item set by the
 argument \code{item}. The latter argument can hold either the name of the item or its number identification. If the argument \code{itemFit} takes the value
 \code{"best"}, the curves are drawn according to the output of the best model among \eqn{M_0} and \eqn{M_1}. That is, two curves are drawn if the item is flagged
 as DIF, and only one if the item is flagged as non-DIF. If \code{itemFit} takes the value \code{"null"}, then the two curves are drawn from the fitted parameters
 of the null model \eqn{M_0}. See \code{\link{genLogistik}} for further details on the models. The colors and types of traits for these curves are defined by means
 of the arguments \code{colIC} and \code{ltyIC} respectively. These are set as vectors of length \eqn{J+1}, the first element for the reference group and the others
 for the focal groups. Finally, the \code{ref.name} argument permits to display the name if the reference group (instead of "Reference") in the legend.

 Both types of plots can be stored in a figure file, either in PDF or JPEG format. Fixing \code{save.plot} to \code{TRUE} allows this process. The figure is defined
 through the components of \code{save.options}. The first two components perform similarly as those of the \code{output} argument. The third component is the figure
 format, with allowed values \code{"pdf"} (default) for PDF file and \code{"jpeg"} for JPEG file.
}

\references{
Clauser, B.E. and Mazor, K.M. (1998). Using statistical procedures to identify differential item functioning test items. \emph{Educational Measurement: Issues
 and Practice, 17}, 31-44. 

 Gomez-Benito, J., Dolores Hidalgo, M. and Padilla, J.-L. (2009). Efficacy of effect size measures in logistic regression: an application for detecting DIF. 
 \emph{Methodology, 5}, 18-25. \doi{10.1027/1614-2241.5.1.18}

 Hidalgo, M. D. and Lopez-Pina, J.A. (2004). Differential item functioning detection and effect size: a comparison between logistic regression and Mantel-Haenszel
 procedures. \emph{Educational and Psychological Measurement, 64}, 903-915.  \doi{10.1177/0013164403261769}
 
 Jodoin, M. G. and Gierl, M. J. (2001). Evaluating Type I error and power rates using an effect size measure with logistic regression procedure for DIF detection. \emph{Applied Measurement in Education, 14}, 329-349. \doi{10.1207/S15324818AME1404_2}

Kim, J., and Oshima, T. C. (2013). Effect of multiple testing adjustment in differential item functioning detection. \emph{Educational and Psychological Measurement, 73}, 458--470. \doi{10.1177/0013164412467033}

 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

 Magis, D., Raiche, G., Beland, S. and Gerard, P. (2011). A logistic regression procedure to detect differential item functioning among multiple groups. \emph{International Journal of Testing, 11}, 365--386. \doi{10.1080/15305058.2011.602810}

 Nagelkerke, N. J. D. (1991). A note on a general definition of the coefficient of determination. \emph{Biometrika, 78}, 691-692. \doi{10.1093/biomet/78.3.691}

 Zumbo, B. D. and Thomas, D. R. (1997). \emph{A measure of effect size for a model-based approach for studying DIF}. Prince George, Canada: University of Northern British
 Columbia, Edgeworth Laboratory for Quantitative Behavioral Science.
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
 \code{\link{genLogistik}}, \code{\link{genDichoDif}}, \code{\link{subtestLogistic}}
}

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)
 attach(verbal)

 # Creating four groups according to gender ("Man" or "Woman") and
 # trait anger score ("Low" or "High")
 group <- rep("WomanLow", nrow(verbal))
 group[Anger>20 & Gender==0] <- "WomanHigh"
 group[Anger<=20 & Gender==1] <- "ManLow"
 group[Anger>20 & Gender==1] <- "ManHigh"

 # New data set
 Verbal <- cbind(verbal[,1:24], group)

 # Reference group: "WomanLow"
 names <- c("WomanHigh", "ManLow", "ManHigh")

 # Testing both types of DIF effects
 # Three equivalent settings of the data matrix and the group membership
 r <- difGenLogistic(Verbal, group = 25, focal.names = names)
 difGenLogistic(Verbal, group = "group", focal.name = names)
 difGenLogistic(Verbal[,1:24], group = Verbal[,25], focal.names = names)

 # Using the Wald test
 difGenLogistic(Verbal, group = 25, focal.names = names, criterion = "Wald")

 # Multiple comparisons adjustment using Benjamini-Hochberg method
difGenLogistic(Verbal, group = 25, focal.names = names, p.adjust.method = "BH")

 # With item purification
 difGenLogistic(Verbal, group = 25, focal.names = names, purify = TRUE)
 difGenLogistic(Verbal, group = 25, focal.names = names, purify = TRUE,
   nrIter = 5)

 # With items 1 to 5 set as anchor items
 difGenLogistic(Verbal, group = 25, focal.name = names, anchor = 1:5)

 # Testing for nonuniform DIF effect
 difGenLogistic(Verbal, group = 25, focal.names = names, type = "nudif")

 # Testing for uniform DIF effect
 difGenLogistic(Verbal, group = 25, focal.names = names, type = "udif")

 # User anger trait score as matching criterion
 anger <- verbal[,25]
 difGenLogistic(Verbal, group = 25, focal.names = names, match = anger)

 # Saving the output into the "GLresults.txt" file (and default path)
 r <- difGenLogistic(Verbal, group = 25, focal.name = names, 
                save.output = TRUE, output = c("GLresults","default"))

 # Graphical devices
 plot(r)
 plot(r, plot = "itemCurve", item = 1)
 plot(r, plot = "itemCurve", item = 1, itemFit = "best")
 plot(r, plot = "itemCurve", item = 6)
 plot(r, plot = "itemCurve", item = 6, itemFit = "best")

 # Plotting results and saving it in a PDF figure
 plot(r, save.plot = TRUE, save.options = c("plot", "default", "pdf"))

 # Changing the path, JPEG figure
 path <- "c:/Program Files/"
 plot(r, save.plot = TRUE, save.options = c("plot", path, "jpeg"))
}
 }
