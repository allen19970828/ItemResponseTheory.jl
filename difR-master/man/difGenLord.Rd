\name{difGenLord}
\alias{difGenLord}
\alias{plot.GenLord}
\alias{print.GenLord}

\title{Generalized Lord's chi-squared DIF method}

\description{
 Performs DIF detection among multiple groups using generalized Lord's chi-squared method. 
 }

\usage{
difGenLord(Data, group, focal.names, model, c = NULL, engine = "ltm", 
 	discr = 1, irtParam = NULL, nrFocal = 2, same.scale = TRUE, anchor = NULL,
 	alpha = 0.05, purify = FALSE, nrIter = 10, p.adjust.method = NULL, 
 	save.output = FALSE, 	output = c("out", "default")) 
\method{print}{GenLord}(x, ...)
\method{plot}{GenLord}(x, plot = "lordStat", item = 1, pch = 8,
  	number = TRUE, col = "red", colIC = rep("black",
  	length(x$focal.names)+1), ltyIC = 1:(length(x$focal.names)
  	+ 1), save.plot = FALSE, save.options = c("plot", "default", "pdf"),
      ref.name = NULL, ...)
 }

\arguments{
 \item{Data}{numeric: either the data matrix only, or the data matrix plus the vector of group membership. See \bold{Details}.}
 \item{group}{numeric or character: either the vector of group membership or the column indicator (within \code{Data}) of group membership. See \bold{Details}.}
 \item{focal.names}{numeric or character vector indicating the levels of \code{group} which correspond to the focal groups.}
 \item{model}{character: the IRT model to be fitted (either \code{"1PL"}, \code{"2PL"} or \code{"3PL"}).}
 \item{c}{optional numeric value or vector giving the values of the constrained pseudo-guessing parameters. See \bold{Details}.}
 \item{engine}{character: the engine for estimating the 1PL model, either \code{"ltm"} (default) or \code{"lme4"}.}
 \item{discr}{either \code{NULL} or a real positive value for the common discrimination parameter (default is 1). Used onlky if \code{model} is \code{"1PL"} and
             \code{engine} is \code{"ltm"}. See \bold{Details}.}
 \item{irtParam}{matrix with \emph{2J} rows (where \emph{J} is the number of items) and at most 9 columns containing item parameters estimates. See \bold{Details}.}
 \item{nrFocal}{numeric: the number of focal groups (default is 2).}
 \item{same.scale}{logical: are the item parameters of the \code{irtParam} matrix on the same scale? (default is \code{TRUE}). See \bold{Details}.}
\item{anchor}{either \code{NULL} (default) or a vector of item names (or identifiers) to specify the anchor items. See \bold{Details}.}
 \item{alpha}{numeric: significance level (default is 0.05).}
 \item{purify}{logical: should the method be used iteratively to purify the set of anchor items? (default is FALSE).}
 \item{nrIter}{numeric: the maximal number of iterations in the item purification process (default is 10).}
\item{p.adjust.method}{either \code{NULL} (default) or the acronym of the method for p-value adjustment for multiple comparisons. See \bold{Details}.}
 \item{save.output}{logical: should the output be saved into a text file? (Default is \code{FALSE}).}
 \item{output}{character: a vector of two components. The first component is the name of the output file, the second component is either the file path or \code{"default"} (default value). See \bold{Details}.} 
 \item{x}{the result from a \code{GenLord} class object.}
 \item{plot}{character: the type of plot, either \code{"lordStat"} or \code{"itemCurve"}. See \bold{Details}.}
 \item{item}{numeric or character: either the number or the name of the item for which ICC curves are plotted. Used only when \code{plot="itemCurve"}.}
 \item{pch, col}{type of usual \code{pch} and \code{col} graphical options.}
 \item{number}{logical: should the item number identification be printed (default is \code{TRUE}).}
 \item{colIC, ltyIC}{vectors of elements of the usual \code{col} and \code{lty} arguments for ICC curves. Used only when \code{plot="itemCurve"}.}
 \item{save.plot}{logical: should the plot be saved into a separate file? (default is \code{FALSE}).}
 \item{save.options}{character: a vector of three components. The first component is the name of the output file, the second component is either the file path or \code{"default"} (default value), and the third component is the file extension, either \code{"pdf"} (default) or \code{"jpeg"}. See \bold{Details}.}
 \item{ref.name}{either \code{NULL}(default) or a character string for the name of the reference group (to be used instead of "Reference" in the legend). Ignored if \code{plot} is \code{"lordStat"}.}
 \item{...}{other generic parameters for the \code{plot} or the \code{print} functions.}
 }

\value{
A list of class "GenLord" with the following arguments:
  \item{genLordChi}{the values of the generalized Lord's chi-squared statistics.}
 \item{p.value}{the vector of p-values for the generalized Lord's chi-square statistics.}
  \item{alpha}{the value of \code{alpha} argument.}
  \item{thr}{the threshold (cut-score) for DIF detection.}
  \item{df}{the degrees of freedom of the asymptotic null distribution of the statistics.}
  \item{DIFitems}{either the column indicators of the items which were detected as DIF items, or "No DIF item detected".}
 \item{p.adjust.method}{the value of the \code{p.adjust.method} argument.}
\item{adjusted.p}{either \code{NULL} or the vector of adjusted p-values for multiple comparisons.}
 \item{purification}{the value of \code{purify} option.} 
  \item{nrPur}{the number of iterations in the item purification process. Returned only if \code{purify} is \code{TRUE}.}
  \item{difPur}{a binary matrix with one row per iteration in the item purification process and one column per item. Zeros and ones in the \emph{i}-th 
   row refer to items which were classified respectively as non-DIF and DIF items at the (\emph{i}-1)-th step. The first row corresponds to the initial
   classification of the items. Returned only if \code{purify} is \code{TRUE}.}
  \item{convergence}{logical indicating whether the iterative item purification process stopped before the maximal number \code{nrIter}of allowed iterations. 
  Returned only if \code{purify} is \code{TRUE}.}
  \item{model}{the value of \code{model} argument.}
  \item{c}{The value of the \code{c} argument.}
  \item{engine}{The value of the \code{engine} argument.}
  \item{discr}{the value of the \code{discr} argument.}
  \item{itemParInit}{the matrix of initial parameter estimates, with the same format as \code{irtParam} either provided by the user (through \code{irtParam}) or estimated from the data (and displayed after rescaling).}
  \item{itemParFinal}{the matrix of final parameter estimates, with the same format as \code{irtParam}, obtained after item purification. Returned 
   only if \code{purify} is \code{TRUE}.}
  \item{estPar}{a logical value indicating whether the item parameters were estimated (\code{TRUE}) or provided by the user (\code{FALSE}).}
  \item{names}{the names of the items.}
 \item{anchor.names}{the value of the \code{anchor} argument.}
  \item{focal.names}{the value of the \code{focal.names} argument.}
  \item{save.output}{the value of the \code{save.output} argument.}
  \item{output}{the value of the \code{output} argument.}
 }
 
\details{
 The generalized Lord's chi-squared method (Kim, Cohen and Park, 1995), also referred to as \emph{Qj} statistic, allows for detecting uniform or non-uniform
 differential item functioning among multiple groups by setting an appropriate item response model. The input can be of two kinds: either by displaying 
 the full data, the group membership, the focal groups and the model, or by giving the item parameter estimates (with the option \code{irtParam}).
 Both can be supplied, but in this case only the parameters in \code{irtParam} are used for computing generalized Lord's chi-squared statistic.

 The \code{Data} is a matrix whose rows correspond to the subjects and columns to the items.
 In addition, \code{Data} can hold the vector of group membership. If so, \code{group} indicates the column of \code{Data} which corresponds to the group membership, either by specifying its name or by giving the column number. Otherwise, \code{group} must be a vector of same length as \code{nrow(Data)}.

 Missing values are allowed for item responses (not for group membership) but must be coded as \code{NA} values. They are discarded for item parameter estimation.
 
 The vector of group membership must hold at least three different values, either as numeric or character. The focal groups are defined by the values of the argument \code{focal.names}. 
 
 If the model is not the 1PL model, or if \code{engine} is equal to \code{"ltm"}, the selected IRT model is fitted using marginal maximum likelihood by means of the functions from the \code{ltm} package (Rizopoulos, 2006). Otherwise, the 1PL model is fitted as a generalized linear mixed model, by means of the \code{glmer} function of the \code{lme4} package (Bates and Maechler, 2009).

 With the \code{"1PL"} model and the \code{"ltm"} engine, the common discrimination parameter is set equal to 1 by default. It is possible to fix another value through the argument\code{discr}. Alternatively, this common discrimination parameter can be estimated (though not returned) by fixing \code{discr} to 
 \code{NULL}.

 The 3PL model can be fitted either unconstrained (by setting \code{c} to \code{NULL}) or by fixing the pseudo-guessing values. In the latter case, the argument \code{c} is either a numeric vector of same length of the number of items, with one value per item pseudo-guessing parameter, or a single value which is duplicated for all the items. If \code{c} is different from \code{NULL} then the 3PL model is always fitted (whatever the value of \code{model}).

 The \code{irtParam} matrix has a number of rows equal to the number of groups (reference and focal ones) times the number of items \emph{J}. The first \emph{J} rows refer to the item parameter estimates in the reference group, while the next sets of \emph{J} rows correspond to the same items in each of 
 the focal groups. The number of columns depends on the selected IRT model: 2 for the 1PL model, 5 for the 2PL model, 6 for the constrained 3PL model and 9 for the unconstrained 3PL model. The columns of \code{irtParam} have to follow the same structure as the output of \code{itemParEst} command (the latter can actually be used to create the \code{irtParam} matrix). The number of focal groups has to be specified with argument \code{nrFocal} (default value is 2).

 In addition to the matrix of parameter estimates, one has to specify whether items in the focal groups were rescaled to those of the reference group. If not, rescaling is performed by equal means anchoring (Cook and Eignor, 1991). Argument \code{same.scale} is used for this choice (default option is \code{TRUE} and assumes therefore that the parameters are already placed on a same scale). 

 The threshold (or cut-score) for classifying items as DIF is computed as the quantile of the chi-squared distribution with lower-tail probability of one minus \code{alpha} and \emph{p} degrees of freedom. The value of \emph{p} is the product of the number of focal groups by the number of item parameters to be tested (1 for the 1PL model, 2 for the 2PL model or the constrained 3PL model, and 3 for the unconstrained 3PL model).
 
 Item purification can be performed by setting \code{purify} to \code{TRUE}. In this case, the purification occurs in the equal means anchoring process: items detected as DIF are iteratively removed from the set of items used for equal means anchoring, and the procedure is repeated until either the same items
 are identified twice as functioning differently, or when \code{nrIter} iterations have been performed. In the latter case a warning message is printed. See Candell and Drasgow (1988) for further details.

Adjustment for multiple comparisons is possible with the argument \code{p.adjust.method}. The latter must be an acronym of one of the available adjustment methods of the \code{\link{p.adjust}} function. According to Kim and Oshima (2013), Holm and Benjamini-Hochberg adjustments (set respectively by \code{"Holm"} and \code{"BH"}) perform best for DIF purposes. See \code{\link{p.adjust}} function for further details. Note that item purification is performed on original statistics and p-values; in case of adjustment for multiple comparisons this is performed \emph{after} item purification.

A pre-specified set of anchor items can be provided through the \code{anchor} argument. It must be a vector of either item names (which must match exactly the column names of \code{Data} argument) or integer values (specifying the column numbers for item identification). In case anchor items are provided, they are used to rescale the item parameters on a common metric. None of the anchor items are tested for DIF: the output separates anchor items and tested items and DIF results are returned only for the latter. Note also that item purification is not activated when anchor items are provided (even if \code{purify} is set to \code{TRUE}). By default it is \code{NULL} so that no anchor item is specified. If item parameters are provided thorugh the \code{irtParam} argument and if they are on the same scale (i.e. if \code{same.scale} is \code{TRUE}), then anchor items are not used (even if they are specified).

 The output of the \code{difGenLord}, as displayed by the \code{print.GenLord} function, can be stored in a text file provided that \code{save.output} is set to \code{TRUE} 
 (the default value \code{FALSE} does not execute the storage). In this case, the name of the text file must be given as a character string into the first component
 of the \code{output} argument (default name is \code{"out"}), and the path for saving the text file can be given through the second component of \code{output}. The
 default value is \code{"default"}, meaning that the file will be saved in the current working directory. Any other path can be specified as a character string: see the 
 \bold{Examples} section for an illustration.

 Two types of plots are available. The first one is obtained by setting \code{plot="lordStat"} and it is the default option. The chi-squared statistics are displayed 
 on the Y axis, for each item. The detection threshold is displayed by a horizontal line, and items flagged as DIF are printed with the color defined by argument \code{col}.
 By default, items are spotted with their number identification (\code{number=TRUE}); otherwise they are simply drawn as dots whose form is given by the option \code{pch}.

 The other type of plot is obtained by setting \code{plot="itemCurve"}. In this case, the fitted ICC curves are displayed for one specific item set by the argument 
 \code{item}. The latter argument can hold either the name of the item or its number identification. The item parameters are extracted from the \code{itemParFinal} matrix
 if the output argument \code{purification} is \code{TRUE}, otherwise from the \code{itemParInit} matrix and after a rescaling of the item parameters using the 
 \code{\link{itemRescale}} command. A legend is displayed in the upper left corner of the plot. The colors and types of traits for these curves are defined by means of 
 the arguments \code{colIC} and \code{ltyIC} respectively. These are set as vectors of length 2, the first element for the reference group and the second for the focal group.
 Finally, the \code{ref.name} argument permits to display the name if the reference group (instead of "Reference") in the legend.

 Both types of plots can be stored in a figure file, either in PDF or JPEG format. Fixing \code{save.plot} to \code{TRUE} allows this process. The figure is defined through
 the components of \code{save.options}. The first two components perform similarly as those of the \code{output} argument. The third component is the figure format, with 
 allowed values \code{"pdf"} (default) for PDF file and \code{"jpeg"} for JPEG file.
}


\references{
 Bates, D. and Maechler, M. (2009). lme4: Linear mixed-effects models using S4 classes. R package version 0.999375-31. http://CRAN.R-project.org/package=lme4

 Candell, G.L. and Drasgow, F. (1988). An iterative procedure for linking metrics and assessing item bias in item response theory. \emph{Applied Psychological Measurement, 12}, 253-260. 

 Cook, L. L. and Eignor, D. R. (1991). An NCME instructional module on IRT equating methods. \emph{Educational Measurement: Issues and Practice, 10}, 37-45.
 
 Kim, S.-H., Cohen, A.S. and Park, T.-H. (1995). Detection of differential item functioning in multiple groups. \emph{Journal of Educational Measurement, 32}, 261-276. \doi{10.1111/j.1745-3984.1995.tb00466.x}

Kim, J., and Oshima, T. C. (2013). Effect of multiple testing adjustment in differential item functioning detection. \emph{Educational and Psychological Measurement, 73}, 458--470. \doi{10.1177/0013164412467033}

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
 \code{\link{itemParEst}}
}

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)
 attach(verbal)

 # Creating four groups according to gender ("Man" or "Woman") and trait
 # anger score ("Low" or "High")
 group <- rep("WomanLow",nrow(verbal))
 group[Anger>20 & Gender==0] <- "WomanHigh"
 group[Anger<=20 & Gender==1] <- "ManLow"
 group[Anger>20 & Gender==1] <- "ManHigh"

 # New data set
 Verbal <- cbind(verbal[,1:24], group)

 # Reference group: "WomanLow"
 names <- c("WomanHigh", "ManLow", "ManHigh")

 # Three equivalent settings of the data matrix and the group membership
 # 1PL model, "ltm" engine 
 r <- difGenLord(Verbal, group = 25, focal.names = names, model = "1PL")
 difGenLord(Verbal, group = "group", focal.name = names, model = "1PL")
 difGenLord(Verbal[,1:24], group = Verbal[,25], focal.names = names, model = "1PL")

 # 1PL model, "ltm" engine, estimated common discrimination 
 r <- difGenLord(Verbal, group = 25, focal.names = names, model = "1PL", discr = NULL)

 # 1PL model, "lme4" engine 
 difGenLord(Verbal, group = "group", focal.name = names, model = "1PL", engine = "lme4")

 # With items 1 to 5 set as anchor items
 difGenLord(Verbal, group = 25, focal.names = names, model = "1PL", anchor = 1:5)

 # Multiple comparisons adjustment using Benjamini-Hochberg method
 difGenLord(Verbal, group = 25, focal.names = names, model = "1PL", p.adjust.method = "BH")

 # With item purification
 difGenLord(Verbal, group = 25, focal.names = names, model = "1PL", purify = TRUE)

 # Saving the output into the "GLresults.txt" file (and default path)
 r <- difGenLord(Verbal, group = 25, focal.names = names, model = "1PL", 
         save.output = TRUE, output = c("GLresults", "default"))

 # Splitting the data into the four subsets according to "group"
 data0<-data1<-data2<-data3<-NULL
 for (i in 1:nrow(verbal)){
  if (group[i]=="WomanLow") data0<-rbind(data0,as.numeric(verbal[i,1:24]))
  if (group[i]=="WomanHigh") data1<-rbind(data1,as.numeric(verbal[i,1:24]))
  if (group[i]=="ManLow") data2<-rbind(data2,as.numeric(verbal[i,1:24]))
  if (group[i]=="ManHigh") data3<-rbind(data3,as.numeric(verbal[i,1:24]))
  }

 # Estimation of the item parameters (1PL model)
 m0.1PL<-itemParEst(data0, model = "1PL")
 m1.1PL<-itemParEst(data1, model = "1PL")
 m2.1PL<-itemParEst(data2, model = "1PL")
 m3.1PL<-itemParEst(data3, model = "1PL")

 # Merging the item parameters WITHOUT rescaling
 irt.noscale<-rbind(m0.1PL,m1.1PL,m2.1PL,m3.1PL)
 rownames(irt.noscale)<-rep(colnames(verbal[,1:24]),4)

 # Merging the item parameters WITH rescaling
 irt.scale<-rbind(m0.1PL, itemRescale(m0.1PL,m1.1PL),
 itemRescale(m0.1PL,m2.1PL) ,itemRescale(m0.1PL,m3.1PL))
 rownames(irt.scale)<-rep(colnames(verbal[,1:24]),4)

 # Equivalent calculations
 difGenLord(irtParam = irt.noscale, nrFocal = 3, same.scale = FALSE)
 difGenLord(irtParam = irt.scale, nrFocal = 3, same.scale = TRUE)

 # With item purification
 difGenLord(irtParam = irt.noscale, nrFocal = 3, same.scale = FALSE, purify = TRUE)

 # Graphical devices
 plot(r)
 plot(r, plot = "itemCurve", item = 1)
 plot(r, plot = "itemCurve", item = 6)
 plot(r, plot = "itemCurve", item = 6, ref.name = "WomanHigh")

 # Plotting results and saving it in a PDF figure
 plot(r, save.plot = TRUE, save.options = c("plot", "default", "pdf"))

 # Changing the path, JPEG figure
 path <- "c:/Program Files/"
 plot(r, save.plot = TRUE, save.options = c("plot", path, "jpeg"))
}
 }
