test_queryRegulome <- function() {
    ## Test vector of SNPs
    url <- "http://www.regulomedb.org/results"
    x <- url.exists(url)
    if(x) {
        x <- queryRegulome(c("rs4791078","rs10048158"), timeout = 100000)
    } else {
        print(paste("WARNING:", url, "not exists"))
    }
}
