\name{difQuade}
\alias{difQuade}
\alias{plot.difQuade}
\alias{print.difQuade}
\title{Detection of Differential Item Functioning Using Quade-Type Association Indices for Polytomous (Ordinal) Item}
\description{
This function detects DIF in ordinal items using association indices based on pairwise comparisons, as proposed by Quade (1974) and extended in Woods (2009). It supports various ordinal measures of association to identify uniform DIF only.
}
\usage{
difQuade(Data, group, focal.name = NULL, anchor = NULL,
         match = "score", type = c("ta", "e", "dxy", "dyx", "gamma"),
         alpha = 0.05, purify = FALSE, nrIter = 10,
         save.output = FALSE, output = c("out", "default"))
}
\arguments{
  \item{Data}{A data frame or matrix of ordinal item responses.}
  \item{group}{A vector indicating group membership.}
  \item{focal.name}{Value in \code{group} identifying the focal group.}
  \item{anchor}{Optional vector of anchor item indices. If \code{NULL}, all items are used.}
  \item{match}{Type of matching score: \code{"score"} (total test score) or \code{"restscore"} (excluding item).}
  \item{type}{Type of ordinal association index: \code{"ta"} (Kendall's tau-a), \code{"e"} (Wilson's e), \code{"gamma"} (Goodman & Kruskal's gamma), \code{"dyx"} (Somers' dyx), or \code{"dxy"} (Somers' dxy).}
  \item{alpha}{Significance level for DIF detection.}
  \item{purify}{Logical: should purification be applied?}
  \item{nrIter}{Number of iterations for purification.}
  \item{save.output}{Logical: should the results be saved to a text file?}
  \item{output}{Name of the output file (or \code{"out"} to use default).}
}
\details{
The function implements the ordinal association approach introduced by Quade (1974), where pairwise comparisons are made between respondents' item responses and total scores. Five indices are supported:

\itemize{
  \item \code{"ta"}: Kendall's tau-a, considers all pair types including ties.
  \item \code{"e"}: Wilson's e index, accounts for ties in both variables.
  \item \code{"gamma"}: Goodman & Kruskal's gamma, ignores tied pairs.
  \item \code{"dyx"}: Somers' dyx, conditions on the matching score.
  \item \code{"dxy"}: Somers' dxy, conditions on the item response.
}
These indices follow the methodology validated in Woods (2009), who confirmed through simulation their robustness across various ordinal DIF contexts.
}
\value{
An object of class \code{"difQuade"} with components:

\itemize{
  \item \code{stat}, \code{se}, \code{zstat}, \code{p.value}: test statistics, standard errors, z-values, and p-values for each item.
  \item \code{DIFitems}: Logical vector indicating flagged items.
  \item \code{match}, \code{type}, \code{anchor}, \code{purification}: arguments used.
}
}
\references{
Quade, D. (1974). Nonparametric tests for the comparison of two groups of multivariate observations. \emph{The Annals of Statistics}, 2(5), 949–960.

Woods, C. M. (2009). Testing for differential item functioning with measures of partial association. \emph{Applied Psychological Measurement}, 33(7), 538–554.
}
\author{    
    Sebastien Beland \cr
    Faculte des sciences de l'education \cr
    Universite de Montreal (Canada) \cr
    \email{sebastien.beland@umontreal.ca}\cr}
\seealso{\code{plot.difQuade}, \code{print.difQuade}}
\examples{
\dontrun{
# With real data
# DIF detection using tau-a and purification
data(SCS)
Data <- SCS[, 1:10]
group <- SCS$Gender

# Using ta and purification
res1 <- difQuade(Data, group, focal.name = 2, 
type = "ta", purify = TRUE)
print(res1)
# Here is a function thta plot the results
plot(res1)

# Using Goodman & Kruskal's gamma with restscore matching
res2 <- difQuade(Data, group, focal.name = 2, 
type = "gamma", match = "restscore")
print(res2)

# Using Wilson's e index (recommended for tied ordinal data)
res3 <- difQuade(Data, group, focal.name = 2, 
type = "e")
print(res3)

# Somers' dyx index with no purification
res4 <- difQuade(Data, group, focal.name = 2, 
type = "dyx", purify = FALSE)
print(res4)

# With simulated data

set.seed(1234)

# original item parameters
a <- rlnorm(10, -0.5)  # slopes
b <- runif(10, -2, 2)  # difficulty
d <- list()
d[[1]] <- c(0, 2, .5, -.15, -1.1)
d[[2]] <- c(0, 2, .25, -.45, -.75)
d[[3]] <- c(0, 1, .5, -.65, -1)
d[[4]] <- c(0, 2, .5, -.85, -2)
d[[5]] <- c(0, 1, .25, -.05, -1)
d[[6]] <- c(0, 2, .5, -.95, -1)
d[[7]] <- c(0, 1, .25, -.35, -2)
d[[8]] <- c(0, 2, .5, -.15, -1)
d[[9]] <- c(0, 1, .25, -.25, -2)
d[[10]] <- c(0, 2, .5, -.35, -1)

# Uniform DIF
It <- 10; NR <- 1000; NF <- 1000
ItDIFa <- NULL; Ga <- NULL
ItDIFb <- c(1, 3)
Gb <- rep(.5, 2)

Out.Unif <- SimPolyDif(It, ItDIFa, ItDIFb, NR, NF, a, b, d,
                       ncat = 5, Ga = Ga, Gb = Gb)
Out.Unif$ipars
Data <- Out.Unif$data

# Using ta and purification
res5 <- difQuade(Data = Data[, 1:10], group = Data$group, 
focal.name = "G1", type = "ta", purify = TRUE)
print(res5)
# Here is a function thta plot the results
plot(res5)

# Using Goodman & Kruskal's gamma with restscore matching
res6 <- difQuade(Data = Data[, 1:10], group = Data$group, 
focal.name = "G1", type = "gamma", match = "restscore")
print(res6)

# Using Wilson's e index (recommended for tied ordinal data)
res7 <- difQuade(Data = Data[, 1:10], group = Data$group, 
focal.name = "G1", type = "e")
print(res7)

# Somers' dyx index with no purification
res8 <- difQuade(Data = Data[, 1:10], group = Data$group, 
focal.name = "G1", type = "dyx", purify = FALSE)
print(res8)
}
}
