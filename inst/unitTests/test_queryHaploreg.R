test_queryHaploreg <- function() {
    # Test vector of SNPs
    x <- queryHaploreg(query=c("rs10048158","rs4791078"))
    checkEqualsNumeric(dim(x)[1], 33)
    # Test loading from file
    x <- queryHaploreg(file=system.file("extdata/snps.txt", package = "haploR"))
    checkEqualsNumeric(dim(x)[1], 33)
    # Test loading from study
    studies <- getStudyList()
    x <- queryHaploreg(study=studies[[1]])
    checkEqualsNumeric(dim(x)[1], 117)
}
