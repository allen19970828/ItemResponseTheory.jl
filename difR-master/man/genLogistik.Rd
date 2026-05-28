\name{genLogistik}
\alias{genLogistik}

\title{Generalized logistic regression DIF statistic}

\description{
 Calculates the "generalized logistic regression" likelihood-ratio or Wald statistics for DIF detection among 
 multiple groups. 
 }

\usage{
genLogistik(data, member, match = "score", anchor = 1:ncol(data), 
 	type = "both", criterion = "LRT") 
 }
 
\arguments{
 \item{data}{numeric: the data matrix (one row per subject, one column per item).}
 \item{member}{numeric: the vector of group membership with zero and positive integer entries only. See \bold{Details}.}
 \item{match}{specifies the type of matching criterion. Can be either \code{"score"} (default) to compute the test score, or any continuous or discrete variable with the same length as the number of rows of \code{data}. See \bold{Details}.}
 \item{anchor}{a vector of integer values specifying which items (all by default) are currently considered as anchor (DIF free) items. See \bold{Details}.}
 \item{type}{a character string specifying which DIF effects must be tested. Possible values are \code{"both"} (default), \code{"udif"} and \code{"nudif"}. 
            See \bold{Details}.}
 \item{criterion}{character: the type of test statistic used to detect DIF items. Possible values are \code{"LRT"} (default) and \code{"Wald"}. See \bold{Details}.}
}


\value{ 
 A list with nine components:
 \item{stat}{the values of the generalized logistic regression DIF statistics (that is, the likelihood ratio test statistics).}
 \item{R2M0}{the values of Nagelkerke's R^2 coefficients for the "full" model.}
 \item{R2M1}{the values of Nagelkerke's R^2 coefficients for the "simpler" model.}
 \item{deltaR2}{the differences between Nagelkerke's \eqn{R^2} coefficients of the tested models. See \bold{Details}.}
 \item{parM0}{a matrix with one row per item and \eqn{2+J*2} columns (where \emph{J} is the number of focal groups), holding successively the fitted 
               parameters \eqn{\hat{\alpha}}, \eqn{\hat{\beta}}, \eqn{\hat{\gamma}_i} and \eqn{\hat{\delta}_i} (\eqn{i = 1, ..., J}) of the "full" 
               model (\eqn{M_0} if \code{type="both"} or \code{type="nudif"}, \eqn{M_1} if \code{type="udif"}).}
 \item{parM1}{the same matrix as \code{parM0} but with fitted parameters for the "simpler" model (\eqn{M_1} if \code{type="nudif"}, \eqn{M_2} if \code{type="both"}
 		   or \code{type="udif"}).}
 \item{covMat}{a 3-dimensional matrix of size \emph{p} x \emph{p} x \emph{K}, where \emph{p} is the number of estimated parameters and \emph{K} is the number of
               items, holding the \emph{p} x \emph{p} covariance matrices of the estimated parameters (one matrix for each tested item).}
 \item{criterion}{the value of the \code{criterion} argument.}
\item{match}{a character string, either \code{"score"} or \code{"matching variable"} depending on the \code{match} argument.}
 }


\details{
 This command computes the generalized logistic regression statistic (Magis, Raiche, Beland and Gerard, 2011) in the specific framework of differential item
 functioning among  \eqn{(J+1)} groups and \emph{J} is the number of focal groups. It forms the basic command of \code{\link{difGenLogistic}} and is specifically 
 designed for this call.
 
 The three possible models to be fitted are:

 \deqn{M_0: logit (\pi_i) = \alpha + \beta X + \gamma_i + \delta_i X}
 \deqn{M_1: logit (\pi_i) = \alpha + \beta X + \gamma_i}
 \deqn{M_2: logit (\pi_i) = \alpha + \beta X}

 where \eqn{\pi_i} is the probability of answering correctly the item in group \emph{i} (\eqn{i = 0, ..., J}) and \eqn{X} is the matching criterion. Parameters
 \eqn{\alpha} and \eqn{\beta} are the common intercept and the slope of the logistic curves, while \eqn{\gamma_i} and \eqn{\delta_i} are group-specific
 parameters. For identification reasons the parameters \eqn{\gamma_0} and \eqn{\delta_0} of the reference group are set to zero. The set of parameters
 \eqn{\{\gamma_i: i = 1, ..., J\}} of the focal groups (\eqn{g=i}) represents the uniform DIF effect across all groups, and the set of parameters 
 \eqn{\{\delta_i: i = 1, ..., n\}} is used to model nonuniform DIF effect across all groups.
 The models are fitted with the \code{\link{glm}} function.

 The matching criterion can be either the test score or any other continuous or discrete variable to be passed in the \code{Logistik} function. This is specified by the \code{match} argument. By default, it takes the value \code{"score"} and the test score (i.e. raw score) is computed. The second option is to assign to \code{match} a vector of continuous or discrete numeric values, which acts as the matching criterion. Note that for consistency this vector should not belong to the \code{data} matrix.

 Two tests are available: the Wald test and the likelihood ratio test. With the likelihood ratio test, two nested models are fitted and compared by means
 of Wilks' Lambda (or likelihood ratio) statistic (Wilks, 1938). With the Wald test, the model parameters are statistically tested using an appropriate 
 contrast matrix. Each test is set with the \code{criterion} argument, with the values \code{"LRT"} and \code{"Wald"} respectively. 

 The argument \code{type} determines the type of DIF effect to be tested. The three possible values of \code{type} are: \code{type="both"} which tests
 the hypothesis \eqn{H_0: \gamma_i = \delta_i=0} for all \emph{i}; \code{type="nudif"} which tests the hypothesis \eqn{H_0: \delta_i = 0} for all \emph{i};
 and \code{type="udif"} which tests the hypothesis \eqn{H_0: \gamma_i = 0 | \delta_i = 0} for all \emph{i}. In other words, \code{type="both"} tests
 for DIF (without distinction between uniform and nonuniform effects), while \code{type="udif"} and \code{type="nudif"} test for uniform and nonuniform DIF,
 respectively. Whatever the tested DIF effects, this is a simultaneous test of the equality of focal group parameters to zero.

 The data are passed through the \code{data} argument, with one row per subject and one column per item.  Missing values are allowed but must be coded as 
 \code{NA} values. They are discarded from the fitting of the logistic models (see \code{\link{glm}} for further details).
  
 The vector of group membership, specified with \code{member} argument, must hold only zeros and positive integers. The value zero corresponds to the
 reference group, and each positive integer value corresponds to one focal group. At least two different positive integers must be supplied.

 Option \code{anchor} sets the items which are considered as anchor items for computing the  logistic regression DIF statistics. Items other than the anchor 
 items and the tested item are discarded. \code{anchor} must hold integer values specifying the column numbers of the corresponding anchor items. It is 
 mainly designed to perform item purification.

 In addition to the results of the fitted models (model parameters, covariance matrices, test statistics), Nagelkerke's \eqn{R^2} coefficients (Nagelkerke, 1991)
 are computed for each model and the output returns the differences in these coefficients. Such differences are used as measures of effect size by the
 \code{\link{difGenLogistic}} command; see Gomez-Benito, Dolores Hidalgo and Padilla (2009), Jodoin and Gierl (2001) and Zumbo and Thomas (1997).
}
 
\references{
 Gomez-Benito, J., Dolores Hidalgo, M. and Padilla, J.-L. (2009). Efficacy of effect size measures in logistic regression: an application for detecting DIF. 
 \emph{Methodology, 5}, 18-25. \doi{10.1027/1614-2241.5.1.18}

 Jodoin, M. G. and Gierl, M. J. (2001). Evaluating Type I error and power rates using an effect size measure with logistic regression procedure for DIF detection. \emph{Applied Measurement in Education, 14}, 329-349. \doi{10.1207/S15324818AME1404_2}

 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

 Magis, D., Raiche, G., Beland, S. and Gerard, P. (2011). A logistic regression procedure to detect differential item functioning among multiple groups. \emph{International Journal of Testing, 11}, 365--386. \doi{10.1080/15305058.2011.602810}

 Nagelkerke, N. J. D. (1991). A note on a general definition of the coefficient of determination. \emph{Biometrika, 78}, 691-692. \doi{10.1093/biomet/78.3.691}

 Wilks, S. S. (1938). The large-sample distribution of the likelihood ratio for testing composite hypotheses. \emph{Annals of Mathematical Statistics, 9}, 60-62. \doi{10.1214/aoms/1177732360}

 Zumbo, B. D. and Thomas, D. R. (1997). A measure of effect size for a model-based approach for studying DIF. Prince George, Canada: University of Northern British
 Columbia, Edgeworth Laboratory for Quantitative Behavioral Science.
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
 group <- rep(0,nrow(verbal))
 group[Anger>20 & Gender==0] <- 1
 group[Anger<=20 & Gender==1] <- 2
 group[Anger>20 & Gender==1] <- 3

 # Testing both types of DIF simultaneously
 # With all items
 genLogistik(verbal[,1:24], group)
 genLogistik(verbal[,1:24], group, criterion = "Wald")

 # Removing item 6 from the set of anchor items
 genLogistik(verbal[,1:24], group, anchor = c(1:5, 7:24))
 genLogistik(verbal[,1:24], group, anchor = c(1:5, 7:24), criterion = "Wald")

 # Testing nonuniform DIF effect
 genLogistik(verbal[,1:24], group, type = "nudif")
 genLogistik(verbal[,1:24], group, type = "nudif", criterion="Wald")

 # Testing uniform DIF effect
 genLogistik(verbal[,1:24], group, type = "udif")
 genLogistik(verbal[,1:24], group, type = "udif", criterion="Wald")

 # Using trait anger score as matching criterion
 genLogistik(verbal[,1:24], group, match = verbal[,25])
 }
 }
