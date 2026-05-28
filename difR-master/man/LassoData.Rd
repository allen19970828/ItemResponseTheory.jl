\name{LassoData}
\alias{LassoData}

\title{Rearrange the data matrix for the Detection of DIF using the Lasso Approach (Magis et al. (2015)}

\description{A Function that rearrange the matrix to use the lasso DIF detection for dichotomous items.}

\usage{
LassoData(Data, group)
}

\arguments{
 \item{Data}{numeric: either the data matrix only, or the data matrix plus the vector of group membership.}
 \item{group}{numeric or character: either the vector of group membership or the column indicator (within Data) of group membership.}
 }

\value{
 A matrix of five columns where, respectively,:

 \item{SCORE}{is the total score.}
 \item{GROUP}{is the group membership.}
 \item{PERS}{is the number of the respondent.}
 \item{Y}{is the dichotomous answer to the item. Only "0" and "1" are allowed.}
 \item{ITEM}{is the item name (must be a character).}
 }
 
\details{
This function rearranges the data matrix for use in lasso-based DIF detection with dichotomous items. It requires a matrix of dichotomous item responses and a vector indicating group membership.
}

\references{
Magis, D., Tuerlinckx, F., & De Boeck, P. (2015). Detection of Differential Item Functioning Using the Lasso Approach. Journal of Educational and Behavioral Statistics, 40(2), 111–135. https://doi.org/10.3102/1076998614559747
 }

\author{
    Sebastien Beland \cr
    Faculte des sciences de l'education \cr
    Universite de Montreal (Canada) \cr
    \email{sebastien.beland@umontreal.ca} \cr
    Carl F. Falk \cr
    Department of Psychology \cr
    McGill University (Canada)  \cr
    \email{carl.falk@mcgill.ca}, \url{https://www.mcgill.ca/psychology/carl-f-falk} \cr
 }

\examples{
\dontrun{

# Example with the verbal data

data(verbal)

LassoData(Data=verbal[,1:24], group=verbal[,26])

# Example with SimDichoDif to generate uniform DIF

It   <- 15 # number of items
ItDIFa <- NULL
ItDIFb <- c(1,3)
NR   <- 100 # number of responses for group 1 (reference)
NF   <- 100 # number of responses for group 2 (focal)
a    <- rep(1,It)          
b    <- rnorm(It,1,.5)  
Gb   <- rep(2,2)           # Group value for U-DIF
Ga   <- 0                  # Group value for NU-DIF: need to be fix to 0 for U-DIF
Out1 <- SimDichoDif(It,ItDIFa,ItDIFb,NR,NF,a,b,Ga,Gb)
Data<-Out1$data[,1:15]
Member<-Out1$data[,16]

LassoData(Data=Data, group=Member)

 }
 }



