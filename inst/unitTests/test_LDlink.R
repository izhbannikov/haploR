test_LDlink.LDmatrix <- function() {
    # Test vector of SNPs
    x <- LDlink.LDmatrix(snps=c("rs10048158","rs4791078"))
    checkEqualsNumeric(dim(x$matrix.r2), c(2,3))
    checkEqualsNumeric(dim(x$matrix.dprime), c(2,3))
    # Test loading from file
    x <- LDlink.LDmatrix(snps=system.file("extdata/snps.txt", package = "haploR"))
    checkEqualsNumeric(dim(x$matrix.r2), c(2,3))
    checkEqualsNumeric(dim(x$matrix.dprime), c(2,3))
}
