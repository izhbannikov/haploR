test_queryRegulome <- function() {
    x <- queryRegulome(c("rs4791078","rs10048158"))
    checkEqualsNumeric(dim(x$res.table)[1], 2)
}
