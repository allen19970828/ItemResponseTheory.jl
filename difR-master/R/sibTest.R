#' @importFrom mirt SIBTEST
#' @export
sibTest<-function (data, member, anchor = 1:ncol(data), type = "udif") 
{
    res <- matrix(NA, ncol(data), 5)
    for (item in 1:ncol(data)) {
            if (sum(item==anchor)==0) ANCHOR <- anchor
            else ANCHOR <- anchor[anchor != item]
            prov <- SIBTEST(data, member, focal_name = 1, match_set = ANCHOR, 
                suspect_set = item)
            if (type == "udif") 
                res[item, ] <- c(prov$beta[1], prov$SE[1], prov$X2[1], 
                  prov$df[1], prov$p[1])
            if (type == "nudif") 
                res[item, ] <- c(prov$beta[2], prov$SE[2], prov$X2[2], 
                  prov$df[2], prov$p[2])
    }
    RES <- list(Beta = res[, 1], SE = res[, 2], X2 = res[, 3], 
        df = res[, 4], p.value = res[, 5], type = type)
    return(RES)
}
