test_queryHaploreg <- function() {
    ## Test vector of SNPs
    url <- "https://pubs.broadinstitute.org/mammals/haploreg/haploreg.php"
    x <- url.exists(url)
    if(x) {
        x <- queryHaploreg(query=c("rs10048158","rs4791078"), timeout = 100000)
        x <- queryHaploreg(file=system.file("extdata/snps.txt", package = "haploR"), timeout = 100000)
    } else {
        print(paste("WARNING:", url, "not exists"))
    }
}
