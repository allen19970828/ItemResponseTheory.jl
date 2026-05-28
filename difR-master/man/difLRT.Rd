\name{difLRT}
\alias{difLRT}
\alias{print.LRT}
\alias{plot.LRT}

\title{Likelihood-Ratio Test DIF method}

\description{
 Performs DIF detection using Likelihood Ratio Test (LRT) method.
}

\usage{
difLRT(Data, group, focal.name, alpha = 0.05, purify = FALSE, nrIter = 10, 
 	p.adjust.method = NULL, save.output = FALSE, output = c("out", "default")) 
\method{print}{LRT}(x, ...)
\method{plot}{LRT}(x, pch = 8, number = TRUE, col = "red", save.plot = FALSE, 
 	save.options = c("plot", "default", "pdf"), ...)

}

\arguments{
 \item{Data}{numeric: either the data matrix only, or the data matrix plus the vector of group membership. See \bold{Details}.}
 \item{group}{numeric or character: either the vector of group membership or the column indicator (within \code{data}) of group membership. See \bold{Details}.}
 \item{focal.name}{numeric or character indicating the level of \code{group} which corresponds to the focal group.}
 \item{alpha}{numeric: significance level (default is 0.05).}
 \item{purify}{logical: should the method be used iteratively to purify the set of anchor items? (default is FALSE).}
 \item{nrIter}{numeric: the maximal number of iterations in the item purification process (default is 10).}
 \item{p.adjust.method}{either \code{NULL} (default) or the acronym of the method for p-value adjustment for multiple comparisons. See \bold{Details}.}
\item{save.output}{logical: should the output be saved into a text file? (Default is \code{FALSE}).}
 \item{output}{character: a vector of two components. The first component is the name of the output file, the second component is either the file path or \code{"default"} (default value). See \bold{Details}.}
 \item{x}{the result from a \code{LRT} class object.}
 \item{pch, col}{type of usual \code{pch} and \code{col} graphical options.}
 \item{number}{logical: should the item number identification be printed (default is \code{TRUE}).}
 \item{save.plot}{logical: should the plot be saved into a separate file? (default is \code{FALSE}).}
 \item{save.options}{character: a vector of three components. The first component is the name of the output file, the second component is either the file path or \code{"default"} (default value),
                     and the third component is the file extension, either \code{"pdf"} (default) or \code{"jpeg"}. See \bold{Details}.}
 \item{...}{other generic parameters for the \code{plot} or the \code{print} functions.}
}

\value{
A list of class "LRT" with the following arguments:
  \item{LRT}{the values of the likelihood-ratio statistics.}
  \item{p.value}{the vector of p-values for the likelihood-ratio statistics.}
  \item{alpha}{the value of \code{alpha} argument.}
  \item{thr}{the threshold (cut-score) for DIF detection.}
  \item{DIFitems}{either the items which were detected as DIF items, or "No DIF item detected".}
 \item{p.adjust.method}{the value of the \code{p.adjust.method} argument.}
\item{adjusted.p}{either \code{NULL} or the vector of adjusted p-values for multiple comparisons.}
 \item{purification}{the value of \code{purify} option.} 
  \item{nrPur}{the number of iterations in the item purification process. Returned only if \code{purify} is \code{TRUE}.}
  \item{convergence}{logical indicating whether the iterative item purification process stopped before the maximal number of allowed iterations
   (10 by default). Returned only if \code{purify} is \code{TRUE}.}
  \item{names}{the names of the items.}
  \item{save.output}{the value of the \code{save.output} argument.}
  \item{output}{the value of the \code{output} argument.}
 }

\details{
 The likelihood-ratio test method (Thissen, Steinberg and Wainer, 1988) allows for detecting uniform differential item functioning 
 by fitting a closed-form Rasch model and by testing for extra interactions between group membership and item response. Currently only 
 the Rasch model can be used, so only uniform DIF can be detected. Moreover, items are tested one by one and the other items act as
 anchor items.

 The \code{Data} is a matrix whose rows correspond to the subjects and columns to the items. Missing values are allowed but must be coded as \code{NA} values.
 In addition, \code{Data} can hold the vector of group membership. If so, \code{group} indicates the column of \code{Data} which 
 corresponds to the group membership, either by specifying its name or by giving the column number. Otherwise, \code{group} must 
 be a vector of same length as \code{nrow(Data)}.
 
 The vector of group membership must hold only two different values, either as numeric or character. The focal group is defined by
 the value of the argument \code{focal.name}. 
 
 The function \code{glmer} from package \code{lme4} (Bates and Maechler, 2009) is used to fit the closed-form Rasch model. More precisely, the probability that 
 response \eqn{Y_{ijg}} of subject \emph{i} from group \emph{g} (focal or reference) to item \emph{j} is modeled as

 \deqn{logit (Pr(Y_{ijg}=1) = \theta_{ig} + \gamma_g - \beta_j}

 where \eqn{\theta_i} is subject's ability, \eqn{\beta_j} is the item difficulty and \eqn{\gamma_g} is the difference mean ability level between
 the focal and the reference groups. Subject abilities are treated as random effects, while item difficulties and \eqn{\gamma_g} are treated as fixed effects.
 Each item is tested by incorporating an interaction term, \eqn{\delta_{gj}}, and by testing its statistical significance using the traditional
 likelihood-ratio test.

 The threshold (or cut-score) for classifying items as DIF is computed as the quantile of the chi-squared distribution with lower-tail
 probability of one minus \code{alpha} and one degree of freedom.
 
 Item purification can be performed by setting \code{purify} to \code{TRUE}. In this case, items detected as DIF are iteratively
 removed from the set of tested items, and the procedure is repeated (using the remaining items) until no additional item is
 identified as functioning differently. The process stops when either there is no new item detected as DIF, or when \code{nrIter} iterations 
 are run and new DIF items are nevertheless detected. In the latter case a warning message is printed. 

Adjustment for multiple comparisons is possible with the argument \code{p.adjust.method}. The latter must be an acronym of one of the available adjustment methods of the \code{\link{p.adjust}} function. According to Kim and Oshima (2013), Holm and Benjamini-Hochberg adjustments (set respectively by \code{"Holm"} and \code{"BH"}) perform best for DIF purposes. See \code{\link{p.adjust}} function for further details. Note that item purification is performed on original statistics and p-values; in case of adjustment for multiple comparisons this is performed \emph{after} item purification.

 The output of the \code{difLRT}, as displayed by the \code{print.LRT} function, can be stored in a text file provided that \code{save.output} is set to \code{TRUE} 
 (the default value \code{FALSE} does not execute the storage). In this case, the name of the text file must be given as a character string into the first component
 of the \code{output} argument (default name is \code{"out"}), and the path for saving the text file can be given through the second component of \code{output}. The
 default value is \code{"default"}, meaning that the file will be saved in the current working directory. Any other path can be specified as a character string: see the 
 \bold{Examples} section for an illustration.

 The \code{plot.LRT} function displays the DIF statistics in a plot, with each item on the X axis. The type of point and the color are fixed by the usual \code{pch} and 
 \code{col} arguments. Option \code{number} permits to display the item numbers instead. Also, the plot can be stored in a figure file, either in PDF or JPEG format.
 Fixing \code{save.plot} to \code{TRUE} allows this process. The figure is defined through the components of \code{save.options}. The first two components perform similarly 
 as those of the \code{output} argument. The third component is the figure format, with allowed values \code{"pdf"} (default) for PDF file and \code{"jpeg"} for JPEG file.

}

\note{
 Because of the fitting of the modified Rasch model with \code{glmer}, the process can be very time consuming. 
}

\references{
 Bates, D. and Maechler, M. (2009). lme4: Linear mixed-effects models using S4 classes. R package version 0.999375-31. http://CRAN.R-project.org/package=lme4
 
Kim, J., and Oshima, T. C. (2013). Effect of multiple testing adjustment in differential item functioning detection. \emph{Educational and Psychological Measurement, 73}, 458--470. \doi{10.1177/0013164412467033}

 Magis, D., Beland, S., Tuerlinckx, F. and De Boeck, P. (2010). A general framework and an R package for the detection
 of dichotomous differential item functioning. \emph{Behavior Research Methods, 42}, 847-862. \doi{10.3758/BRM.42.3.847}

 Thissen, D., Steinberg, L. and Wainer, H. (1988). Use of item response theory in the study of group difference in trace lines. 
 In H. Wainer and H. Braun (Eds.), \emph{Test validity}. Hillsdale, NJ: Lawrence Erlbaum Associates.
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
 \code{\link{LRT}}, \code{\link{dichoDif}}
 }

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)
 attach(verbal)

 # Excluding the "Anger" variable
 verbal <- verbal[colnames(verbal)!="Anger"]

 # Keeping the first 5 items and the first 50 subjects
 # (this is an artificial simplification to reduce the computational time)
 verbal <- verbal[1:50, c(1:5, 25)]

 # Three equivalent settings of the data matrix and the group membership
 r <- difLRT(verbal, group = 6, focal.name = 1)
 difLRT(verbal, group = "Gender", focal.name = 1)
 difLRT(verbal[,1:5], group = verbal[,6], focal.name = 1)

 # Multiple comparisons adjustment using Benjamini-Hochberg method
 difLRT(verbal, group = 6, focal.name = 1, p.adjust.method = "BH")

 # With item purification
 difLRT(verbal, group = 6, focal.name = 1, purify = TRUE)

 # Saving the output into the "LRTresults.txt" file (and default path)
 r <- difLRT(verbal, group = 6, focal.name = 1, save.output = TRUE, 
            output = c("LRTresults", "default"))

 # Graphical devices
 plot(r)

 # Plotting results and saving it in a PDF figure
 plot(r, save.plot = TRUE, save.options = c("plot", "default", "pdf"))

 # Changing the path, JPEG figure
 path <- "c:/Program Files/"
 plot(r, save.plot = TRUE, save.options = c("plot", path, "jpeg"))

 # WARNING: do not trust the results above since they are based on a selected 
 # subset of the verbal data set!
 }
 }