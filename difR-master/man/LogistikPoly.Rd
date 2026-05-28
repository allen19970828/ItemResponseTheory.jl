\name{LogistikPoly}
\alias{LogistikPoly}
\title{Detection of DIF in polytomous (ordinal) items using cumulative logistic regression}
\description{
  This function implements a method for detecting Differential Item Functioning (DIF) in ordinal response items using cumulative logistic regression (\code{\link[VGAM]{vglm}} with the \code{propodds} family).
}
\usage{
LogistikPoly(data, member, member.type = "group", match = "score",
             anchor = 1:ncol(data), type = "both", criterion = "LRT",
             all.cov = FALSE)
}
\arguments{
  \item{data}{A data.frame or matrix of item responses (ordinal scale), with one row per subject, one column per item.}
  \item{member}{A vector indicating group membership (e.g., reference vs. focal group).}
  \item{member.type}{Type of the group variable. Use \code{"group"} (default) for a categorical variable; a continuous covariate may also be provided.}
 \item{match}{matching variable: \code{"score"}, \code{"restscore"}, or an external numeric vector.}
  \item{anchor}{Indices of items used to compute the matching score (default is all items).}
  \item{type}{Type of DIF tested: \code{"both"} (uniform and non-uniform), \code{"udif"} (only uniform), or \code{"nudif"} (only non-uniform).}
  \item{criterion}{Model comparison criterion. Use \code{"LRT"} (likelihood-ratio test) or \code{"Wald"} (Wald test).}
  \item{all.cov}{Logical; if \code{TRUE}, returns the variance-covariance matrices of the model parameters for each item.}
}
\value{
A list with the following elements:
  \item{stat}{DIF test statistic (LRT or Wald) for each item.}
  \item{R2M0}{McKelvey-Zavoina pseudo R² for the full model (with group).}
  \item{R2M1}{McKelvey-Zavoina pseudo R² for the reduced model (without group).}
  \item{deltaR2}{Difference in R² between full and reduced models.}
  \item{parM0}{Matrix of parameter estimates for the full model.}
  \item{parM1}{Matrix of parameter estimates for the reduced model.}
  \item{seM0}{Standard errors for the parameters in the full model.}
  \item{seM1}{Standard errors for the parameters in the reduced model.}
  \item{cov.M0}{List of variance-covariance matrices for the full model (if \code{all.cov = TRUE}).}
  \item{cov.M1}{List of variance-covariance matrices for the reduced model (if \code{all.cov = TRUE}).}
  \item{criterion}{Criterion used for DIF detection ("LRT" or "Wald").}
  \item{member.type}{Type of group membership variable.}
  \item{match}{Indicates the type of matching method used ("score" or custom variable).}
}
\details{
This function compares nested cumulative logistic regression models to detect DIF in polytomous (ordinal) items. The full model includes group membership and its interaction with the matching variable (depending on the selected \code{type}).

If \code{match = "score"}, the total test score (based on anchor items) is used as the matching variable. This is the classical approach and allows for the application of iterative purification, whereby items identified as DIF are progressively excluded from the anchor set and the matching score is updated. If \code{match = "restscore"}, the matching score is computed by excluding the item currently being tested from the total score. However, since the matching score varies across items, purification cannot be applied under this setting. 

Larger test statistics values may indicate potential DIF.

McKelvey-Zavoina pseudo R² is used to compute model fit for both the full and reduced models, and their difference (\code{deltaR2}) is also provided.

For each item, the DIF analysis is performed using only complete cases. Respondents with missing data on the item being tested, the matching variable, or the group variable are excluded from the estimation for that item.
}
\references{
 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

Zumbo, B. D. (1999). \emph{A Handbook on the Theory and Methods of Differential ItemFunctioning (DIF): Logistic Regression Modeling as a Unitary Framework for Binary and Likert-Type (Ordinal) Item Scores}. Ottawa, ON: Directorate of Human Resources
Research and Evaluation, Department of National Defense.
}
\author{
    Sebastien Beland \cr
    Faculte des sciences de l'education \cr
    Universite de Montreal (Canada) \cr
    \email{sebastien.beland@umontreal.ca} \cr     
 }
\examples{
\dontrun{

# With real data

attach(SCS)

# With Wald procedure
LogistikPoly(data=SCS[,1:10], member=SCS[,11],criterion = "Wald")  

# Testing for non-uniform DIF
LogistikPoly(data=SCS[,1:10], member=SCS[,11],type = "nudif")

# Testing for uniform DIF
LogistikPoly(data=SCS[,1:10], member=SCS[,11],type = "udif")

# Use of the rest scores
LogistikPoly(data=SCS[,1:10], member=SCS[,11], match = "restscore")

# With simulated data

set.seed(1234)

# original item parameters
a <- rlnorm(10,-.5) # slopes
b <- runif(10, -2, 2) # difficulty
d <- list() # step parameters
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

# Change only a few item parameters
# Uniform DIF
It <- 10
NR <- 1000
NF <- 1000
ItDIFa <- NULL
Ga <- NULL
ItDIFb <- c(1, 3)
Gb <- rep(.5, 2) # 2 items w/ difficulty parameter that is higher in group 2

Out.Unif <- SimPolyDif(It, ItDIFa, ItDIFb, NR, NF, a, b, d, ncat=5, Ga, Gb)
#Out.Unif
Out.Unif$ipars
Data <- Out.Unif$data
  
# With Wald procedure
LogistikPoly(data=Out.Unif$data[,1:10], member=Out.Unif$data[,11], criterion = "Wald")  

# Testing for non-uniform DIF
LogistikPoly(data=Out.Unif$data[,1:10], member=Out.Unif$data[,11], type = "nudif")

# Testing for uniform DIF
LogistikPoly(data=Out.Unif$data[,1:10], member=Out.Unif$data[,11], type = "udif")

# Use of the rest scores
LogistikPoly(data=Out.Unif$data[,1:10], member=Out.Unif$data[,11], match = "restscore")

 }
 }
