\name{difStd}
\alias{difStd}
\alias{plot.PDIF}
\alias{print.PDIF}

\title{Standardization DIF method}

\description{
  Performs DIF detection using standardization method. 
 }

\usage{
difStd(Data, group, focal.name, anchor = NULL, match = "score", 
  	stdWeight = "focal", thrSTD = 0.1, purify = FALSE, nrIter = 10, 
  	save.output = FALSE, output = c("out", "default"))
\method{print}{PDIF}(x, ...)
\method{plot}{PDIF}(x, pch = 8, number = TRUE, col = "red", save.plot = FALSE, 
  	save.options = c("plot", "default", "pdf"), ...)
 }
 
\arguments{
 \item{Data}{numeric: either the data matrix only, or the data matrix plus the vector of group membership. See \bold{Details}.}
 \item{group}{numeric or character: either the vector of group membership or the column indicator (within \code{data}) of group membership. See \bold{Details}.}
 \item{focal.name}{numeric or character indicating the level of \code{group} which corresponds to the focal group.}
\item{anchor}{either \code{NULL} (default) or a vector of item names (or identifiers) to specify the anchor items. See \bold{Details}.}
 \item{match}{specifies the type of matching criterion. Can be either \code{"score"} (default) to compute the test score, or any continuous or discrete variable with the same length as the number of rows of \code{Data}. See \bold{Details}.}
 \item{stdWeight}{character: the type of weights used for the standardized P-DIF statistic. Possible values are \code{"focal"} (default),
                  \code{"reference"} and \code{"total"}. See \bold{Details}.}
 \item{thrSTD}{numeric: the threshold (cut-score) for standardized P-DIF statistic (default is 0.10).}
 \item{purify}{logical: should the method be used iteratively to purify the set of anchor items? (default is \code{FALSE}).}
 \item{nrIter}{numeric: the maximal number of iterations in the item purification process (default is 10).}
 \item{save.output}{logical: should the output be saved into a text file? (Default is \code{FALSE}).}
 \item{output}{character: a vector of two components. The first component is the name of the output file, the second component is either the file path or
               \code{"default"} (default value). See \bold{Details}.}
 \item{x}{the result from a \code{PDIF} class object.}
 \item{pch, col}{type of usual \code{pch} and \code{col} graphical options.}
 \item{number}{logical: should the item number identification be printed (default is \code{TRUE}).}
 \item{save.plot}{logical: should the plot be saved into a separate file? (default is \code{FALSE}).}
 \item{save.options}{character: a vector of three components. The first component is the name of the output file, the second component is either the file path
                     or \code{"default"} (default value), and the third component is the file extension, either \code{"pdf"} (default) or \code{"jpeg"}.
                     See \bold{Details}.}
 \item{...}{other generic parameters for the \code{plot} or the \code{print} functions.}
}


\value{
A list of class "PDIF" with the following arguments:
  \item{PDIF}{the values of the standardized P-DIF statistics.}
  \item{stdAlpha}{the values of the standardized alpha values (for effect sizes computation).}
  \item{alpha}{the value of \code{alpha} argument.}
  \item{thr}{the value of the \code{thrSTD} argument.}
  \item{DIFitems}{either the column indicators of the items which were detected as DIF items, or "No DIF item detected".}
 \item{match}{a character string, either \code{"score"} or \code{"matching variable"} depending on the \code{match} argument.}
 \item{purification}{the value of \code{purify} option.} 
  \item{nrPur}{the number of iterations in the item purification process. Returned only if \code{purify} is \code{TRUE}.}
  \item{difPur}{a binary matrix with one row per iteration in the item purification process and one column per item. Zeros and ones in the \emph{i}-th 
   row refer to items which were classified respectively as non-DIF and DIF items at the (\emph{i}-1)-th step. The first row corresponds to the initial
   classification of the items. Returned only if \code{purify} is \code{TRUE}.}
  \item{convergence}{logical indicating whether the iterative item purification process stopped before the maximal number \code{nrIter} of allowed iterations. 
  Returned only if \code{purify} is \code{TRUE}.}
  \item{names}{the names of the items.}
 \item{anchor.names}{the value of the \code{anchor} argument.}
  \item{stdWeight}{the value of the \code{stdWeight} argument.}
  \item{save.output}{the value of the \code{save.output} argument.}
  \item{output}{the value of the \code{output} argument.}
 }
 
\details{
 The method of standardization (Dorans and Kulick, 1986) allows for detecting uniform differential item functioning 
 without requiring an item response model approach.
 
 The \code{Data} is a matrix whose rows correspond to the subjects and columns to the items. In addition, \code{Data} can hold the vector of group membership. 
 If so, \code{group} indicates the column of \code{Data} which corresponds to the group membership, either by specifying its name or by giving the column number.
 Otherwise, \code{group} must be a vector of same length as \code{nrow(Data)}.
 
 Missing values are allowed for item responses (not for group membership) but must be coded as \code{NA} values. They are discarded from sum-score computation.

 The vector of group membership must hold only two different values, either as numeric or character. The focal group is defined by
 the value of the argument \code{focal.name}. 
 
 The matching criterion can be either the test score or any other continuous or discrete variable to be passed in the \code{\link{stdPDIF}} function. This is specified by the \code{match} argument. By default, it takes the value \code{"score"} and the test score (i.e. raw score) is computed. The second option is to assign to \code{match} a vector of continuous or discrete numeric values, which acts as the matching criterion. Note that for consistency this vector should not belong to the \code{Data} matrix.

 The threshold (or cut-score) for classifying items as DIF has to be set by the user by the argument \code{thrSTD}. Default value is 0.10 
 but Dorans (1989) also recommends value 0.05. For this reason it is not possible to provide asymptotic \emph{p}-values.

 The weights for computing the standardized P-DIF statistics are defined through the argument \code{stdWeight}, with possible values
 \code{"focal"} (default value), \code{"reference"} and \code{"total"}. See \code{\link{stdPDIF}} for further details.
 
 In addition, two types of effect sizes are displayed. The first one is obtained from the standardized P-DIF statistic itself.
 According to Dorans, Schmitt and Bleistein (1992), the effect size of an item is classified as negligible if \eqn{|St-P-DIF| \leq 0.05},
 moderate if \eqn{0.05 \leq |St-P-DIF| \leq 0.10}, and large if if \eqn{|St-P-DIF| \geq 0.10}. The second one is based on the transformation
 to the ETS Delta Scale (Holland and Thayer, 1985) of the standardized 'alpha' values (Dorans, 1989; Holland, 1985). The values of the 
 effect sizes, together with the Dorans, Schmitt and Bleistein (DSB) and the ETS Delta scale (ETS) classification, are printed with the output.

 Item purification can be performed by setting \code{purify} to \code{TRUE}. Purification works as follows: if at least one item was detected as functioning 
 differently at some step of the process, then the data set of the next step consists in all items that are currently anchor (DIF free) items, plus the 
 tested item (if necessary). The process stops when either two successive applications of the method yield the same classifications of the items (Clauser and Mazor,
 1998), or when \code{nrIter} iterations are run without obtaining two successive identical classifications. In the latter case a warning message is printed. 

A pre-specified set of anchor items can be provided through the \code{anchor} argument. It must be a vector of either item names (which must match exactly the column names of \code{Data} argument) or integer values (specifying the column numbers for item identification). In case anchor items are provided, they are used to compute the test score (matching criterion), including also the tested item. None of the anchor items are tested for DIF: the output separates anchor items and tested items and DIF results are returned only for the latter. Note also that item purification is not activated when anchor items are provided (even if \code{purify} is set to \code{TRUE}). By default it is \code{NULL} so that no anchor item is specified.

 The output of the \code{difStd}, as displayed by the \code{print.PDIF} function, can be stored in a text file provided that \code{save.output} is set to \code{TRUE} 
 (the default value \code{FALSE} does not execute the storage). In this case, the name of the text file must be given as a character string into the first component
 of the \code{output} argument (default name is \code{"out"}), and the path for saving the text file can be given through the second component of \code{output}. The
 default value is \code{"default"}, meaning that the file will be saved in the current working directory. Any other path can be specified as a character string: see
 the \bold{Examples} section for an illustration.

 The \code{plot.PDIF} function displays the DIF statistics in a plot, with each item on the X axis. The type of point and the color are fixed by the usual \code{pch}
 and \code{col} arguments. Option \code{number} permits to display the item numbers instead. Also, the plot can be stored in a figure file, either in PDF or JPEG
 format. Fixing \code{save.plot} to \code{TRUE} allows this process. The figure is defined through the components of \code{save.options}. The first two components
 perform similarly as those of the \code{output} argument. The third component is the figure format, with allowed values \code{"pdf"} (default) for PDF file and
 \code{"jpeg"} for JPEG file.
}

 
\references{
 Clauser, B.E. and Mazor, K.M. (1998). Using statistical procedures to identify differential item functioning test items. \emph{Educational Measurement: Issues and
 Practice, 17}, 31-44. 

 Dorans, N. J. (1989). Two new approaches to assessing differential item functioning. Standardization and the Mantel-Haenszel method. \emph{Applied Measurement in
 Education, 2}, 217-233. \doi{10.1207/s15324818ame0203_3}
 
 Dorans, N. J. and Kulick, E. (1986). Demonstrating the utility of the standardization approach to assessing unexpected differential item performance on the Scholastic Aptitude Test. \emph{Journal of Educational Measurement, 23}, 355-368. \doi{10.1111/j.1745-3984.1986.tb00255.x}
 
 Dorans, N. J., Schmitt, A. P. and Bleistein, C. A. (1992). The standardization approach to assessing comprehensive differential item functioning. \emph{Journal of Educational Measurement, 29},
 309-319. \doi{10.1111/j.1745-3984.1992.tb00379.x}

 Holland, P. W. (1985, October). \emph{On the study of differential item performance without IRT}. Paper presented at the meeting of Military Testing Association, San Diego (CA). 

 Holland, P. W. and Thayer, D. T. (1985). An alternative definition of the ETS delta scale of item difficulty. \emph{Research Report RR-85-43}. Princeton,
 NJ: Educational Testing Service.

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
    \email{raiche.gilles@uqam.ca}\cr 
 }


\seealso{
 \code{\link{stdPDIF}}, \code{\link{dichoDif}} 
 }

\examples{
\dontrun{

 # Loading of the verbal data
 data(verbal)

 # Excluding the "Anger" variable
 verbal<-verbal[colnames(verbal) != "Anger"]

 # Three equivalent settings of the data matrix and the group membership
 difStd(verbal, group = 25, focal.name = 1)
 difStd(verbal, group = "Gender", focal.name = 1)
 difStd(verbal[,1:24], group = verbal[,25], focal.name = 1)

 # With other weights
 difStd(verbal, group = "Gender", focal.name = 1, stdWeight = "reference")
 difStd(verbal, group = "Gender", focal.name = 1, stdWeight = "total")
 
 # With item purification
 difStd(verbal, group = "Gender", focal.name = 1, purify = TRUE)
 difStd(verbal, group = "Gender", focal.name = 1, purify = TRUE, nrIter = 5)

 # With items 1 to 5 set as anchor items
 difStd(verbal, group = "Gender", focal.name = 1, anchor = 1:5)
 difStd(verbal, group = "Gender", focal.name = 1, anchor = 1:5, purify = TRUE)


 # With detection threshold of 0.05
 difStd(verbal, group = "Gender", focal.name = 1, thrSTD = 0.05)

 # Saving the output into the "STDresults.txt" file (and default path)
 r <- difStd(verbal, group = 25, focal.name = 1, save.output  =  TRUE, 
            output = c("STDresults","default"))

 # Graphical devices
 plot(r)

 # Plotting results and saving it in a PDF figure
 plot(r, save.plot = TRUE, save.options = c("plot", "default", "pdf"))

 # Changing the path, JPEG figure
 path <- "c:/Program Files/"
 plot(r, save.plot = TRUE, save.options = c("plot", path, "jpeg"))
}
 }

