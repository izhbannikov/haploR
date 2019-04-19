test_queryHaploreg <- function() {
    ## Test vector of SNPs
    #x <- queryHaploreg(query=c("rs10048158","rs4791078"), timeout = 100000)
    #checkEqualsNumeric(dim(x)[1], 33)
    ## Test loading from file
    #x <- queryHaploreg(file=system.file("extdata/snps.txt", package = "haploR"), timeout = 100000)
    #checkEqualsNumeric(dim(x)[1], 33)
    x <- url.exists("https://pubs.broadinstitute.org/mammals/haploreg/haploreg.php")
    checkTrue(x)
}
