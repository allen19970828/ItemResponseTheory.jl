#' @export
LassoData <- function(Data, group){

  if (length(group) == 1) {
    if (is.numeric(group)) {
      GROUP <- Data[, group]
      DichoData <- Data[, (1:ncol(Data)) != group]
      colnames(DichoData) <- colnames(DichoData)[(1:ncol(Data)) != 
                                         group]
    }
    else {
      GROUP <- Data[, colnames(Data) == group]
      DichoData <- Data[, colnames(Data) != group]
      colnames(DichoData) <- colnames(Data)[colnames(Data) != 
                                         group]
    }
  }
  else {
    GROUP <- group
    DichoData <- Data
  }
  
  SCO   <- as.matrix(rowSums(DichoData,na.rm=TRUE))             # Total score
  SCORE <- as.matrix(rep(SCO, length(DichoData[1,])))
  GROUP <- as.matrix(rep(GROUP, length(DichoData[1,])))         # Group membership  
  Ans   <-  cbind(row = rownames(as.data.frame(DichoData)), stack(as.data.frame(DichoData))) # Answers of all the items
  
  Y<-cbind(SCORE,GROUP,Ans)                                     # Merge all 5 columns
  colnames(Y) <- c("SCORE","GROUP","PERS","Y","ITEM")           # Column names needed for lassoDIF function
  
  return(Y)
}