test_queryRegulome <- function() {
    ## Test vector of SNPs
<<<<<<< HEAD
    url <- "http://www.regulomedb.org/"
    x <- url.exists(url)
    if(x) {
        x <- regulomeSummary(c("rs4791078","rs10048158"), timeout = 100000)
=======
    url <- "http://www.regulomedb.org/results"
    x <- url.exists(url)
    if(x) {
        x <- queryRegulome(c("rs4791078","rs10048158"), timeout = 100000)
>>>>>>> 222e12c342c60fd04825117621e09891331b7c32
    } else {
        print(paste("WARNING:", url, "not exists"))
    }
}
