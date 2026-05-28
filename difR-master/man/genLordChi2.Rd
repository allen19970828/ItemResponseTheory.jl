\name{genLordChi2}
\alias{genLordChi2}

\title{Generalized Lord's chi-squared DIF statistic}

\description{
 Calculates the generalized Lord's chi-squared statistics for DIF detection among multiple groups. 
 }

\usage{
genLordChi2(irtParam, nrFocal)
 }

\arguments{
 \item{irtParam}{numeric: the matrix of item parameter estimates. See \bold{Details}.}
 \item{nrFocal}{numeric: the number of focal groups.}
}

\value{
 A vector with the values of the generalized Lord's chi-squared DIF statistics.
 }
 
\details{
 This command computes the generalized Lord's chi-squared statistic (Kim, Cohen and Park, 1995), also called the \emph{Qj} 
 statistics, in the specific framework of differential item functioning with multiple groups. It forms the basic command 
 of \code{\link{difGenLord}} and is specifically designed for this call.

 The \code{irtParam} matrix has a number of rows equal to the number of groups (reference and focal ones) times the number of items \emph{J}. The first \emph{J} 
 rows refer to the item parameter estimates in the reference group, while the next sets of \emph{J} rows correspond to the same items in each of 
 the focal groups. The number of columns depends on the selected IRT model: 2 for the 1PL model, 5 for the 2PL model, 6 for the constrained 3PL model
 and 9 for the unconstrained 3PL model. The columns of \code{irtParam} have to follow the same structure as the output of
 \code{itemParEst} command (the latter can actually be used to create the \code{irtParam} matrix). 

 In addition, the item parameters of the reference group and the focal groups must be placed on the same scale. This can be done by using \code{\link{itemRescale}}
 command, which performs equal means anchoring between two groups of item estimates (Cook and Eignor, 1991).

 The number of focal groups has to be specified with argument \code{nrFocal}.
}

\references{
 Cook, L. L. and Eignor, D. R. (1991). An NCME instructional module on IRT equating methods. \emph{Educational Measurement: Issues and Practice, 10}, 37-45.

 Kim, S.-H., Cohen, A.S. and Park, T.-H. (1995). Detection of differential item functioning in multiple groups. \emph{Journal of Educational Measurement, 32}, 261-276. \doi{10.1111/j.1745-3984.1995.tb00466.x}

 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}
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
 \code{\link{itemParEst}}, \code{\link{itemRescale}}, \code{\link{difGenLord}}
}

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)
 attach(verbal)

 # Creating four groups according to gender ("Man" or "Woman") and
 # trait anger score ("Low" or "High")
 group <- rep("WomanLow",nrow(verbal))
 group[Anger>20 & Gender==0] <- "WomanHigh"
 group[Anger<=20 & Gender==1] <- "ManLow"
 group[Anger>20 & Gender==1] <- "ManHigh"

 # Splitting the data into the four subsets according to "group"
 data0 <- data1 <- data2 <- data3 <- NULL
 for (i in 1:nrow(verbal)){
 if (group[i]=="WomanLow") data0 <- rbind(data0, as.numeric(verbal[i,1:24]))
 if (group[i]=="WomanHigh") data1 <- rbind(data1, as.numeric(verbal[i,1:24]))
 if (group[i]=="ManLow") data2 <- rbind(data2, as.numeric(verbal[i,1:24]))
 if (group[i]=="ManHigh") data3 <- rbind(data3, as.numeric(verbal[i,1:24]))
 }

 # Estimation of the item parameters (1PL model)
 m0.1PL <- itemParEst(data0, model = "1PL")
 m1.1PL <- itemParEst(data1, model = "1PL")
 m2.1PL <- itemParEst(data2, model = "1PL")
 m3.1PL <- itemParEst(data3, model = "1PL")

 # merging the item parameters with rescaling
 irt.scale <- rbind(m0.1PL, itemRescale(m0.1PL, m1.1PL), itemRescale(m0.1PL, m2.1PL), 
                    itemRescale(m0.1PL, m3.1PL))

 # Generalized Lord's chi-squared statistics
 genLordChi2(irt.scale, nrFocal = 3)
 }
 }

