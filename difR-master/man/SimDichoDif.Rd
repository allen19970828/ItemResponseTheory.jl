\name{SimDichoDif}
\alias{SimDichoDif}

\title{Generation of DIF for dichotomous items}

\description{Function to generate DIF for dichotomous items using the 2PL model.}

\usage{
SimDichoDif(It, ItDIFa, ItDIFb, NR, NF,
            a = rep(1, It), b,
            Ga = rep(0, length(ItDIFa)), Gb = rep(0, length(ItDIFb)),
            D = 1, thR = NULL, thF = NULL,
            muR = 0, muF = 0, sigR = 1, sigF = 1)
}

\arguments{
 \item{It}{It: Number of items}
 \item{ItDIFa}{Vector of integers specifying which items have DIF for a parameters.}
 \item{ItDIFb}{Vector of integers specifying which items have DIF for b parameters.}
 \item{NR}{Number of respondents for reference group.}
 \item{NF}{Number of respondents for focal group (generalize to multiple focal groups).}
 \item{a}{Item slope for reference group.}
 \item{b}{Item difficulty for reference group.}
 \item{Gb}{Vector of difference in b's for focal group(s).}
 \item{Ga}{Vector of difference in a's for focal group(s).}
 \item{D}{Scaling parameter for 2PL. Defaults to 1.}
 \item{thR}{Optional vector of latent variable values for reference group.}
 \item{thF}{Optional vector of latent variable values for focal group.}
 \item{muR}{Mean of latent variable for reference group. Used if latent scores not supplied.}
 \item{muF}{Mean of latent variable for reference group. Used if latent scores not supplied.}
 \item{sigR}{Standard deviation of latent variable for reference group. Used if latent scores not supplied.}
 \item{sigF}{Standard deviation of latent variable for reference group. Used if latent scores not supplied.}
 }

\value{
 A list with several arguments:
 \item{data}{the matrix with DIF items.}
 \item{ipars}{the item parameters.}
 \item{thetas}{the person parameters.}
 }
 
\details{
This function is based on the 2PL model to test uniform, non-uniform of both DIF. To use the Rasch model, please restrict \emph{a} parameter to 1.
}

\references{
Berger, M., & Tutz, G. (2016). Detection of Uniform and Nonuniform Differential Item Functioning by Item-Focused Trees. 
\emph{Journal of Educational and Behavioral Statistics, 41}(6), 559–592. https://doi.org/10.3102/1076998616659371
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

# test to generate UDIF

It   <- 15 # number of items
ItDIFa <- NULL
ItDIFb <- c(1,3)
NR   <- 100 # number of responses for group 1 (reference)
NF   <- 100 # number of responses for group 2 (focal)
a    <- rep(1,It)          # for tests: runif(It,0.2,.5)  
b    <- rnorm(It,1,.5)  
Gb   <- rep(2,2)           # Group value for U-DIF
Ga   <- 0                  # Group value for NU-DIF: need to be fix to 0 for U-DIF
#Type <- "UDIF"
#seed <- 1

Out1 <- SimDichoDif(It,ItDIFa,ItDIFb,NR,NF,a,b,Ga,Gb)
Out1
Out1$ipars

# Test to generate NUDIF

It   <- 15                # Nb of items with DIF
ItDIFa <- c(1,3)
ItDIFb <- c(1,3)
NR   <- 100              # N for Ref.
NF   <- 100              # N for Focal
a    <- rep(1,It)        # For Rasch or any value for 1PL
b    <- rnorm(It,1,.5)   # Item difficulties from random normal 
Gb   <- rep(.8,2)        # Group value for U-DIF
Ga   <- rep(1.2,2)       # Group value for NU-DIF
#Type <- "NUDIF"
#seed <- 1

Out2 <- SimDichoDif(It,ItDIFa,ItDIFb,NR,NF,a,b,Ga,Gb)
Out2
Out2$ipars

# Generates a mix of UDIF and NUDIF

It   <- 15                # Nb of items with DIF
ItDIFa <- c(1)
ItDIFb <- c(1,3)
NR   <- 100              # N for Ref.
NF   <- 100              # N for Focal
a    <- rep(1,It)        # For Rasch or any value for 1PL
b    <- rnorm(It,1,.5)   # Item difficulties from random normal 
Gb   <- rep(.8,2)        # Group value for U-DIF
Ga   <- 1.2              # Group value for NU-DIF
#Type <- "NUDIF"
#seed <- 1

Out3 <- SimDichoDif(It,ItDIFa,ItDIFb,NR,NF,a,b,Ga,Gb)
Out3
Out3$ipars

 }
 }



