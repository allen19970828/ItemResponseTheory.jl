\name{dichoDif}
\alias{dichoDif}
\alias{print.dichoDif}

\title{Comparison of DIF detection methods}

\description{
 This function compares the specified DIF detection methods with respect to the detected items and can only be used with dichotomous items. 
 }

\usage{
dichoDif(Data, group, focal.name, method, anchor = NULL, props = NULL, 
 	thrTID = 1.5, alpha = 0.05, MHstat = "MHChisq", correct = TRUE, 
 	exact = FALSE, stdWeight = "focal", thrSTD = 0.1, BDstat = "BD", 
 	member.type = "group", match = "score", type = "both", criterion = "LRT", 
 	model = "2PL", c = NULL, engine = "ltm", discr = 1, irtParam = NULL, 
 	same.scale = TRUE, signed = FALSE, purify = FALSE, purType = "IPP1",
 	nrIter = 10, extreme = "constraint", const.range = c(0.001, 0.999), 
 	nrAdd = 1, p.adjust.method = NULL, save.output = FALSE,
 	output = c("out", "default")) 
\method{print}{dichoDif}(x, ...)
 }
 
\arguments{
 \item{Data}{numeric: either the data matrix only, or the data matrix plus the vector of group membership. See \bold{Details}.}
 \item{group}{numeric or character: either the vector of group membership or the column indicator (within \code{Data}) of group membership. See \bold{Details}.}
 \item{focal.name}{numeric or character indicating the level of \code{group} which corresponds to the focal group.}
 \item{method}{character: the name of the selected method. Possible values are \code{"TID"}, \code{"MH"}, \code{"Std"}, \code{"Logistic"}, \code{"BD"}, \code{"SIBTEST"}, \code{"Lord"}, \code{"Raju"} and \code{"LRT"}. See \bold{Details}.}
\item{anchor}{either \code{NULL} (default) or a vector of item names (or identifiers) to specify the anchor items. See \bold{Details}.}
 \item{props}{either \code{NULL} (default) or a two-column matrix with proportions of success in the reference group and the focal group. See \bold{Details}.}
 \item{thrTID}{numeric: the threshold for detecting DIF items with TID method (default is 1.5).}
 \item{alpha}{numeric: significance level (default is 0.05).}
 \item{MHstat}{character: specifies the DIF statistic to be used for DIF identification. Possible values are \code{"MHChisq"} (default) and \code{"logOR"}. See \bold{Details}.}
 \item{correct}{logical: should the Mantel-Haenszel continuity correction be used? (default is TRUE).}
 \item{exact}{logical: should an exact test be computed? (default is \code{FALSE}).}
 \item{stdWeight}{character: the type of weights used for the standardized P-DIF statistic. Possible values are \code{"focal"} (default), \code{"reference"} and \code{"total"}. See \bold{Details}.}
 \item{thrSTD}{numeric: the threshold (cut-score) for standardized P-DIF statistic (default is 0.10).}
 \item{BDstat}{character specifying the DIF statistic to be used. Possible values are \code{"BD"} (default) and \code{"trend"}. See \bold{Details}.}
 \item{member.type}{character: either \code{"group"} (default) to specify that group membership is made of two groups, or \code{"cont"} to indicate that group membership is based on a  continuous criterion. See \bold{Details}.}
 \item{match}{specifies the type of matching criterion. Can be either \code{"score"} (default) to compute the test score, or any continuous or discrete variable with the same length as the number of rows of \code{Data}. See \bold{Details}.}
 \item{type}{a character string specifying which DIF effects must be tested. Possible values are \code{"both"} (default), \code{"udif"} and \code{"nudif"}. See \bold{Details}.}
 \item{criterion}{a character string specifying which DIF statistic is computed. Possible values are \code{"LRT"} (default) or \code{"Wald"}. See \bold{Details}.}
 \item{model}{character: the IRT model to be fitted (either \code{"1PL"}, \code{"2PL"} or \code{"3PL"}). Default is \code{"2PL"}.}
 \item{c}{optional numeric value or vector giving the values of the constrained pseudo-guessing parameters. See \bold{Details}.}
 \item{engine}{character: the engine for estimating the 1PL model, either \code{"ltm"} (default) or \code{"lme4"}.}
 \item{discr}{either \code{NULL} or a real positive value for the common discrimination parameter (default is 1). Used onlky if \code{model} is \code{"1PL"} and \code{engine} is \code{"ltm"}. See \bold{Details}.}
 \item{irtParam}{matrix with \emph{2J} rows (where \emph{J} is the number of items) and at most 9 columns containing item parameters estimates. See \bold{Details}.}
 \item{same.scale}{logical: are the item parameters of the \code{irtParam} matrix on the same scale? (default is "TRUE"). See \bold{Details}.}
 \item{signed}{logical: should the Raju's statistics be computed using the signed (\code{TRUE}) or unsigned (\code{FALSE}, default) area? See \bold{Details}.}
 \item{purify}{logical: should the method be used iteratively to purify the set of anchor items? (default is FALSE).}
 \item{purType}{character: the type of purification process to be run. Possible values are \code{"IPP1"} (default), \code{"IPP2"} and \code{"IPP3"}. Ignored if \code{purify} is \code{FALSE} or \code{method} does not supply the \code{"TID"} method.}
 \item{nrIter}{numeric: the maximal number of iterations in the item purification process (default is 10).}
 \item{extreme}{character: the method used to modify the extreme proportions. Possible values are \code{"constraint"} (default) or \code{"add"}. Ignored if \code{method} is not \code{"TID"}.}
 \item{const.range}{numeric: a vector of two constraining proportions. Default values are 0.001 and 0.999. Ignored if \code{method} is not \code{"TID"} or if \code{extreme} is \code{"add"}.}
 \item{nrAdd}{integer: the number of successes and the number of failures to add to the data in order to adjust the proportions. Default value is 1. Ignored if \code{method} is not \code{"TID"} or if \code{extreme} is \code{"constraint"}.}
\item{p.adjust.method}{either \code{NULL} (default) or the acronym of the method for p-value adjustment for multiple comparisons. See \bold{Details}.}
 \item{save.output}{logical: should the output be saved into a text file? (Default is \code{FALSE}).}
 \item{output}{character: a vector of two components. The first component is the name of the output file, the second component is either the file path or \code{"default"} (default value). See \bold{Details}.}
 \item{x}{result from a \code{dichoDif} class object.}
 \item{...}{other generic parameters for the \code{print} function.}
}

\value{
Either the output of one of the DIF detection methods, or a list of class "dichoDif" with the following arguments:
  \item{DIF}{a character matrix with one row per item and whose columns refer to the different specified detection methods. See \bold{Details}.}
  \item{props}{the value of the \code{props} argument.}
  \item{thrTID}{the value of the \code{thrTID} argument.}
  \item{correct}{the value of \code{correct} argument.}
  \item{exact}{the value of \code{exact} argument.}
  \item{alpha}{the significance level \code{alpha}.}
  \item{MHstat}{the value of the \code{MHstat} argument.}
  \item{stdWeight}{the value of the \code{stdWeight} argument.}
  \item{thrSTD}{the value of \code{thrSTD} argument.}
  \item{BDstat}{the value of the \code{BDstat} argument.}
  \item{member.type}{the value of the \code{member.type} argument.}
  \item{match}{the value of the \code{match} argument.}
  \item{type}{the value of the \code{type} argument.}
  \item{criterion}{the value of the \code{criterion} argument.}
  \item{model}{the value of \code{model} argument.}
  \item{c}{the value of \code{c} argument.}
  \item{engine}{The value of the \code{engine} argument.}
  \item{discr}{the value of the \code{discr} argument.}
  \item{irtParam}{the value of \code{irtParam} argument.}
  \item{same.scale}{the value of \code{same.scale} argument.}
  \item{p.adjust.method}{the value of the \code{p.adjust.method} argument.}
\item{purification}{the value of \code{purify} argument.} 
  \item{nrPur}{an integer vector (of length equal to the number of methods) with the number of iterations in the purification process. 
   Returned only if \code{purify} is TRUE.}
  \item{convergence}{a logical vector (of length equal to the number of methods) indicating whether the iterative purification process converged. Returned only if \code{purify} is TRUE.}
 \item{anchor.names}{the value of the \code{anchor} argument.}
  \item{save.output}{the value of the \code{save.output} argument.}
  \item{output}{the value of the \code{output} argument.}
 }

\details{
 \code{dichoDif} is a generic function which calls one or several DIF detection methods and summarize their output. The possible methods are: 
\enumerate{
\item{\code{"TID"} for Transformed Item Difficulties (TID) method (Angoff and Ford, 1973),}
\item{\code{"MH"} for mantel-Haenszel (Holland and Thayer, 1988),}
\item{\code{"Std"} for standardization (Dorans and Kulick, 1986),}
\item{\code{"BD"} for Breslow-Day method (Penfield, 2003),}
\item{\code{"Logistic"} for logistic regression (Swaminathan and Rogers, 1990),}
\item{\code{"SIBTEST"} for SIBTEST (Shealy and Stout) and Crossing-SIBTEST (Chalmers, 2018; Li and Stout, 1996) methods,}
\item{\code{"Lord"} for Lord's chi-square test (Lord, 1980),} 
\item{\code{"Raju"} for Raju's area method (Raju, 1990), and}
\item{\code{"LRT"} for likelihood-ratio test method (Thissen, Steinberg and Wainer, 1988).}
}

 If \code{method} has a single component, the output of \code{dichoDif} is exactly the one provided by the method itself. Otherwise, the main  output is a matrix with one row per item and one column per method. For each specified method and related arguments, items detected as DIF and non-DIF are respectively encoded as \code{"DIF"} and \code{"NoDIF"}. When printing the output an additional column is added, counting the number of times each item was detected as functioning
differently (Note: this is just an informative summary, since the methods are obviously not independent for the detection of DIF items).

 The \code{Data} is a matrix whose rows correspond to the subjects and columns to the items. In addition, \code{Data} can hold the vector of group membership. If so, \code{group} indicates the column of \code{Data} which corresponds to the group membership, either by specifying its name or by giving the column number. Otherwise, \code{group} must be a vector of same length as \code{nrow(Data)}.
 
 Missing values are allowed for item responses (not for group membership) but must be coded as \code{NA} values. They are discarded from either the computation of the sum-scores, the fitting of the logistic models or the IRT models (according to the method).

 The vector of group membership must hold only two different values, either as numeric or character. The focal group is defined by the value of the argument \code{focal.name}. 

For \code{"MH"}, \code{"Std"}, \code{"Logistic"} and \code{"BD"} methods, the matching criterion can be either the test score or any other continuous or discrete variable to be passed in the \code{Logistik} function. This is specified by the \code{match} argument. By default, it takes the value \code{"score"} and the test score (i.e. raw score) is computed. The second option is to assign to \code{match} a vector of continuous or discrete numeric values, which acts as the matching criterion. Note that for consistency this vector should not belong to the \code{Data} matrix. 

 For Lord and Raju methods, one can specify either the IRT model to be fitted (by means of \code{model}, \code{c}, \code{engine} and \code{discr} arguments), or the item parameter estimates with arguments \code{irtParam} and \code{same.scale}. See \code{\link{difLord}} and \code{\link{difRaju}} for further details. 

 The threshold for detecting DIF items depends on the method. For standardization it has to be fully specified (with the \code{thr} argument), as well as for the TID method (through the \code{thrTID} argument). For the other methods it is depending on the significance level set by \code{alpha}.

 For Mantel-Haenszel method, the DIF statistic can be either the Mantel-Haenszel chi-square statistic or the log odds-ratio statistic. The method is specified by the argument \code{MHstat}, and the default value is \code{"MHChisq"} for the chi-square statistic. Moreover, the option \code{correct}
specifies whether the continuity correction has to be applied to Mantel-Haenszel statistic. See \code{\link{difMH}} for further details.

 By default, the asymptotic Mantel-Haenszel statistic is computed. However, the exact statistics and related P-values can be obtained by specifying the logical argument \code{exact} to \code{TRUE}. See Agresti (1990, 1992) for further details about exact inference.

 The weights for computing the standardized P-DIF statistics are defined through the argument \code{stdWeight}, with possible values \code{"focal"} (default value), \code{"reference"} and \code{"total"}. See \code{\link{stdPDIF}} for further details. 

 For Breslow-Day method, two test statistics are available: the usual Breslow-Day statistic for testing homogeneous association (Aguerri, Galibert, Attorresi and Maranon, 2009) and the trend test statistic for assessing some monotonic trend in the odss ratios (Penfield, 2003). The DIF statistic is supplied by the \code{BDstat} argument, with values \code{"BD"} (default) for the usual statistic and \code{"trend"} for the trend test statistic.

 For logistic regression, the argument \code{type} permits to test either both uniform and nonuniform effects simultaneously (\code{type="both"}), only uniform DIF effect (\code{type="udif"}) or only nonuniform DIF effect (\code{type="nudif"}). The \code{criterion} argument specifies the DIF statistic to be computed, either the likelihood ratio test statistic (by setting \code{criterion="LRT"}) or the Wald test (by setting \code{criterion="Wald"}). Moreover, the group membership can be either a vector of two distinct values, one for the reference group and one for the focal group, or a continuous or discrete variable that acts as the "group" membership variable. In the former case, the \code{member.type} argument is set to \code{"group"} and the \code{focal.name} defines which value in the \code{group} variable stands for the focal group. In the latter case, \code{member.type} is set to \code{"cont"}, \code{focal.name} is ignored and each value of the \code{group} represents one "group" of data (that is, the DIF effects are investigated among participants relying on different values of some discrete or continuous trait). See \code{\link{Logistik}} for further details.

 The SIBTEST method (Shealy and Stout, 1993) and its modified version, the Crossing-SIBTEST (Chalmers, 2018; Li and Stout, 1996) are returned by the \code{\link{difSIBTEST}} function. SIBTEST method is returned when \code{type} argument is set to \code{"udif"}, while Crossing-SIBTEST is set with \code{"nudif"} value for the \code{type} argument. Note that \code{type} takes the by-default value \code{"both"} which is not allowed within the \code{\link{difSIBTEST}} function; however, within this fucntion, keeping the by-default value yields selection of Crossing-SIBTEST.

The \code{\link{difSIBTEST}} function is a wrapper to the \code{\link[mirt]{SIBTEST}} function from the \bold{mirt} package (Chalmers, 2012) to fit within the \code{difR} framework (Magis et al., 2010). Therefore, if you are using this function for publication purposes please cite Chalmers (2018; 2012) and Magis et al. (2010).

 For Raju's method, the type of area (signed or unsigned) is fixed by the logical \code{signed} argument, with default value \code{FALSE} (i.e. unsigned areas). See \code{\link{RajuZ}} for further details.

 Item purification can be requested by specifying \code{purify} option to \code{TRUE}. Recall that item purification process is slightly different for IRT and for non-IRT based methods. See the corresponding methods for further information.

Adjustment for multiple comparisons is possible with the argument \code{p.adjust.method}. See the corresponding methods for further information.

A pre-specified set of anchor items can be provided through the \code{anchor} argument. For non-IRT methods, anchor items are used to compute the test score (as matching criterion). For IRT methods, anchor items are used to rescale the item parameters on a common metric. See the corresponding methods for further information. Note that \code{anchor} argument is not working with \code{"LRT"} method.

 The output of the \code{dichoDif} function can be stored in a text file by fixing \code{save.output} and \code{output} appropriately. See the help file of \code{\link{selectDif}} function (or any other DIF method) for further information.
}
 
\references{
 Agresti, A. (1990). \emph{Categorical data analysis}. New York: Wiley.

 Agresti, A. (1992). A survey of exact inference for contingency tables. \emph{Statistical Science, 7}, 131-177. \doi{10.1214/ss/1177011454}

 Aguerri, M.E., Galibert, M.S., Attorresi, H.F. and Maranon, P.P. (2009). Erroneous detection of nonuniform DIF using the Breslow-Day test in a short test. \emph{Quality and Quantity, 43}, 35-44. \doi{10.1007/s11135-007-9130-2}

 Angoff, W. H., and Ford, S. F. (1973). Item-race interaction on a test of scholastic aptitude. \emph{Journal of Educational Measurement, 2}, 95-106. \doi{10.1111/j.1745-3984.1973.tb00787.x}

Chalmers, R. P. (2012). mirt: A Multidimensional item response
  theory package for the R environment. \emph{Journal of Statistical Software, 48(6)}, 1-29. \doi{10.18637/jss.v048.i06}

Chalmers, R. P. (2018). Improving the Crossing-SIBTEST statistic for detecting non-uniform DIF. \emph{Psychometrika, 83}(2), 376--386. \doi{10.1007/s11336-017-9583-8}

 Dorans, N. J. and Kulick, E. (1986). Demonstrating the utility of the standardization approach to assessing unexpected differential item performance on the 
 Scholastic Aptitude Test. \emph{Journal of Educational Measurement, 23}, 355-368. \doi{10.1111/j.1745-3984.1986.tb00255.x}

 Holland, P. W. and Thayer, D. T. (1988). Differential item performance and the Mantel-Haenszel procedure. In H. Wainer and H. I. Braun (Dirs.), \emph{Test 
 validity}. Hillsdale, NJ: Lawrence Erlbaum Associates.

Li, H.-H., and Stout, W. (1996). A new procedure for detection of crossing DIF. \emph{Psychometrika, 61}, 647--677. \doi{10.1007/BF02294041}

 Lord, F. (1980). \emph{Applications of item response theory to practical testing problems}. Hillsdale, NJ: Lawrence Erlbaum Associates.

 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

 Penfield, R.D. (2003). Application of the Breslow-Day test of trend in odds ratio heterogeneity to the detection of nonuniform DIF. \emph{Alberta Journal of 
 Educational Research, 49}, 231-243.

 Raju, N. S. (1990). Determining the significance of estimated signed and unsigned areas between two item response functions. \emph{Applied Psychological Measurement, 14}, 197-207. \doi{10.1177/014662169001400208}
 
Shealy, R. and Stout, W. (1993). A model-based standardization approach that separates true bias/DIF from group ability differences and detect test bias/DTF as well as item bias/DIF. \emph{Psychometrika, 58}, 159-194. \doi{10.1007/BF02294572}

 Swaminathan, H. and Rogers, H. J. (1990). Detecting differential item functioning using logistic regression procedures. \emph{Journal of Educational 
 Measurement, 27}, 361-370. \doi{10.1111/j.1745-3984.1990.tb00754.x}

 Thissen, D., Steinberg, L. and Wainer, H. (1988). Use of item response theory in the study of group difference in trace lines. In H. Wainer and H. Braun (Eds.), 
 \emph{Test validity}. Hillsdale, NJ: Lawrence Erlbaum Associates.
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
 \code{\link{difTID}}, \code{\link{difMH}}, \code{\link{difStd}}, \code{\link{difBD}}, \code{\link{difLogistic}}, \code{\link{difSIBTEST}}, \code{\link{difLord}}, \code{\link{difRaju}},
 \code{\link{difLRT}}
 }

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)
 attach(verbal)

 # Excluding the "Anger" variable
 verbal <- verbal[colnames(verbal)!="Anger"]

 # Comparing TID, Mantel-Haenszel, standardization; logistic regression and SIBTEST
 # TID threshold 1.0
 # Standardization threshold 0.08
 # no continuity correction,
 # with item purification
 # both types of DIF effect for logistic regression
 # CSIBTEST method 
 dichoDif(verbal, group = 25, focal.name = 1, method = c("TID", "MH", "Std",
          "Logistic", "SIBTEST"), correct = FALSE, thrSTD = 0.08, thrTID = 1, purify = TRUE)

 # Same analysis, but using items 1 to 5 as anchor and saving the output into 
 # the 'dicho' file 
 dichoDif(verbal, group = 25, focal.name = 1, method = c("TID", "MH", "Std",
          "Logistic"), correct = FALSE, thrSTD = 0.08, thrTID = 1, purify = TRUE, 
          anchor = 1:5,save.output = TRUE, output = c("dicho", "default"))

 # Comparing Lord and Raju results with 2PL model and
 # with item purification 
 dichoDif(verbal, group = 25, focal.name = 1, method = c("Lord", "Raju"),
          model = "2PL", purify = TRUE)
}
 }
