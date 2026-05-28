#' @export
difLRT<-function (Data, group, focal.name, alpha = 0.05, purify = FALSE, 
    nrIter = 10, p.adjust.method=NULL,save.output = FALSE, output = c("out", "default")) 
{
    internalLRT <- function() {
        if (length(group) == 1) {
            if (is.numeric(group)) {
                gr <- Data[, group]
                DATA <- Data[, (1:ncol(Data)) != group]
                colnames(DATA) <- colnames(Data)[(1:ncol(Data)) != 
                  group]
            }
            else {
                gr <- Data[, colnames(Data) == group]
                DATA <- Data[, colnames(Data) != group]
                colnames(DATA) <- colnames(Data)[colnames(Data) != 
                  group]
            }
        }
        else {
            gr <- group
            DATA <- Data
        }
        Group <- rep(0, nrow(DATA))
        Group[gr == focal.name] <- 1
        if (!purify) {
            STATS <- LRT(DATA, Group)
PVAL<-1-pchisq(STATS,1)
            if (max(STATS) <= qchisq(1 - alpha, 1)) 
                DIFitems <- "No DIF item detected"
            else DIFitems <- (1:ncol(DATA))[STATS > qchisq(1 - 
                alpha, 1)]
            RES <- list(LRT = STATS, p.value=PVAL,alpha = alpha, thr = qchisq(1 - 
                alpha, 1), DIFitems = DIFitems, p.adjust.method = p.adjust.method, 
                adjusted.p = NULL,purification = purify, 
                names = colnames(DATA), save.output = save.output, 
                output = output)
        }
        else {
            nrPur <- 0
            noLoop <- FALSE
            stats1 <- LRT(DATA, Group)
            if (max(stats1) <= qchisq(1 - alpha, 1)) {
                DIFitems <- "No DIF item detected"
                noLoop <- TRUE
            }
            else {
                dif <- (1:ncol(DATA))[stats1 > qchisq(1 - alpha, 
                  1)]
                nodif <- NULL
                for (i in 1:ncol(DATA)) {
                  if (sum(i == dif) == 0) 
                    nodif <- c(nodif, i)
                }
                repeat {
                  if (nrPur >= nrIter) 
                    break
                  else {
                    nrPur <- nrPur + 1
                    dat <- DATA[, nodif]
                    stats2 <- LRT(dat, Group)
                    stats1[nodif] <- stats2
                    if (max(stats2) <= qchisq(1 - alpha, 1)) {
                      noLoop <- TRUE
                      break
                    }
                    else {
                      ind2 <- (1:ncol(dat))[stats2 > qchisq(1 - 
                        alpha, 1)]
                      noind2 <- (1:ncol(dat))[stats2 <= qchisq(1 - 
                        alpha, 1)]
                      dif <- c(dif, nodif[ind2])
                      nodif <- nodif[noind2]
                    }
                  }
                }
                DIFitems <- (1:ncol(DATA))[stats1 > qchisq(1 - 
                  alpha, 1)]
            }
PVAL<-1-pchisq(stats1,1)
            RES <- list(LRT = stats1, p.value=PVAL,alpha = alpha, thr = qchisq(1 - 
                alpha, 1), DIFitems = DIFitems, p.adjust.method = p.adjust.method, 
                adjusted.p = NULL, purification = purify, 
                nrPur = nrPur, convergence = noLoop, names = colnames(DATA), 
                save.output = save.output, output = output)
        }
        if (!is.null(p.adjust.method)) {
            pval <- 1 - pchisq(RES$LRT, 1)
            RES$adjusted.p <- p.adjust(pval, method = p.adjust.method)
            if (min(RES$adjusted.p, na.rm = TRUE) > alpha) 
                RES$DIFitems <- "No DIF item detected"
            else RES$DIFitems <- which(RES$adjusted.p < alpha)
        }
        class(RES) <- "LRT"
        return(RES)
    }
    resToReturn <- internalLRT()
    if (save.output) {
        if (output[2] == "default") 
            wd <- paste(getwd(), "/", sep = "")
        else wd <- output[2]
        fileName <- paste(wd, output[1], ".txt", sep = "")
        capture.output(resToReturn, file = fileName)
    }
    return(resToReturn)
}




# METHODS
#' @export
plot.LRT<-function(x,pch=8,number=TRUE,col="red",  save.plot=FALSE,save.options=c("plot","default","pdf"),...) 
{
internalLRT<-function(){
res <- x
if (!number) {
plot(res$LRT,xlab="Item",ylab="Likelihood Ratio statistic",ylim=c(0,max(c(res$LRT,res$thr)+1)),pch=pch,main="Likelihood Ratio Test")
points(res$DIFitems,res$MH[res$DIFitems],pch=pch,col=col)
}
else {
plot(res$LRT,xlab="Item",ylab="Likelihood Ratio statistic",ylim=c(0,max(c(res$LRT,res$thr)+1)),col="white",main="Likelihood Ratio Test")
text(1:length(res$LRT),res$LRT,1:length(res$LRT))
if (!is.character(res$DIFitems)) text(res$DIFitems,res$LRT[res$DIFitems],res$DIFitems,col=col)
}
abline(h=res$thr)
}
internalLRT()
if (save.plot){
plotype<-NULL
if (save.options[3]=="pdf") plotype<-1
if (save.options[3]=="jpeg") plotype<-2
if (is.null(plotype)) cat("Invalid plot type (should be either 'pdf' or 'jpeg').","\n","The plot was not captured!","\n")
else {
if (save.options[2]=="default") wd<-paste(getwd(),"/",sep="")
else wd<-save.options[2]
fileName<-paste(wd,save.options[1],switch(plotype,'1'=".pdf",'2'=".jpg"),sep="")
if (plotype==1){
{
pdf(file=fileName)
internalLRT()
}
dev.off()
}
if (plotype==2){
{
jpeg(filename=fileName)
internalLRT()
}
dev.off()
}
cat("The plot was captured and saved into","\n"," '",fileName,"'","\n","\n",sep="")
}
}
else cat("The plot was not captured!","\n",sep="")
}



#' @export
print.LRT<-function (x, ...) 
{
    res <- x
    cat("\n")
    cat("Detection of Differential Item Functioning using Likelihood Ratio Test", 
        "\n")
    if (res$purification) 
        pur <- "with "
    else pur <- "without "
    cat(pur, "item purification", "\n", "\n", sep = "")
    if (res$purification) {
        if (res$nrPur <= 1) 
            word <- " iteration"
        else word <- " iterations"
        if (!res$convergence) {
            cat("WARNING: no item purification convergence after ", 
                res$nrPur, word, "\n", sep = "")
            cat("WARNING: following results based on the last iteration of the purification", 
                "\n", "\n")
        }
        else cat("Convergence reached after ", res$nrPur, word, 
            "\n", "\n", sep = "")
    }
    if (is.null(res$p.adjust.method)) 
        cat("No p-value adjustment for multiple comparisons", 
            "\n", "\n")
    else {
        pAdjMeth <- switch(res$p.adjust.method, bonferroni = "Bonferroni", 
            holm = "Holm", hochberg = "Hochberg", hommel = "Hommel", 
            BH = "Benjamini-Hochberg", BY = "Benjamini-Yekutieli")
        cat("Multiple comparisons made with", pAdjMeth, "adjustement of p-values", 
            "\n", "\n")
    }
    cat("Likelihood Ratio statistic:", "\n", "\n")
    pval <- round(1 - pchisq(res$LRT, 1), 4)
if (is.null(res$p.adjust.method)) symb <- symnum(pval, c(0, 0.001, 0.01, 0.05, 0.1, 1), symbols = c("***", 
        "**", "*", ".", ""))
else symb <- symnum(res$adjusted.p, c(0, 0.001, 0.01, 0.05, 0.1, 1), symbols = c("***", 
        "**", "*", ".", ""))
    m1 <- cbind(round(res$LRT, 4), pval)
if (!is.null(res$p.adjust.method)) m1<-cbind(m1,round(res$adjusted.p,4))
    m1 <- noquote(cbind(format(m1, justify = "right"), symb))
    if (!is.null(res$names)) 
        rownames(m1) <- res$names
    else {
        rn <- NULL
        for (i in 1:nrow(m1)) rn[i] <- paste("Item", i, sep = "")
        rownames(m1) <- rn
    }
   con <- c("Stat.", "P-value")
    if (!is.null(res$p.adjust.method)) 
        con <- c(con, "Adj. P", "")
    else con <- c(con, "")
    colnames(m1) <- con
    print(m1)
    cat("\n")
    cat("Signif. codes: 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 ", 
        "\n")
    cat("\n", "Detection threshold: ", round(res$thr, 4), " (significance level: ", 
        res$alpha, ")", "\n", "\n", sep = "")
    if (is.character(res$DIFitems) == TRUE) 
        cat("Items detected as DIF items:", res$DIFitems, "\n", 
            "\n")
    else {
        cat("Items detected as DIF items:", "\n")
        m2 <- cbind(rownames(m1)[res$DIFitems])
        rownames(m2) <- rep("", nrow(m2))
        colnames(m2) <- ""
        print(m2, quote = FALSE)
        cat("\n")
    }
    if (!x$save.output) 
        cat("Output was not captured!", "\n")
    else {
        if (x$output[2] == "default") 
            wd <- paste(getwd(), "/", sep = "")
        else wd <- x$output[2]
        fileName <- paste(wd, x$output[1], ".txt", sep = "")
        cat("Output was captured and saved into file", "\n", 
            " '", fileName, "'", "\n", "\n", sep = "")
    }
}