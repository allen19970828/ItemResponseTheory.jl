\name{SimPolyDif}
\alias{SimPolyDif}

\title{Generation of DIF for polytomous items}

\description{Function to generate DIF for polytomous items using the GPCM.}

\usage{
 SimPolyDif(It, ItDIFa, ItDIFb,
                       NR, NF, a, b, d, ncat=3,
                       Ga=rep(0,ItDIFa), Gb=rep(0,ItDIFb),
                       D=1, 
                       thR=NULL,thF=NULL,muR=0,muF=0,sigR=1,sigF=1,
                       ItDIFd=NULL, Gd = lapply(1:It, function(x){rep(0,ncat)}))
 }

\arguments{
 \item{It}{It: Number of items}
 \item{ItDIFa}{Vector of integers specifying which items have DIF for a parameters.}
 \item{ItDIFb}{Vector of integers specifying which items have DIF for b parameters.}
 \item{NR}{Number of respondents for reference group.}
 \item{NF}{Number of respondents for focal group (generalize to multiple focal groups).}
 \item{a}{Item slope for reference group.}
 \item{b}{Item difficulty for reference group.}
 \item{d}{Step parameters, as a list whose length is the same as the number of items, for the reference group.}
 \item{ncat}{Number of categories per item. Currently the same number for all items.}
 \item{Gb}{Vector of difference in b's for focal group(s).}
 \item{Ga}{Vector of difference in a's for focal group(s).}
 \item{D}{Scaling parameter for GPCM. Defaults to 1.}
 \item{thR}{Optional vector of latent variable values for reference group.}
 \item{thF}{Optional vector of latent variable values for focal group.}
 \item{muR}{Mean of latent variable for reference group. Used if latent scores not supplied.}
 \item{muF}{Mean of latent variable for reference group. Used if latent scores not supplied.}
 \item{sigR}{Standard deviation of latent variable for reference group. Used if latent scores not supplied.}
 \item{sigF}{Standard deviation of latent variable for reference group. Used if latent scores not supplied.}
 \item{ItDIFd}{Vector of integers specifying which items have DIF for step parameters.}
 \item{Gd}{List of differences in d's for focal group(s).}
 }

\value{
 A list with several arguments:
 \item{data}{the matrix with DIF items.}
 \item{ipars}{the item parameters.}
 \item{thetas}{the person parameters.}
 }
 
\details{
This function is based on traditional parameterizations of the GPCM that have an overall difficulty parameter and step parameters.
}

\references{
Muraki, E. (1992). A generalized partial credit model: Application of an EM algorithm. \emph{Applied Psychological Measurement, 16,} 159–176.
 }

\author{
    Carl F. Falk \cr
    Department of Psychology \cr
    McGill University (Canada)  \cr
    \email{carl.falk@mcgill.ca}, \url{https://www.mcgill.ca/psychology/carl-f-falk} \cr
    Sebastien Beland \cr
    Faculte des sciences de l'education \cr
    Universite de Montreal (Canada) \cr
    \email{sebastien.beland@umontreal.ca} \cr
 }

\examples{
\dontrun{
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
difPolyLogistic(as.data.frame(Data[, 1:It]),
                group = Data[, It + 1], focal.name = "G2")

# Nonuniform DIF
ItDIFa <- c(1, 2)
Ga <- rep(.25, 2)
ItDIFb <- c(1, 3)
Gb <- rep(.5, 2)

Out.NUnif <- SimPolyDif(It, ItDIFa, ItDIFb, NR, NF, a, b, d,
                        ncat = 5, Ga = Ga, Gb = Gb)
Out.NUnif$ipars
Data <- Out.NUnif$data
difPolyLogistic(as.data.frame(Data[, 1:It]),
                group = Data[, It + 1], focal.name = "G2")

# Also changing step parameters
ItDIFd <- c(2)
Gd <- list(c(0, .25, -.25, .25, -.25))

Out.NUnif2 <- SimPolyDif(It, ItDIFa, ItDIFb, NR, NF, a, b, d,
                         ncat = 5, Ga = Ga, Gb = Gb,
                         ItDIFd = ItDIFd, Gd = Gd)
Out.NUnif2$ipars
Data <- Out.NUnif2$data
difPolyLogistic(as.data.frame(Data[, 1:It]),
                group = Data[, It + 1], focal.name = "G2")

}
}
