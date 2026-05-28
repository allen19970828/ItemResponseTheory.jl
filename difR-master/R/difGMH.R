#' @export
difGMH<-function (Data, group, focal.names, anchor = NULL,match="score", alpha = 0.05, 
    purify = FALSE, nrIter = 10, p.adjust.method=NULL,save.output = FALSE, output = c("out", 
        "default")) 
{
if (purify & match[1] != "score") 
        stop("purification not allowed when matching variable is not 'score'", 
            call. = FALSE)
    internalGMH <- function() {
        if (length(focal.names) == 1) 
            return(difMH(Data = Data, group = group, focal.name = focal.names, 
                anchor = anchor, alpha = alpha, purify = purify, 
                nrIter = nrIter, correct = FALSE))
        else {
            if (length(group) == 1) {
                if (is.numeric(group) == TRUE) {
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
            DF <- length(focal.names)
            for (i in 1:DF) Group[gr == focal.names[i]] <- i
            if (!is.null(anchor)) {
                dif.anchor <- anchor
                if (is.numeric(anchor)) 
                  ANCHOR <- anchor
                else {
                  ANCHOR <- NULL
                  for (i in 1:length(anchor)) ANCHOR[i] <- (1:ncol(DATA))[colnames(DATA) == 
                    anchor[i]]
                }
            }
            else {
                ANCHOR <- 1:ncol(DATA)
                dif.anchor <- NULL
            }
            if (!purify | match[1] != "score" | !is.null(anchor)) {
                STATS <- genMantelHaenszel(DATA, Group, match=match,anchor = ANCHOR)
                PVAL<-1-pchisq(STATS,DF)
if (max(STATS) <= qchisq(1 - alpha, DF)) 
                  DIFitems <- "No DIF item detected"
                else DIFitems <- (1:ncol(DATA))[STATS > qchisq(1 - 
                  alpha, DF)]
                RES <- list(GMH = STATS, p.value=PVAL,alpha = alpha, thr = qchisq(1 - 
                  alpha, DF), DIFitems = DIFitems, 
match=ifelse(match[1]=="score","score","matching variable"),p.adjust.method = p.adjust.method, 
                adjusted.p = NULL, purification = purify, 
                  names = colnames(DATA), anchor.names = dif.anchor, 
                  focal.names = focal.names, save.output = save.output, 
                  output = output)
                if (!is.null(anchor)) {
                  RES$GMH[ANCHOR] <- NA
                  for (i in 1:length(RES$DIFitems)) {
                    if (sum(RES$DIFitems[i] == ANCHOR) == 1) 
                      RES$DIFitems[i] <- NA
                  }
                  RES$DIFitems <- RES$DIFitems[!is.na(RES$DIFitems)]
                }
            }
            else {
                nrPur <- 0
                difPur <- NULL
                noLoop <- FALSE
                stats1 <- genMantelHaenszel(DATA, Group,match=match)
                if (max(stats1) <= qchisq(1 - alpha, DF)) {
                  DIFitems <- "No DIF item detected"
                  noLoop <- TRUE
                }
                else {
                  dif <- (1:ncol(DATA))[stats1 > qchisq(1 - alpha, 
                    DF)]
                  difPur <- rep(0, length(stats1))
                  difPur[dif] <- 1
                  repeat {
                    if (nrPur >= nrIter) 
                      break
                    else {
                      nrPur <- nrPur + 1
                      nodif <- NULL
                      if (is.null(dif) == TRUE) 
                        nodif <- 1:ncol(DATA)
                      else {
                        for (i in 1:ncol(DATA)) {
                          if (sum(i == dif) == 0) 
                            nodif <- c(nodif, i)
                        }
                      }
                      stats2 <- genMantelHaenszel(DATA, Group, 
                        anchor = nodif,match=match)
                      if (max(stats2) <= qchisq(1 - alpha, DF)) 
                        dif2 <- NULL
                      else dif2 <- (1:ncol(DATA))[stats2 > qchisq(1 - 
                        alpha, DF)]
                      difPur <- rbind(difPur, rep(0, ncol(DATA)))
                      difPur[nrPur + 1, dif2] <- 1
                      if (length(dif) != length(dif2)) 
                        dif <- dif2
                      else {
                        dif <- sort(dif)
                        dif2 <- sort(dif2)
                        if (sum(dif == dif2) == length(dif)) {
                          noLoop <- TRUE
                          break
                        }
                        else dif <- dif2
                      }
                    }
                  }
                  stats1 <- stats2
PVAL<-1-pchisq(stats1,DF)
                  DIFitems <- (1:ncol(DATA))[stats1 > qchisq(1 - 
                    alpha, DF)]
                }
                if (is.null(difPur) == FALSE) {
                  ro <- co <- NULL
                  for (ir in 1:nrow(difPur)) ro[ir] <- paste("Step", 
                    ir - 1, sep = "")
                  for (ic in 1:ncol(difPur)) co[ic] <- paste("Item", 
                    ic, sep = "")
                  rownames(difPur) <- ro
                  colnames(difPur) <- co
                }
                RES <- list(GMH = stats1, p.value=PVAL,alpha = alpha, thr = qchisq(1 - 
                  alpha, DF), DIFitems = DIFitems, 
match=ifelse(match[1]=="score","score","matching variable"),
p.adjust.method = p.adjust.method, 
                adjusted.p = NULL, purification = purify, 
                  nrPur = nrPur, difPur = difPur, convergence = noLoop, 
                  names = colnames(DATA), anchor.names = NULL, 
                  focal.names = focal.names, save.output = save.output, 
                  output = output)
            }
    if (!is.null(p.adjust.method)) {
            pval <- 1-pchisq(RES$GMH,length(RES$focal.names))
            RES$adjusted.p <- p.adjust(pval, method = p.adjust.method)
            if (min(RES$adjusted.p, na.rm = TRUE) > alpha) 
                RES$DIFitems <- "No DIF item detected"
            else RES$DIFitems <- which(RES$adjusted.p < alpha)
        }
            class(RES) <- "GMH"
            return(RES)
        }
    }
    resToReturn <- internalGMH()
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
plot.GMH <-function(x,pch=8,number=TRUE,col="red", save.plot=FALSE,save.options=c("plot","default","pdf"),...) 
{
internalGMH<-function(){
res <- x
if (!number) {
plot(res$GMH,xlab="Item",ylab="Generalized Mantel-Haenszel statistic",ylim=c(0,max(c(res$GMH,res$thr)+1,na.rm=TRUE)),pch=pch,main="Generalized Mantel-Haenszel")
if (!is.character(res$DIFitems)) points(res$DIFitems,res$GMH[res$DIFitems],pch=pch,col=col)
}
else {
plot(res$GMH,xlab="Item",ylab="Generalized Mantel-Haenszel statistic",ylim=c(0,max(c(res$GMH,res$thr)+1,na.rm=TRUE)),col="white",main=" Generalized Mantel-Haenszel")
text(1:length(res$GMH),res$GMH,1:length(res$GMH))
if (!is.character(res$DIFitems)) text(res$DIFitems,res$GMH[res$DIFitems],res$DIFitems,col=col)
}
abline(h=res$thr)
}
internalGMH()
if (save.plot){
plotype<-NULL
if (save.options[3]=="pdf") plotype<-1
if (save.options[3]=="jpeg") plotype<-2
if (is.null(plotype)==TRUE) cat("Invalid plot type (should be either 'pdf' or 'jpeg').","\n","The plot was not captured!","\n")
else {
if (save.options[2]=="default") wd<-paste(getwd(),"/",sep="")
else wd<-save.options[2]
fileName<-paste(wd,save.options[1],switch(plotype,'1'=".pdf",'2'=".jpg"),sep="")
if (plotype==1){
{
pdf(file=fileName)
internalGMH()
}
dev.off()
}
if (plotype==2){
{
jpeg(filename=fileName)
internalGMH()
}
dev.off()
}
cat("The plot was captured and saved into","\n"," '",fileName,"'","\n","\n",sep="")
}
}
else cat("The plot was not captured!","\n",sep="")
}



#' @export
print.GMH<- function(x,...){
res <- x
cat("\n")
cat("Detection of Differential Item Functioning using Generalized Mantel-Haenszel","\n")
if (res$purification & is.null(res$anchor.names)) pur<-"with "
else pur<-"without "
cat("method, ",pur, "item purification and with ",length(res$focal.names)," focal groups","\n","\n",sep="")
if (is.character(res$focal.names) | is.factor(res$focal.names)){
cat("Focal groups:","\n")
nagr<-cbind(res$focal.names)
rownames(nagr)<-rep("",nrow(nagr))
colnames(nagr)<-""
print(nagr,quote=FALSE)
cat("\n")
}
 if (res$purification & is.null(res$anchor.names)){
if (res$nrPur<=1) word<-" iteration"
else word<-" iterations"
 if (!res$convergence) {
 cat("WARNING: no item purification convergence after ",res$nrPur,word,"\n",sep="")
 loop<-NULL
 for (i in 1:res$nrPur) loop[i]<-sum(res$difPur[1,]==res$difPur[i+1,])
 if (max(loop)!=length(res$GMH)) cat("(Note: no loop detected in less than ",res$nrPur,word,")","\n",sep="")
 else cat("(Note: loop of length ",min((1:res$nrPur)[loop==length(res$GMH)])," in the item purification process)","\n",sep="")
 cat("WARNING: following results based on the last iteration of the purification","\n","\n")
}
 else cat("Convergence reached after ",res$nrPur,word,"\n","\n",sep="")
 }
 if (res$match[1] == "score") 
        cat("Matching variable: test score", "\n", "\n")
    else cat("Matching variable: specified matching variable", 
        "\n", "\n")
if (is.null(res$anchor.names)) {
itk<-1:length(res$GMH)
cat("No set of anchor items was provided", "\n", "\n")
}
else {
itk<-(1:length(res$GMH))[!is.na(res$GMH)]
cat("Anchor items (provided by the user):", "\n")
if (is.numeric(res$anchor.names)) mm<-res$names[res$anchor.names]
else mm<-res$anchor.names
mm <- cbind(mm)
rownames(mm) <- rep("", nrow(mm))
colnames(mm) <- ""
print(mm, quote = FALSE)
cat("\n", "\n")
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
cat("Generalized Mantel-Haenszel chi-square statistic:","\n","\n")
pval<-round(1-pchisq(res$GMH,length(res$focal.names)),4)
if (is.null(res$p.adjust.method)) symb<-symnum(pval,c(0,0.001,0.01,0.05,0.1,1),symbols=c("***","**","*",".",""))
else symb<-symnum(res$adjusted.p,c(0,0.001,0.01,0.05,0.1,1),symbols=c("***","**","*",".",""))
m1<-cbind(round(res$GMH[itk],4),pval[itk])
if (!is.null(res$p.adjust.method)) m1<-cbind(m1,round(res$adjusted.p[itk],4))
m1<-noquote(cbind(format(m1,justify="right"),symb[itk]))
if (!is.null(res$names)) rownames(m1)<-res$names[itk]
else{
rn<-NULL
for (i in 1:nrow(m1)) rn[i]<-paste("Item",i,sep="")
rownames(m1)<-rn[itk]
}
con<-c("Stat.","P-value")
if (!is.null(res$p.adjust.method)) con<-c(con,"Adj. P")
con<-c(con,"")
colnames(m1)<-con
print(m1)
cat("\n")
cat("Signif. codes: 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 ","\n")
cat("\n","Detection threshold: ",round(res$thr,4)," (significance level: ",res$alpha,")","\n","\n",sep="")
if (is.character(res$DIFitems)) cat("Items detected as DIF items:",res$DIFitems,"\n","\n")
else {
cat("Items detected as DIF items:","\n")
  if (!is.null(res$names)) m2 <- res$names
    else {
        rn <- NULL
        for (i in 1:length(res$GMH)) rn[i] <- paste("Item", i, sep = "")
        m2 <- rn
    }
        m2 <- cbind(m2[res$DIFitems])
rownames(m2)<-rep("",nrow(m2))
colnames(m2)<-""
print(m2,quote=FALSE)
cat("\n","\n")
}
    if (!x$save.output) cat("Output was not captured!","\n")
    else {
if (x$output[2]=="default") wd<-paste(getwd(),"/",sep="")
else wd<-x$output[2]
fileName<-paste(wd,x$output[1],".txt",sep="")
cat("Output was captured and saved into file","\n"," '",fileName,"'","\n","\n",sep="")
}
}