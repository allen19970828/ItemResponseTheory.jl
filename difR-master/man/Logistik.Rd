\name{Logistik}
\alias{Logistik}
\title{Logistic regression DIF statistic}
\usage{
Logistik(
  data,
  member,
  member.type = "group",
  match = "score",
  anchor = 1:ncol(data),
  type = "both",
  criterion = "LRT",
  all.cov = FALSE
)
}
\arguments{
\item{data}{numeric: the data matrix (one row per subject, one column per
item).}

\item{member}{numeric or factor: the vector of group membership. Can either
take two distinct values (zero for the reference group and one for the
focal group) or be a continuous vector. See \bold{Details}.}

\item{member.type}{character: either \code{"group"} (default) to specify
that group membership is made of two groups, or \code{"cont"} to indicate
that group membership is based on a continuous criterion. See
\bold{Details}.}

\item{match}{specifies the type of matching criterion. Can be either
\code{"score"} (default) to compute the total test score based on the
anchor items, or \code{"restscore"} to compute the matching score while
excluding the item currently being tested. This prevents contamination of
the matching variable by the item itself. Alternatively, any numeric vector
with the same length as the number of rows in \code{data} can be supplied
as an external matching variable.}

\item{anchor}{a vector of integer values specifying which items (all by
default) are currently considered as anchor (DIF free) items. Ignored if
\code{match} is not \code{"score"}. See \bold{Details}.}

\item{type}{a character string specifying which DIF effects must be tested.
Possible values are \code{"both"} (default), \code{"udif"} and
\code{"nudif"}. See \bold{Details}.}

\item{criterion}{a character string specifying which DIF statistic is
computed. Possible values are \code{"LRT"} (default) or \code{"Wald"}. See
\bold{Details}.}

\item{all.cov}{logical: should \emph{all} covariance matrices of model
parameter estimates be returned (as lists) for both nested models and all
items? (default is \code{FALSE}).}
}
\value{
A list with nine components:
\describe{
  \item{stat}{the values of the logistic regression DIF statistics.}
  \item{R2M0}{the values of Nagelkerke's R^2 coefficients for the "full" model.}
  \item{R2M1}{the values of Nagelkerke's R^2 coefficients for the "simpler" model.}
  \item{deltaR2}{the differences between Nagelkerke's \eqn{R^2} coefficients of the tested models. See \bold{Details}.}
  \item{parM0}{a matrix with one row per item and four columns, holding successively the fitted parameters \eqn{\hat{\alpha}}, \eqn{\hat{\beta}}, \eqn{\hat{\gamma}_1} and \eqn{\hat{\delta}_1} of the "full" model (\eqn{M_0} if \code{type = "both"} or \code{type = "nudif"}, \eqn{M_1} if \code{type = "udif"}).}
  \item{parM1}{the same matrix as \code{parM0} but with fitted parameters for the "simpler" model (\eqn{M_1} if \code{type = "nudif"}, \eqn{M_2} if \code{type = "both"} or \code{type = "udif"}).}
  \item{seM0}{a matrix with the standard error values of the parameter estimates in matrix \code{parM0}.}
  \item{seM1}{a matrix with the standard error values of the parameter estimates in matrix \code{parM1}.}
  \item{cov.M0}{either \code{NULL} (if \code{all.cov} argument is \code{FALSE}) or a list of covariance matrices of parameter estimates of the "full" model (\eqn{M_0}) for each item (if \code{all.cov} argument is \code{TRUE}).}
  \item{cov.M1}{either \code{NULL} (if \code{all.cov} argument is \code{FALSE}) or a list of covariance matrices of parameter estimates of the "reduced" model (\eqn{M_1}) for each item (if \code{all.cov} argument is \code{TRUE}).}
  \item{criterion}{the value of the \code{criterion} argument.}
  \item{member.type}{the value of the \code{member.type} argument.}
  \item{match}{a character string, either \code{"score"} or \code{"matching variable"} depending on the \code{match} argument.}
}
}
\description{
Calculates the "logistic regression" likelihood-ratio statistics and effect
sizes for DIF detection.
}
\details{
This command computes the logistic regression statistic (Swaminathan &
Rogers, 1990) in the specific framework of differential item functioning.
It forms the basic command of \code{\link{difLogistic}} and is specifically
designed for this call.

If the \code{member.type} argument is set to \code{"group"}, the
\code{member} argument must be a vector with two distinct (numeric or
factor) values, say 0 and 1 (for the reference and focal groups
respectively). Those values are internally transformed onto factors to
denote group membership. The three possible models to be fitted are then:

\deqn{M_0: \text{logit} (\pi_g) = \alpha + \beta X + \gamma_g + \delta_g X,}
\deqn{M_1: \text{logit} (\pi_g) = \alpha + \beta X + \gamma_g,}
\deqn{M_2: \text{logit} (\pi_g) = \alpha + \beta X,}

where \eqn{\pi_g} is the probability of answering correctly the item in
group \emph{g} and \eqn{X} is the matching variable. Parameters
\eqn{\alpha} and \eqn{\beta} are the intercept and the slope of the
logistic curves (common to all groups), while \eqn{\gamma_g} and
\eqn{\delta_g} are group-specific parameters. For identification reasons
the parameters \eqn{\gamma_0} and \eqn{\delta_0} for reference group
(\eqn{g = 0}) are set to zero. The parameter \eqn{\gamma_1} of the focal
group (\eqn{g = 1}) represents the uniform DIF effect, and the parameter
\eqn{\delta_1} is used to model nonuniform DIF effect. The models are
fitted with the \code{\link{glm}} function.

If \code{member.type} is set to \code{"cont"}, then "group membership" is
replaced by a continuous or discrete variable, given by the \code{member}
argument, and the models above are written as

\deqn{M_0: \text{logit} (\pi_g) = \alpha + \beta X + \gamma Y + \delta X Y,}
\deqn{M_1: \text{logit} (\pi_g) = \alpha + \beta X + \gamma Y,}
\deqn{M_2: \text{logit} (\pi_g) = \alpha + \beta X,}

where \code{Y} is the group variable. Parameters \eqn{\gamma} and
\eqn{\delta} act now as the \eqn{\gamma_1} and \eqn{\delta_1} DIF
parameters.

The matching criterion can be either the test score or any other continuous
or discrete variable to be passed in the \code{Logistik} function. This is
specified by the \code{match} argument. By default, it takes the value
\code{"score"} and the test score (i.e. raw score) is computed. The second
option is to assign to \code{match} a vector of continuous or discrete
numeric values, which acts as the matching criterion. Note that for
consistency this vector should not belong to the \code{data} matrix.

Two types of DIF statistics can be computed: the likelihood ratio test
statistics, obtained by comparing the fit of two nested models, and the
Wald statistics, obtained with an appropriate contrast matrix for testing
the model parameters (Johnson & Wichern, 1998). These are specified by
the argument \code{criterion}, with respective values \code{"LRT"} and
\code{"Wald"}. By default, the LRT statistics are computed.

If \code{criterion} is \code{"LRT"}, the argument \code{type} determines the
models to be compared by means of the LRT statistics. The three possible
values of \code{type} are: \code{type = "both"} (default) which
tests the hypothesis \eqn{H_0: \gamma_1 = \delta_1 = 0} (or \eqn{H_0: \gamma
= \delta = 0}) by comparing models \eqn{M_0} and \eqn{M_2};
\code{type = "nudif"} which tests the hypothesis \eqn{H_0: \delta_1 = 0} (or
\eqn{H_0: \delta = 0}) by comparing models \eqn{M_0} and \eqn{M_1}; and
\code{type = "udif"} which tests the hypothesis \eqn{H_0: \gamma_1 = 0} (or
\eqn{H_0: \gamma = 0}) by comparing models \eqn{M_1} and \eqn{M_2} (assuming
that \eqn{\delta_1 = 0} or \eqn{\delta = 0}). In other words,
\code{type="both"} tests for DIF (without distinction between uniform and
nonuniform effects), while \code{type = "udif"} and \code{type = "nudif"}
test for uniform and nonuniform DIF, respectively.

If \code{criterion} is \code{"Wald"}, the argument \code{type} determines
the logistic model to be considered and the appropriate contrast matrix.
If \code{type = "both"}, the considered model is model \eqn{M_0} and the
contrast matrix has two rows, (0, 0, 1, 0) and (0, 0, 0, 1). If
\code{type = "nudif"}, the considered model is also model \eqn{M_0} but the
contrast matrix has only one row, (0, 0, 0, 1). Eventually, if
\code{type = "udif"}, the considered model is model \eqn{M_1} and the
contrast matrix has one row, (0, 0, 1).

The data are passed through the \code{data} argument, with one row per
subject and one column per item. Missing values are allowed but must be
coded as \code{NA} values. They are discarded from the fitting of the
logistic models (see \code{\link{glm}} for further details).

The vector of group membership, specified with \code{member} argument, must
hold only zeros and ones, a value of zero corresponding to the reference
group and a value of one to the focal group.

Option \code{anchor} sets the items which are considered as anchor items
for computing the test scores and related logistic regression DIF
statistics. Items other than the anchor items and the tested item are
discarded. \code{anchor} must hold integer values specifying the column
numbers of the corresponding anchor items. It is mainly designed to perform
item purification. Note that this option is discarded when \code{match} is
not \code{"score"}.

The output contains: the selected DIF statistics (either the LRT or the
Wald statistic) computed for each item, two matrices with the parameter
estimates of both models (for each item) and two matrices of related
standard error values. In addition, Nagelkerke's \eqn{R^2} coefficients
(Nagelkerke, 1991) are computed for each model and the output returns both,
the vectors of \eqn{R^2} coefficients for each model and the differences in
these coefficients. Such differences are used as measures of effect size by
the \code{\link{difLogistic}} command; see Gomez-Benito, Dolores Hidalgo
and Padilla (2009), Jodoin and Gierl (2001), and Zumbo and Thomas (1997).
The \code{criterion} and \code{member.type} arguments are also returned, as
well as a character argument named \code{match} that specifies the type of
matching criterion that was used.
}
\examples{

\dontrun{

 # Loading of the verbal data
 data(verbal)

 # Testing both types of DIF simultaneously
 # With all items, test score as matching criterion
 Logistik(verbal[, 1:24], verbal[, 26])

 # Returning all covariance matrices of model parameters
 Logistik(verbal[, 1:24], verbal[, 26], all.cov = TRUE)

 # Testing both types of DIF simultaneously
 # With all items and Wald test
 Logistik(verbal[, 1:24], verbal[, 26], criterion = "Wald")

 # Removing item 6 from the set of anchor items
 Logistik(verbal[, 1:24], verbal[, 26], anchor = c(1:5, 7:24))

 # Testing for nonuniform DIF
 Logistik(verbal[, 1:24], verbal[, 26], type = "nudif")

 # Testing for uniform DIF
 Logistik(verbal[, 1:24], verbal[, 26], type = "udif")

 # Using the "anger" trait variable as matching criterion
 Logistik(verbal[, 1:24], verbal[, 26], match = verbal[, 25])

 # Using the "anger" trait variable as group membership
 Logistik(verbal[, 1:24], verbal[, 25], member.type = "cont")
 }

}
\references{
Gomez-Benito, J., Dolores Hidalgo, M. and Padilla, J.-L.
(2009). Efficacy of effect size measures in logistic regression: an
application for detecting DIF. \emph{Methodology, 5}, 18--25,
\doi{10.1027/1614-2241.5.1.18}

Jodoin, M. G. and Gierl, M. J. (2001). Evaluating Type I error and power
rates using an effect size measure with logistic regression procedure for
DIF detection. \emph{Applied Measurement in Education, 14}, 329--349,
\doi{10.1207/S15324818AME1404_2}

Johnson, R. A. and Wichern, D. W. (1998). \emph{Applied multivariate
statistical analysis (fourth edition)}. Upper Saddle River, NJ:
Prentice-Hall.

Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general
framework and an R package for the detection of dichotomous differential
item functioning. \emph{Behavior Research Methods, 42}, 847--862,
\doi{10.3758/BRM.42.3.847}

Nagelkerke, N. J. D. (1991). A note on a general definition of the
coefficient of determination. \emph{Biometrika, 78}, 691--692,
\doi{10.1093/biomet/78.3.691}

Swaminathan, H. and Rogers, H. J. (1990). Detecting differential item
functioning using logistic regression procedures. \emph{Journal of
Educational Measurement, 27}, 361--370, \doi{10.1111/j.1745-3984.1990.tb00754.x}

Zumbo, B. D. and Thomas, D. R. (1997). A measure of effect size for a
model-based approach for studying DIF. Prince George, Canada: University of
Northern British Columbia, Edgeworth Laboratory for Quantitative Behavioral
Science.
}
\seealso{
\code{\link{difLogistic}}, \code{\link{dichoDif}}
}
\author{
David Magis \cr
Data science consultant at IQVIA Belux \cr
Brussels, Belgium\cr

Sebastien Beland \cr
Faculte des sciences de l'education \cr
Universite de Montreal (Canada) \cr
\email{sebastien.beland@umontreal.ca} \cr

Gilles Raiche \cr
Universite du Quebec a Montreal \cr
\email{raiche.gilles@uqam.ca} \cr

Adela Hladka (nee Drabinova) \cr
Institute of Computer Science of the Czech Academy of Sciences \cr 
\email{hladka@cs.cas.cz} \cr
}
\keyword{internal}
