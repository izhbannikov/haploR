test_queryRegulome <- function() {
    #x <- queryRegulome(c("rs4791078","rs10048158"), timeout = 100000)
    #checkEqualsNumeric(dim(x$res.table)[1], 2)
    x <- url.exists("http://www.regulomedb.org/")
    checkTrue(x)
}
