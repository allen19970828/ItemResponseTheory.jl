# DIF TRANSFORMED ITEM DIFFICULTIES (ANGOFF's DELTA METHOD)

#' @importFrom deltaPlotR deltaPlot diagPlot
#' @export
difTID<-function (Data, group, focal.name, thrTID = 1.5, 
purify = FALSE, purType = "IPP1", nrIter = 10, alpha = 0.05,
extreme = "constraint", const.range = c(0.001, 0.999), nrAdd = 1,
save.output=FALSE, output=c("out","default")) 
{
internalTID<-function(){

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
RES<-deltaPlotR::deltaPlot(data=cbind(Group,DATA),type="response",group=1,focal.name=focal.name,
thr = thrTID, purify = purify, purType = purType, maxIter = nrIter, 
alpha =alpha, extreme = extreme, const.range = const.range, nrAdd = nrAdd, 
 save.output = save.output,output = output)
if (is.null(colnames(DATA))) {
itNames<-1:ncol(DATA)
number<-TRUE
}
else {
itNames<-colnames(DATA)
number<-FALSE
}
RES<-c(RES,list(names=itNames,number=number))
class(RES)<-"TID"
return(RES)
}
resToReturn<-internalTID()
if (save.output){
if (output[2]=="default") wd<-paste(getwd(),"/",sep="")
else wd<-output[2]
fileName<-paste(wd,output[1],".txt",sep="")
capture.output(resToReturn,file=fileName)
}
return(resToReturn)
}



## PLOT METHOD

#' @export
plot.TID<-function (x, plot="dist",pch = 2, pch.mult = 17, axis.draw = TRUE, thr.draw = FALSE, 
    dif.draw = c(1, 3), print.corr = FALSE, xlim = NULL, ylim = NULL, 
    xlab = NULL, ylab = NULL, main = NULL, col="red", number=TRUE,save.plot = FALSE, 
    save.options = c("plot", "default", "pdf"),...) 
{
PLOT<-switch(plot,dist=1,delta=2)
if(is.null(PLOT)) stop("'plot' must be either 'dist' or 'delta'",call.=FALSE)
if (PLOT==2) deltaPlotR::diagPlot(x,pch = pch, pch.mult = pch.mult, 
axis.draw = axis.draw, thr.draw = thr.draw, dif.draw = dif.draw, 
print.corr = print.corr, xlim = xlim , ylim = ylim, xlab = xlab, 
ylab = ylab, main = main, save.plot = save.plot, 
    save.options = save.options)
if (PLOT==1) {
    internalTID <- function() {
    res <- x
yl<-c(min(c(res$Dist,-abs(res$thr)),na.rm=TRUE)-0.1,max(c(res$Dist,abs(res$thr)),na.rm=TRUE)+0.1)
plot(res$Dist,xlab = "Item", ylab = "Perpendicular distance",ylim = yl, col="white", main = "Transformed Item Difficulties")
if (!number){
text(1:length(res$Dist), res$Dist, res$names)
if (!is.character(res$DIFitems)) text(res$DIFitems, res$Dist[res$DIFitems], res$names[res$DIFitems],col = col)
}
else{
text(1:length(res$Dist), res$Dist, 1:length(res$Dist))
if (!is.character(res$DIFitems)) text(res$DIFitems, res$Dist[res$DIFitems], res$DIFitems,col = col)
}
abline(h = -abs(res$thr))
abline(h = abs(res$thr))
}
internalTID()
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
internalTID()
}
dev.off()
}
if (plotype==2){
{
jpeg(filename=fileName)
internalTID()
}
dev.off()
}
cat("The plot was captured and saved into","\n"," '",fileName,"'","\n","\n",sep="")
}
}
else cat("The plot was not captured!","\n",sep="")
}
}


## PRINT METHOD


#' @export
print.TID<-function (x, only.final = TRUE, ...) 
{
    res <- x
    cat("\n")
    cat("Detection of Differential Item Functioning using Angoff's Delta method", 
        "\n")
    if (res$purify) 
        cat("  with item purification", "\n", "\n")
    else cat("  without item purification", "\n", "\n")
    if (res$purify) {
        if (res$convergence) {
            if (res$nrIter == 1) 
                cat("Convergence reached after", res$nrIter, 
                  "iteration", "\n", "\n")
            else cat("Convergence reached after", res$nrIter, 
                "iterations", "\n", "\n")
        }
        else {
            cat("WARNING: convergence was not reached after", 
                res$maxIter, "iterations!", "\n", "\n")
        }
        if (res$nrIter > 1) {
            if (res$purType == "IPP1") {
                cat("Threshold kept fixed to", res$thr[1], "\n")
                if (res$rule == "fixed") 
                  cat(" (as fixed by the user [IPP1])", "\n", 
                    "\n")
                else cat(" (as computed from normal approximation [IPP1])", 
                  "\n", "\n")
            }
            else {
                cat("Threshold adjusted iteratively using normal approximation", 
                  "\n")
                cat(" and ", round(res$alpha * 100), "% significance level", 
                  "\n", sep = "")
                if (res$purType == "IPP2") 
                  cat(" (only slope parameter updated [IPP2])", 
                    "\n", "\n")
                else cat(" (full update of the threshold [IPP3])", 
                  "\n", "\n")
            }
        }
    }
    if (res$adjust.extreme == "constraint") 
        cat("Extreme proportions adjusted by constraining to [", 
            round(res$const.range[1], 3), "; ", res$const.range[2], 
            "]", "\n", "\n", sep = "")
    else {
        if (res$nrAdd == 1) 
            cat("Extreme proportions adjusted by adding one success and one failure", 
                "\n", "\n")
        else cat("Extreme proportions adjusted by adding ", res$nrAdd, 
            " successes and ", res$nrAdd, " failures", "\n", 
            "\n", sep = "")
    }
    if (res$purify) 
        cat("Statistics (after the first iteration):", "\n", 
            "\n")
    else cat("Statistics:", "\n", "\n")
        m1 <- round(cbind(res$Props, res$Deltas, res$Dist[, 1]), 
            4)
        symb <- symnum(abs(as.numeric(res$Dist[, 1])), c(0, abs(res$thr[length(res$thr)]), 
            Inf), symbols = c("", "***"))
        m1 <- noquote(cbind(format(m1, justify = "right"), symb))
        colnames(m1) <- c("Prop.Ref", "Prop.Foc", "Delta.Ref", 
            "Delta.Foc", "Dist.", "")
if (res$number){
    rn <- NULL
    for (i in 1:nrow(m1)) rn[i] <- paste("Item", i, sep = "")
}
else rn<-res$names
    rownames(m1) <- rn
    print(m1)
    cat("\n")
    cat("Code: '***' if item is flagged as DIF", "\n", "\n")
    if (res$purify) {
        cat("Statistics (after the last iteration):", "\n", "\n")
            m1 <- round(cbind(res$Props, res$Deltas, res$Dist[, 
                ncol(res$Dist)]), 4)
            symb <- symnum(abs(as.numeric(res$Dist[, ncol(res$Dist)])), 
                c(0, abs(res$thr[length(res$thr)]), Inf), symbols = c("", 
                  "***"))
            m1 <- noquote(cbind(format(m1, justify = "right"), 
                symb))
            colnames(m1) <- c("Prop.Ref", "Prop.Foc", "Delta.Ref", 
                "Delta.Foc", "Dist.", "")
if (res$number){
            rn <- NULL
            for (i in 1:nrow(m1)) rn[i] <- paste("Item", i, sep = "")
}
else rn<-res$names
            rownames(m1) <- rn
        print(m1)
        cat("\n")
        cat("Code: '***' if item is flagged as DIF", "\n", "\n")
    }
    if (!only.final) {
        cat("Perpendicular distances:", "\n", "\n")
        m1 <- round(res$Dist, 4)
        rc <- NULL
        for (t in 1:ncol(res$Dist)) rc[t] <- paste("Iter", t, 
            sep = "")
        colnames(m1) <- rc
        rn <- NULL
        for (i in 1:nrow(m1)) rn[i] <- paste("Item", i, sep = "")
        rownames(m1) <- rn
        print(m1)
        cat("\n")
    }
    myBool <- ifelse(!res$purify, TRUE, ifelse(res$nrIter == 
        1, TRUE, FALSE))
    if (myBool) {
        cat("Parameters of the major axis:", "\n", "\n")
        np <- round(rbind(res$axis.par), 4)
        rownames(np) <- ""
        colnames(np) <- c("a", "b")
        print(np)
        cat("\n")
        if (res$rule == "norm") 
            cat("Detection threshold: ", round(res$thr, 4), " (significance level: ", 
                round(res$alpha * 100, 0), "%)", sep = "", "\n", 
                "\n")
        else cat("Detection threshold: ", round(res$thr, 4), 
            sep = "", "\n", "\n")
    }
    else {
        if (only.final) {
            cat("Parameters of the major axis (first and last iterations only):", 
                "\n", "\n")
            if (is.null(dim(res$axis.par))) 
                np <- round(rbind(res$axis.par, res$axis.par), 
                  4)
            else np <- round(rbind(res$axis.par[c(1, nrow(res$axis.par)), 
                ]), 4)
            rownames(np) <- c("First", "Last")
            colnames(np) <- c("a", "b")
            print(np)
            cat("\n")
            if (res$rule == "norm") {
                cat("First and last detection thresholds: ", 
                  round(res$thr[1], 4), " and ", round(res$thr[length(res$thr)], 
                    4), sep = "", "\n")
                cat(" (significance level: ", round(res$alpha * 
                  100, 0), "%)", sep = "", "\n", "\n")
            }
            else cat("First and last detection thresholds: ", 
                round(res$thr[1], 4), " and ", round(res$thr[length(res$thr)], 
                  4), sep = "", "\n")
        }
        else {
            cat("Parameters of the major axis:", "\n", "\n")
            np <- round(rbind(res$axis.par), 4)
            npr <- NULL
            for (i in 1:nrow(res$axis.par)) npr[i] <- paste("Iter", 
                i, sep = "")
            rownames(np) <- npr
            colnames(np) <- c("a", "b")
            print(np)
            cat("\n")
            cat("Detection thresholds:", "\n", "\n")
            mm <- rbind(res$thr)
            rownames(mm) <- ""
            cn <- NULL
            for (i in 1:length(res$thr)) cn[i] <- paste("Iter", 
                i, sep = "")
            colnames(mm) <- cn
            print(mm)
            cat("\n")
            if (res$rule == "norm") 
                cat("(significance level: ", round(res$alpha * 
                  100, 0), "%)", sep = "", "\n", "\n")
            else cat("\n")
        }
    }
    if (is.character(res$DIFitems)) 
        cat("Items detected as DIF items:", res$DIFitems, "\n", 
            "\n")
    else {
        cat("Items detected as DIF items:", "\n")
        namedif <- NULL
        for (i in 1:length(res$DIFitems)) {
if (res$number) namedif[i] <- paste("Item", res$DIFitems[i], sep = "")
else namedif[i] <- res$names[res$DIFitems[i]]
}
        m3 <- cbind(namedif)
        rownames(m3) <- rep("", length(res$DIFitems))
        colnames(m3) <- ""
        print(m3, quote = FALSE)
        cat("\n")
    }
    if (!res$save.output) 
        cat("Output was not captured!", "\n")
    else {
        if (res$output[2] == "default") 
            wd <- file.path(getwd())
        else wd <- res$output[2]
        nameF <- paste(res$output[1], ".txt", sep = "")
        fileName <- file.path(wd, nameF)
        cat("Output was captured and saved into file", "\n", 
            " '", fileName, "'", "\n", "\n", sep = "")
    }
}