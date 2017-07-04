#' This function queries HaploReg web-based tool 
#' in order to Extended view for SNP of interest
#' 
#' @param snp A SNP of interest.
#' @param url A url to HaploReg.
#' Default: <"http://archive.broadinstitute.org/mammals/haploreg/detail_v4.1.php?query=&id=">
#' @return A list of tables t1, t2, ..., etc 
#' depending on information contained in HaploReg database.
#' @examples
#' tables <- getExtendedView(snp="rs10048158")
#' tables
#' @rdname haploR-getExtendedView
#' @export
getExtendedView <- function(snp, url="http://archive.broadinstitute.org/mammals/haploreg/detail_v4.1.php?query=&id=") {
    # Construct a direct link:
    ext.url <- paste(url, snp, sep="")
    # Get data:
    page <- htmlParse(ext.url)
    tables <- readHTMLTable(page)
    
    #t1 <- readHTMLTable(page)[[1]]
    tables[[1]] <- tables[[1]][-1,]
    colnames(tables[[1]]) <- c("chr",	"pos hg19",	"chr2",	"pos (hg38)", "Reference", "Alternate", "AFR", "AMR",	"ASN", "EUR", "by GERP", "by SiPhy", "dbSNP functional annotation")
    
    if (length(tables) >=2) {
        #t2 <- readHTMLTable(page)[[2]]
        colnames(tables[[2]]) <- as.character(unlist(c(tables[[2]][1,])))
        tables[[2]] <- tables[[2]][-1,]
    }
    
    #t3 <- readHTMLTable(page)[[3]]
    #t4 <- readHTMLTable(page)[[4]]
    #t5 <- readHTMLTable(page)[[5]]
    
    table.names <- paste("t", 1:length(tables), sep="")
    names(tables) <- table.names
    
    return(tables)
}