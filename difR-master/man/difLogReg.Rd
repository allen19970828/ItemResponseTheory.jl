\name{difLogReg}
\alias{difLogReg}

\title{General logistic regression DIF method}

\description{
  Performs DIF detection using logistic regression method with either two groups, more than two groups, or a continuous group variable.
 }

\usage{
difLogReg(Data, group, focal.name, anchor = NULL, group.type = "group", 
 	match = "score", type = "both", criterion = "LRT", alpha = 0.05, 
 	purify = FALSE, nrIter = 10, p.adjust.method = NULL, save.output = FALSE, 
 	output = c("out", "default"))
 }
 
\arguments{
 \item{Data}{numeric: either the data matrix only, or the data matrix plus the vector of group membership. See \bold{Details}.}
 \item{group}{numeric or character: either the vector of group membership or the column indicator (within \code{data}) of group membership. See \bold{Details}.}
 \item{focal.name}{numeric or character indicating the level(s) of \code{group} which corresponds to the focal group(s). Ignored if \code{group.type} is not \code{"group"}.}
\item{anchor}{either \code{NULL} (default) or a vector of item names (or identifiers) to specify the anchor items. See \bold{Details}.}
 \item{group.type}{character: either \code{"group"} (default) to specify that group membership is made of two (or more than two) groups, or \code{"cont"} to indicate that group membership is based on a  continuous criterion. See \bold{Details}.}
 \item{match}{specifies the type of matching criterion. Can be either \code{"score"} (default) to compute the test score, or any continuous or discrete variable with the same length as the number of rows of \code{Data}. See \bold{Details}.}
 \item{type}{a character string specifying which DIF effects must be tested. Possible values are \code{"both"} (default), \code{"udif"} and \code{"nudif"}. See \bold{Details}.}
 \item{criterion}{a character string specifying which DIF statistic is computed. Possible values are \code{"LRT"} (default) or \code{"Wald"}. See \bold{Details}.}
 \item{alpha}{numeric: significance level (default is 0.05).}
 \item{purify}{logical: should the method be used iteratively to purify the set of anchor items? (default is FALSE). Ignored if \code{match} is not \code{"score"}.}
 \item{nrIter}{numeric: the maximal number of iterations in the item purification process. (default is 10).}
 \item{p.adjust.method}{either \code{NULL} (default) or the acronym of the method for p-value adjustment for multiple comparisons. See \bold{Details}.}
\item{save.output}{logical: should the output be saved into a text file? (Default is \code{FALSE}).}
 \item{output}{character: a vector of two components. The first component is the name of the output file, the second component is either the file path or 
               \code{"default"} (default value). See \bold{Details}.}
}


\value{
A list of class "Logistic" (if \code{group.type} is \code{"cont"} or with the length of \code{focal.name} is one) or "genLogistic", with related arguments (see \code{\link{difLogistic}} and \code{\link{difGenLogistic}}). 
 }


\details{
 The \code{difLogReg} function is a meta-function for logistic regression DIF analysis. It encompasses all possible cases that are currently implemented in difR and makes appropriate calls to the function \code{\link{difLogistic}} or \code{\link{difGenLogistic}}. 

Three situations are embedded in this function.
\enumerate{
\item The group membership is defined by two distinct groups. In this case, \code{group.type} must be \code{"group"} and \code{focal.name} must be a single value, referring to the name or label of the focal group.
\item The group membership is defined by a finite, yet larger than two, number of groups.  In this case, \code{group.type} must be \code{"group"} and \code{focal.name} must be a vector with the names or labels of all focal groups.
\item The group membership is a continuous or discrete (but treated as continuous) variable. In this case, DIF is tested with respect to this "membership" variable. Furthermore, \code{group.type} must be \code{"cont"} and \code{focal.name} is ignored (though some value must be specified, for instance \code{NULL}). 
}
The specification of the data, the options for item purification, DIF statistic selection, and output saving, are identical to the options arising from the \code{\link{difLogistic}} and \code{\link{difGenLogistic}} functions. 
}

\references{
 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

 Swaminathan, H. and Rogers, H. J. (1990). Detecting differential item functioning using logistic regression procedures. \emph{Journal of Educational 
 Measurement, 27}, 361-370. \doi{10.1111/j.1745-3984.1990.tb00754.x}
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
 \code{\link{difLogistic}}, \code{\link{difGenLogistic}}, \code{\link{dichoDif}},  \code{\link{genDichoDif}}
}

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)
 attach(verbal)

 # Few examples
 difLogReg(Data=verbal[,1:24], group=verbal[,26], focal.name=1)
 difLogReg(Data = verbal[,1:24], group = verbal[,26], focal.name = 1, match = verbal[,25])
 difLogReg(Data = verbal[,1:24], group = verbal[,25], focal.name = 1, group.type = "cont")

 group<-rep("WomanLow",nrow(verbal))
 group[Anger>20 & Gender==0] <- "WomanHigh"
 group[Anger<=20 & Gender==1] <- "ManLow"
 group[Anger>20 & Gender==1] <- "ManHigh"
 names <- c("WomanHigh", "ManLow", "ManHigh")

 difLogReg(Data = verbal[,1:24], group = group, focal.name = names)
 }
 }
