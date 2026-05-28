\name{genDichoDif}
\alias{genDichoDif}
\alias{print.genDichoDif}

\title{Comparison of DIF detection methods among multiple groups}

\description{
 This function compares the specified DIF detection methods among multiple 
 groups, with respect to the detected items. 
 }

\usage{
genDichoDif(Data, group, focal.names, method, anchor = NULL, match = "score", 
 	type = "both", criterion = "LRT", alpha = 0.05, model = "2PL", c = NULL, 
 	engine = "ltm", discr = 1, irtParam = NULL, nrFocal = 2, same.scale = TRUE, 
 	purify = FALSE, nrIter = 10, p.adjust.method = NULL, save.output = FALSE, 
 	output = c("out", "default")) 
\method{print}{genDichoDif}(x, ...)
 }
 
\arguments{
 \item{Data}{numeric: either the data matrix only, or the data matrix plus the vector of group membership. See \bold{Details}.}
 \item{group}{numeric or character: either the vector of group membership or the column indicator (within data) of group membership. See \bold{Details}.}
 \item{focal.names}{numeric or character vector indicating the levels of \code{group} which correspond to the focal groups.}
 \item{method}{character: the name of the selected methods. See \bold{Details}.}
\item{anchor}{either \code{NULL} (default) or a vector of item names (or identifiers) to specify the anchor items. See \bold{Details}.}
 \item{match}{specifies the type of matching criterion. Can be either \code{"score"} (default) to compute the test score, or any continuous or discrete variable with the same length as the number of rows of \code{Data}. See \bold{Details}.}
 \item{type}{a character string specifying which DIF effects must be tested (default is \code{"both"}). See \bold{Details}.}
 \item{criterion}{character: the type of test statistic used to detect DIF items with generalized logistic regression. Possible values are \code{"LRT"} (default) and \code{"Wald"}. See \bold{Details}.}
 \item{alpha}{numeric: significance level (default is 0.05).}
 \item{model}{character: the IRT model to be fitted (either \code{"1PL"}, \code{"2PL"} or \code{"3PL"}). Default is \code{"2PL"}.}
 \item{c}{optional numeric value or vector giving the values of the constrained pseudo-guessing parameters. See \bold{Details}.}
 \item{engine}{character: the engine for estimating the 1PL model, either \code{"ltm"} (default) or \code{"lme4"}.}
 \item{discr}{either \code{NULL} or a real positive value for the common discrimination parameter (default is 1). Used onlky if \code{model} is \code{"1PL"} and \code{engine} is \code{"ltm"}. See \bold{Details}.}
 \item{irtParam}{matrix with \emph{2J} rows (where \emph{J} is the number of items) and at most 9 columns containing item parameters estimates. See \bold{Details}.}
 \item{nrFocal}{numeric: the number of focal groups (default is 2).}
 \item{same.scale}{logical: are the item parameters of the \code{irtParam} matrix on the same scale? (default is "TRUE"). See \bold{Details}.}
 \item{purify}{logical: should the method be used iteratively to purify the set of anchor items? (default is FALSE).}
 \item{nrIter}{numeric: the maximal number of iterations in the item purification process (default is 10).} 
\item{p.adjust.method}{either \code{NULL} (default) or the acronym of the method for p-value adjustment for multiple comparisons. See \bold{Details}.}
 \item{save.output}{logical: should the output be saved into a text file? (Default is \code{FALSE}).}
 \item{output}{character: a vector of two components. The first component is the name of the output file, the second component is either the file path or \code{"default"} (default value). See \bold{Details}.}
 \item{x}{result from a \code{genDichoDif} class object.}
 \item{...}{other generic parameters for the \code{print} function.}
}

\value{
Either the output of one of the DIF detection methods, or a list of class "genDichoDif" with the following arguments:
  \item{DIF}{a character matrix with one row per item and whose columns refer to the different specified detection methods. See \bold{Details}.}
  \item{alpha}{the significance level \code{alpha}.}
  \item{method}{the value of \code{method}argument.}
  \item{match}{the value of \code{match} argument.} 
  \item{type}{the value of \code{type} argument.}  
  \item{criterion}{the value of the \code{criterion} argument.}
  \item{model}{the value of \code{model} option.}
  \item{c}{the value of \code{c} option.}
  \item{engine}{The value of the \code{engine} argument.}
  \item{discr}{the value of the \code{discr} argument.}
  \item{irtParam}{the value of \code{irtParam} option.}
  \item{same.scale}{the value of \code{same.scale} option.}
   \item{p.adjust.method}{the value of the \code{p.adjust.method} argument.}
\item{purification}{the value of \code{purify} option.} 
  \item{nrPur}{an integer vector (of length equal to the number of methods) with the number of iterations in the purification process. Returned only if \code{purify} is TRUE.}
  \item{convergence}{a logical vector (of length equal to the number of methods) indicating whether the iterative purification process converged. Returned only if \code{purify} is TRUE.}
 \item{anchor.names}{the value of the \code{anchor} argument.}
  \item{save.output}{the value of the \code{save.output} argument.}
  \item{output}{the value of the \code{output} argument.}
 }

\details{
 \code{genDichoDif} is a generic function which calls one or several DIF detection methods among multiple groups, and summarize their output. The possible methods are: \code{"GMH"} for Generalized Mantel-Haenszel (Penfield, 2001), \code{"genLogistic"} for generalized logistic regression (Magis, Raiche Beland and Gerard, 2011) and \code{"genLord"} for generalized Lord's chi-square test (Kim, Cohen and Park, 1995).

 If \code{method} has a single component, the output of \code{genDichoDif} is exactly the one provided by the method itself. Otherwise, the main  output is a matrix with one row per item and one column per method. For each specified method and related arguments, items detected as DIF and non-DIF are respectively encoded as \code{"DIF"} and \code{"NoDIF"}. When printing the output an additional column is added, counting the number of times each item was detected as functioning differently (Note: this is just an informative summary, since the methods are obviously not independent for the detection of DIF items).

 The \code{Data} is a matrix whose rows correspond to the subjects and columns to the items. In addition, \code{Data} can hold the vector of group membership. If so, \code{group} indicates the column of \code{Data} which corresponds to the group membership, either by specifying its name or by giving the column number. Otherwise, \code{group} must be a vector of same length as \code{nrow(Data)}.
 
 Missing values are allowed for item responses (not for group membership) but must be coded as \code{NA} values. They are discarded from either the computation of the sum-scores, the fitting of the logistic models or the IRT models (according to the method).

 The vector of group membership must hold at least three different values, either as numeric or character. The focal groups are defined by the values of the argument \code{focal.names}. 

For generalized Mantel-Haenszel and generalized logistic methods, the matching criterion can be either the test score or any other continuous or discrete variable to be passed in the DIF function. This is specified by the \code{match} argument. By default, it takes the value \code{"score"} and the test score (i.e. raw score) is computed. The second option is to assign to \code{match} a vector of continuous or discrete numeric values, which acts as the matching criterion. Note that for consistency this vector should not belong to the \code{Data} matrix. 

 For the generalized logistic regression method, the argument \code{type} permits to test either both uniform and nonuniform effects simultaneously (with \code{type="both"}), only uniform DIF effect (with \code{type="udif"}) or only nonuniform DIF effect (with \code{type="nudif"}). Furthermore, the argument \code{criterion} defines which test must be used, either the Wald test (\code{"Wald"}) or the likelihood ratio test (\code{"LRT"}). See \code{\link{difGenLord}} for further details. 

 For generalized Lord method, one can specify either the IRT model to be fitted (by means of \code{model}, \code{c}, \code{engine} and \code{discr} arguments), or the item parameter estimates with arguments \code{irtParam} and \code{same.scale}. See \code{\link{difGenLord}} for further details. 

 The threshold for detecting DIF items depends on the method and is depending on the significance level set by \code{alpha}.

 Item purification can be requested by specifying \code{purify} option to \code{TRUE}. Recall that item purification process is slightly different for IRT and for non-IRT based methods. See the corresponding methods for further information.

Adjustment for multiple comparisons is possible with the argument \code{p.adjust.method}. See the corresponding methods for further information.

A pre-specified set of anchor items can be provided through the \code{anchor} argument. For non-IRT methods, anchor items are used to compute the test score (as matching criterion). For IRT methods, anchor items are used to rescale the item parameters on a common metric. See the corresponding methods for further information. 

 The output of the \code{genDichoDif} function can be stored in a text file by fixing \code{save.output} and \code{output} appropriately. See the help file of \code{\link{selectGenDif}} function (or any other DIF method) for further information.
}
 
\references{
 Kim, S.-H., Cohen, A.S. and Park, T.-H. (1995). Detection of differential item functioning in multiple groups. \emph{Journal of Educational Measurement, 32}, 261-276. \doi{10.1111/j.1745-3984.1995.tb00466.x}
 
 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

 Magis, D., Raiche, G., Beland, S. and Gerard, P. (2011). A logistic regression procedure to detect differential item functioning among multiple groups. \emph{International Journal of Testing, 11}, 365--386. \doi{10.1080/15305058.2011.602810}

 Penfield, R. D. (2001). Assessing differential item functioning among multiple groups: a comparison of three Mantel-Haenszel procedures. \emph{Applied Measurement in Education, 14}, 235-259. \doi{10.1207/S15324818AME1403_3}
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
 \code{\link{difGMH}}, \code{\link{difGenLogistic}}, \code{\link{difGenLord}}
 }

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)
 attach(verbal)

 # Creating four groups according to gender ("Man" or "Woman") and trait 
 # anger score ("Low" or "High")
 group <- rep("WomanLow", nrow(verbal))
 group[Anger>20 & Gender==0] <- "WomanHigh"
 group[Anger<=20 & Gender==1] <- "ManLow"
 group[Anger>20 & Gender==1] <- "ManHigh"

 # New data set
 Verbal <- cbind(verbal[,1:24], group)

 # Reference group: "WomanLow"
 names <- c("WomanHigh", "ManLow", "ManHigh")

 # Comparing the three available methods
 # with item purification 
 genDichoDif(Verbal, group = 25, focal.names = names, method = c("GMH", "genLogistic",
             "genLord"), purify = TRUE)
   
 # Same analysis, but saving the output into the 'genDicho' file
 genDichoDif(Verbal, group = 25, focal.names = names, method = c("GMH", "genLogistic", 
             "genLord"), purify = TRUE, save.output = TRUE, 
             output = c("genDicho", "default"))
}
}
