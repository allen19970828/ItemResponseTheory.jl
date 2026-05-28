\name{subtestLogistic}
\alias{subtestLogistic}
\alias{print.subLogistic}

\title{Testing for DIF among subgroups with generalized logistic regression}

\description{
 Performs the Wald test to identify DIF items among a subset of groups of examinees, using the results of generalized logistic regression for all groups. 
 }

\usage{
subtestLogistic(x, items, groups, alpha = 0.05)
\method{print}{subLogistic}(x, ...)
 }
 
\arguments{
 \item{x}{an object of class "genLogistic", typically the output of the \code{difGenLogistic} command.}
 \item{items}{numeric or character: a vector of items to be tested. See \bold{Details}.}
 \item{groups}{numeric or character: a vector of groups of examinees to be compared. See \bold{Details}.}
 \item{alpha}{numeric: the significance level (default is 0.05).}
 \item{...}{other generic parameters for the \code{print} function.}
}


\value{ 
 A list of class "subLogistic" with the following components:
 \item{stats}{a table with as many rows as tested items, and four columns: the item number, the Wald statistic, the degrees of freedom and the asymptotic 
              \emph{p}-value.}
 \item{contrastMatrix}{the contrast matrix used for testing DIF among the groups set up  by \code{groups}.}
 \item{items}{the value of the \code{items} argument.}
 \item{groups}{the value of the \code{groups} argument.}
 \item{type}{the value of the \code{x$type} argument.}
 \item{purification}{the value of the \code{x$purification} argument.}
 \item{alpha}{the value of the \code{alpha} argument.}
  }


\details{
 This command makes use of the results from the generalized logistic regression to perform subtests between two or more groups of examinees
 (Magis, Raiche, Beland and Gerard, 2010). The Wald test is used with an appropriate contrast matrix.

 The \code{subtestLogistic} command requires a preliminary output of the generalized logistic regression with all groups of examinees, preferable with the 
 \code{\link{difGenLogistic}} command. The object \code{x} is an object of class "genLogistic" from which subtests can be performed. The same DIF effect
 (either uniform, nonuniform, or both types) is tested among the subset of groups of examinees as the one tested with all groups. It is provided b y the 
 argument \code{type} argument of \code{x}. 

 The argument \code{items} is a vector of the names of the items to be tested, or their number in the data set. A single item can be specified.

 The argument \code{groups} specifies which groups of examinees are considered in this subtest routine. It is a vector of either group names or integer values.
 In the latter case, the reference group is specified with the 0 (zero) value, while the focal groups are set up by their rank in the \code{x$focal.names} argument.
 At least two groups must be specified, and all groups can be included (which leads back to the generalized logistic regression with the Wald test).

 The output provides, among others, the Wald statistics, the degrees of freedom and related asymptotic \emph{p}-values for each tested item, as well as the
 contrast matrix. 
 }
 
\references{
 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

 Magis, D., Raiche, G., Beland, S. and Gerard, P. (2011). A logistic regression procedure to detect differential item functioning among multiple groups. \emph{International Journal of Testing, 11}, 365--386. \doi{10.1080/15305058.2011.602810}
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
 \code{\link{difGenLogistic}}, \code{\link{genDichoDif}}
}

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)
 attach(verbal)

 # Creating four groups according to gender (0 or 1) and trait anger score
 # ("Low" or "High")
 # Reference group: women with low trait anger score (<=20)
 group <- rep("WomanLow",nrow(verbal))
 group[Anger>20 & Gender==0] <- "WomanHigh"
 group[Anger<=20 & Gender==1] <- "ManLow"
 group[Anger>20 & Gender==1] <- "ManHigh"

 # New data set
 Verbal <- cbind(verbal[,1:24], group)

 # Reference group: "WomanLow"
 names <- c("WomanHigh", "ManLow", "ManHigh")

 # Testing all types of DIF with all items
 rDIF <- difGenLogistic(Verbal, group = 25, focal.names = names)
 rUDIF <- difGenLogistic(Verbal, group = 25, focal.names = names, type = "udif")
 rNUDIF <- difGenLogistic(Verbal, group = 25, focal.names = names, type = "nudif")

 # Subtests between the reference group and the first two focal groups
 # for item "S2WantShout" (item 6) and the three types of DIF
 subGroups <- c("WomanLow", "WomanHigh", "ManLow")
 subtestLogistic(rDIF, items = 6, groups = subGroups)
 subtestLogistic(rUDIF, items = 6, groups = subGroups)
 subtestLogistic(rNUDIF, items = 6, groups = subGroups) 

 # Subtests between the reference group and the first focal group
 # for items "S2WantShout" (item 6) and "S3WantCurse" (item 7)
 # (only both DIF effects)
 subGroups <- c("WomanLow", "WomanHigh")
 items1 <- c("S2WantShout", "S3WantCurse")
 items2 <- 6:7
 subtestLogistic(rDIF, items = items1, groups = subGroups)
 subtestLogistic(rDIF, items = items2, groups = subGroups)
 }
 }
