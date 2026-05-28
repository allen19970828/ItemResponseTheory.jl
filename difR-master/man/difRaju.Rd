\name{difRaju}
\alias{difRaju}
\alias{plot.Raj}
\alias{print.Raj}

\title{Raju's area DIF method}

\description{
  Performs DIF detection using Raju's area method. 
 }

\usage{
difRaju(Data, group, focal.name, model, c = NULL, engine = "ltm", discr = 1, 
 	irtParam = NULL,  same.scale = TRUE, anchor = NULL, alpha = 0.05, 
 	signed = FALSE, purify = FALSE, nrIter = 10, p.adjust.method = NULL, 
 	save.output = FALSE, output = c("out","default"))   	
\method{print}{Raj}(x, ...)
\method{plot}{Raj}(x, pch = 8, number = TRUE, col = "red", save.plot = FALSE, 
 	save.options = c("plot","default","pdf"), ...)
 }

\arguments{
 \item{Data}{numeric: either the data matrix only, or the data matrix plus the vector of group membership. See \bold{Details}.}
 \item{group}{numeric or character: either the vector of group membership or the column indicator (within \code{data}) of group membership. See \bold{Details}.}
 \item{focal.name}{numeric or character indicating the level of \code{group} which corresponds to the focal group.}
 \item{model}{character: the IRT model to be fitted (either \code{"1PL"}, \code{"2PL"} or \code{"3PL"}).}
 \item{c}{optional numeric value or vector giving the values of the constrained pseudo-guessing parameters. See \bold{Details}.}
 \item{engine}{character: the engine for estimating the 1PL model, either \code{"ltm"} (default) or \code{"lme4"}.}
 \item{discr}{either \code{NULL} or a real positive value for the common discrimination parameter (default is 1). Used only if \code{model} is \code{"1PL"} and
             \code{engine} is \code{"ltm"}. See \bold{Details}.}
 \item{irtParam}{matrix with \emph{2J} rows (where \emph{J} is the number of items) and at most 9 columns containing item parameters estimates. See \bold{Details}.}
 \item{same.scale}{logical: are the item parameters of the \code{irtParam} matrix on the same scale? (default is "TRUE"). See \bold{Details}.}
\item{anchor}{either \code{NULL} (default) or a vector of item names (or identifiers) to specify the anchor items. See \bold{Details}.}
 \item{alpha}{numeric: significance level (default is 0.05).}
 \item{signed}{logical: should the Raju's statistics be computed using the signed (\code{TRUE}) or unsigned (\code{FALSE}, default)
               area? See \bold{Details}.}
 \item{purify}{logical: should the method be used iteratively to purify the set of anchor items? (default is FALSE).}
 \item{nrIter}{numeric: the maximal number of iterations in the item purification process (default is 10).} 
 \item{p.adjust.method}{either \code{NULL} (default) or the acronym of the method for p-value adjustment for multiple comparisons. See \bold{Details}.}
 \item{save.output}{logical: should the output be saved into a text file? (Default is \code{FALSE}).}
 \item{output}{character: a vector of two components. The first component is the name of the output file, the second component is either the file path or \code{"default"} (default value). See \bold{Details}.}
 \item{x}{the result from a \code{Raj} class object.}
 \item{pch, col}{type of usual \code{pch} and \code{col} graphical options.}
 \item{number}{logical: should the item number identification be printed (default is \code{TRUE}).}
 \item{save.plot}{logical: should the plot be saved into a separate file? (default is \code{FALSE}).}
 \item{save.options}{character: a vector of three components. The first component is the name of the output file, the second component is either the file path or \code{"default"} (default value),
                     and the third component is the file extension, either \code{"pdf"} (default) or \code{"jpeg"}. See \bold{Details}.}
 \item{...}{other generic parameters for the \code{plot} or the \code{print} functions.}
 }

\value{
A list of class "Raj" with the following arguments:
  \item{RajuZ}{the values of the Raju's statistics.}
\item{p.value}{the p-values for the Raju's statistics.}
  \item{alpha}{the value of \code{alpha} argument.}
  \item{thr}{the threshold (cut-score) for DIF detection.}
  \item{DIFitems}{either the column indicators of the items which were detected as DIF items, or "No DIF item detected".}
  \item{signed}{the value of the \code{signed} argument.}
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
  \item{itemParInit}{the matrix of initial parameter estimates,with the same format as \code{irtParam} either provided by the user (through \code{irtParam}) or estimated from the data
   (and displayed without rescaling).}
  \item{itemParFinal}{the matrix of final parameter estimates, with the same format as \code{irtParam}, obtained after item purification. Returned 
   only if \code{purify} is \code{TRUE}.}
  \item{estPar}{a logical value indicating whether the item parameters were estimated (\code{TRUE}) or provided by the user (\code{FALSE}).}
  \item{names}{the names of the items.}
 \item{anchor.names}{the value of the \code{anchor} argument.}
  \item{save.output}{the value of the \code{save.output} argument.}
  \item{output}{the value of the \code{output} argument.}
}
 
\details{
 Raju's area method (Raju, 1988, 1990) allows for detecting uniform or non-uniform differential item functioning 
 by setting an appropriate item response model. The input can be of two kinds: either by displaying the full data,
 the group membership and the model, or by giving the item parameter estimates (with the option \code{irtParam}).
 Both can be supplied, but in this case only the parameters in \code{irtParam} are used for computing Raju's statistic.

 By default, the Raju's \emph{Z} statistics are obtained by using the \emph{unsigned} areas between the ICCs. However, these
 statistics can also be computed using the \emph{signed} areas, by setting the argument \code{signed} to \code{TRUE} (default
 value is \code{FALSE}). See \code{\link{RajuZ}} for further details.

 The \code{Data} is a matrix whose rows correspond to the subjects and columns to the items. In addition, \code{Data} can hold the vector of group membership. 
 If so, \code{group} indicates the column of \code{Data} which corresponds to the group membership, either by specifying its name or by giving the column number.
 Otherwise, \code{group} must be a vector of same length as \code{nrow(Data)}.
 
 Missing values are allowed for item responses (not for group membership) but must be coded as \code{NA} values. They are discarded for item parameter estimation.

 The vector of group membership must hold only two different values, either as numeric or character. The focal group is defined by
 the value of the argument \code{focal.name}. 
 
 If the model is not the 1PL model, or if \code{engine} is equal to \code{"ltm"}, the selected IRT model is fitted using marginal maximum likelihood
 by means of the functions from the \code{ltm} package (Rizopoulos, 2006). Otherwise, the 1PL model is fitted as a generalized 
 linear mixed model, by means of the \code{glmer} function of the \code{lme4} package (Bates and Maechler, 2009).
 
 With the \code{"1PL"} model and the \code{"ltm"} engine, the common discrimination parameter is set equal to 1 by default. It is possible to fix another value
 through the argument\code{discr}. Alternatively, this common discrimination parameter can be estimated (though not returned) by fixing \code{discr} to 
 \code{NULL}.

 The 3PL model can be fitted either unconstrained (by setting \code{c} to \code{NULL}) or by fixing the pseudo-guessing values. In the latter 
 case, the argument \code{c} holds either a numeric vector of same length of the number of items, with one value per item pseudo-guessing parameter, 
 or a single value which is duplicated for all the items. If \code{c} is different from \code{NULL} then the 3PL model is always fitted (whatever the value of \code{model}).

 The \code{irtParam} matrix has a number of rows equal to twice the number of items in the data set. The first \emph{J} rows refer to 
 the item parameter estimates in the reference group, while the last \emph{J} ones correspond to the same items in the focal group. 
 The number of columns depends on the selected IRT model: 2 for the 1PL model, 5 for the 2PL model, 6 for the constrained 3PL model
 and 9 for the unconstrained 3PL model. The columns of \code{irtParam} have to follow the same structure as the output of
 \code{itemParEst} command (the latter can actually be used to create the \code{irtParam} matrix).

 In addition to the matrix of parameter estimates, one has to specify whether items in the focal group were rescaled to those of the 
 reference group. If not, rescaling is performed by equal means anchoring (Cook and Eignor, 1991). Argument \code{same.scale} is used for 
 this choice (default option is \code{TRUE} and assumes therefore that the parameters are already placed on the same scale).  

 The threshold (or cut-score) for classifying items as DIF is computed as the quantile of the standard normal distribution with lower-tail
 probability of 1-\code{alpha}/2.
 
 Item purification can be performed by setting \code{purify} to \code{TRUE}. In this case, the purification occurs in the equal means anchoring process. Items 
 detected as DIF are iteratively removed from the set of items used for equal means anchoring, and the procedure is repeated until either the same items
 are identified twice as functioning differently, or when \code{nrIter} iterations have been performed. In the latter case a warning message is printed.
 See Candell and Drasgow (1988) for further details.

Adjustment for multiple comparisons is possible with the argument \code{p.adjust.method}. The latter must be an acronym of one of the available adjustment methods of the \code{\link{p.adjust}} function. According to Kim and Oshima (2013), Holm and Benjamini-Hochberg adjustments (set respectively by \code{"Holm"} and \code{"BH"}) perform best for DIF purposes. See \code{\link{p.adjust}} function for further details. Note that item purification is performed on original statistics and p-values; in case of adjustment for multiple comparisons this is performed \emph{after} item purification.

A pre-specified set of anchor items can be provided through the \code{anchor} argument. It must be a vector of either item names (which must match exactly the column names of \code{Data} argument) or integer values (specifying the column numbers for item identification). In case anchor items are provided, they are used to rescale the item parameters on a common metric. None of the anchor items are tested for DIF: the output separates anchor items and tested items and DIF results are returned only for the latter. Note also that item purification is not activated when anchor items are provided (even if \code{purify} is set to \code{TRUE}). By default it is \code{NULL} so that no anchor item is specified. If item parameters are provided thorugh the \code{irtParam} argument and if they are on the same scale (i.e. if \code{same.scale} is \code{TRUE}), then anchor items are not used (even if they are specified).

 Under the 1PL model, the displayed output also proposes an effect size measure, which is -2.35 times the difference between item difficulties of the reference group
 and the focal group (Penfield and Camilli, 2007, p. 138). This effect size is similar Mantel-Haenszel's \eqn{\Delta_{MH}} effect size, and the ETS delta scale is used 
 to classify the effect sizes (Holland and Thayer, 1985).

 The output of the \code{difRaju}, as displayed by the \code{print.Raj} function, can be stored in a text file provided that \code{save.output} is set to \code{TRUE} 
 (the default value \code{FALSE} does not execute the storage). In this case, the name of the text file must be given as a character string into the first component
 of the \code{output} argument (default name is \code{"out"}), and the path for saving the text file can be given through the second component of \code{output}. The
 default value is \code{"default"}, meaning that the file will be saved in the current working directory. Any other path can be specified as a character string: see the 
 \bold{Examples} section for an illustration.

 The \code{plot.Raj} function displays the DIF statistics in a plot, with each item on the X axis. The type of point and the color are fixed by the usual \code{pch} and 
 \code{col} arguments. Option \code{number} permits to display the item numbers instead. Also, the plot can be stored in a figure file, either in PDF or JPEG format.
 Fixing \code{save.plot} to \code{TRUE} allows this process. The figure is defined through the components of \code{save.options}. The first two components perform similarly 
 as those of the \code{output} argument. The third component is the figure format, with allowed values \code{"pdf"} (default) for PDF file and \code{"jpeg"} for JPEG file.
}


\references{
 Bates, D. and Maechler, M. (2009). lme4: Linear mixed-effects models using S4 classes. R package version 0.999375-31. http://CRAN.R-project.org/package=lme4

 Candell, G.L. and Drasgow, F. (1988). An iterative procedure for linking metrics and assessing item bias in item response theory. \emph{Applied Psychological Measurement, 12}, 253--260. \doi{10.1177/014662168801200304} 

 Cook, L. L. and Eignor, D. R. (1991). An NCME instructional module on IRT equating methods. \emph{Educational Measurement: Issues and Practice, 10}, 37-45.

 Holland, P. W. and Thayer, D. T. (1985). An alternative definition of the ETS delta scale of item difficulty. \emph{Research Report RR-85-43}. Princeton, NJ:
 Educational Testing Service.
 
Kim, J., and Oshima, T. C. (2013). Effect of multiple testing adjustment in differential item functioning detection. \emph{Educational and Psychological Measurement, 73}, 458--470. \doi{10.1177/0013164412467033}

 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

 Penfield, R. D., and Camilli, G. (2007). Differential item functioning and item bias. In C. R. Rao and S. Sinharray (Eds.), \emph{Handbook of Statistics 26: Psychometrics}
 (pp. 125-167). Amsterdam, The Netherlands: Elsevier.

 Raju, N.S. (1988). The area between two item characteristic curves. \emph{Psychometrika, 53}, 495-502. \doi{10.1007/BF02294403}

 Raju, N. S. (1990). Determining the significance of estimated signed and unsigned areas between two item response functions. \emph{Applied Psychological Measurement, 14}, 197-207. \doi{10.1177/014662169001400208}
 
 Rizopoulos, D. (2006). ltm: An R package for latent variable modelling and item response theory analyses. \emph{Journal of Statistical Software, 17}, 1-25. \doi{10.18637/jss.v017.i05}
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
 \code{\link{RajuZ}}, \code{\link{itemParEst}}, \code{\link{dichoDif}}
 }

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)
 attach(verbal)

 # Excluding the "Anger" variable
 verbal<-verbal[colnames(verbal)!="Anger"]

 # Three equivalent settings of the data matrix and the group membership
 # (1PL model, "ltm" engine) 
 difRaju(verbal, group = 25, focal.name = 1, model = "1PL")
 difRaju(verbal, group = "Gender", focal.name = 1, model = "1PL")
 difRaju(verbal[,1:24], group = verbal[,25], focal.name = 1, model = "1PL")

 # Multiple comparisons adjustment using Benjamini-Hochberg method
 difRaju(verbal, group = 25, focal.name = 1, model = "1PL", p.adjust.method = "BH")

 # With signed areas
 difRaju(verbal, group = 25, focal.name = 1, model = "1PL", signed = TRUE)

 # With items 1 to 5 set as anchor items
 difRaju(verbal, group = 25, focal.name = 1, model = "1PL", anchor = 1:5)

 # (1PL model, "lme4" engine) 
 difRaju(verbal, group = "Gender", focal.name = 1, model = "1PL",
 engine = "lme4")

 # 2PL model, signed and unsigned areas
 difRaju(verbal, group = "Gender", focal.name = 1, model = "2PL")
 difRaju(verbal, group = "Gender", focal.name = 1, model = "2PL", signed = TRUE)

 # 3PL model with all pseudo-guessing parameters constrained to 0.05
 # Signed and unsigned areas
 difRaju(verbal, group = "Gender", focal.name = 1, model = "3PL", c = 0.05)
 difRaju(verbal, group = "Gender", focal.name = 1, model = "3PL", c = 0.05,
   signed = TRUE)
 
 # Same models, with item purification
 difRaju(verbal, group = "Gender", focal.name = 1, model = "1PL", purify = TRUE)
 difRaju(verbal, group = "Gender", focal.name = 1, model = "2PL", purify = TRUE)
 difRaju(verbal, group = "Gender", focal.name = 1, model = "3PL", c = 0.05,
 purify = TRUE)

 # With signed areas
 difRaju(verbal, group = "Gender", focal.name = 1, model = "1PL", purify = TRUE,
   signed = TRUE)
 difRaju(verbal, group = "Gender", focal.name = 1, model = "2PL", purify = TRUE,
   signed = TRUE)
 difRaju(verbal, group = "Gender", focal.name = 1, model = "3PL", c = 0.05,
 purify = TRUE, signed = TRUE)

 ## Splitting the data into reference and focal groups
 nF<-sum(Gender)
 nR<-nrow(verbal)-nF
 data.ref<-verbal[,1:24][order(Gender),][1:nR,]
 data.focal<-verbal[,1:24][order(Gender),][(nR+1):(nR+nF),]

 ## Pre-estimation of the item parameters (1PL model, "ltm" engine)
 item.1PL<-rbind(itemParEst(data.ref,model = "1PL"),
 itemParEst(data.focal,model = "1PL"))
 difRaju(irtParam = item.1PL,same.scale = FALSE)

 ## Pre-estimation of the item parameters (1PL model, "lme4" engine)
 item.1PL<-rbind(itemParEst(data.ref, model = "1PL", engine = "lme4"),
 itemParEst(data.focal, model = "1PL", engine = "lme4"))
 difRaju(irtParam = item.1PL, same.scale = FALSE)

 ## Pre-estimation of the item parameters (2PL model)
 item.2PL<-rbind(itemParEst(data.ref, model = "2PL"),
 itemParEst(data.focal, model = "2PL"))
 difRaju(irtParam = item.2PL, same.scale = FALSE)

 ## Pre-estimation of the item parameters (constrained 3PL model)
 item.3PL<-rbind(itemParEst(data.ref, model = "3PL", c = 0.05),
 itemParEst(data.focal, model = "3PL", c = 0.05))
 difRaju(irtParam = item.3PL, same.scale = FALSE)

 # Saving the output into the "RAJUresults.txt" file (and default path)
 r <- difRaju(verbal, group = 25, focal.name = 1, model = "1PL",
          save.output = TRUE, output = c("RAJUresults","default"))

 # Graphical devices
 plot(r)

 # Plotting results and saving it in a PDF figure
 plot(r, save.plot = TRUE, save.options = c("plot", "default", "pdf"))

 # Changing the path, JPEG figure
 path <- "c:/Program Files/"
 plot(r, save.plot = TRUE, save.options = c("plot", path, "jpeg"))
}
 }
