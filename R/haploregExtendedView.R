#' This function queries HaploReg web-based tool 
#' in order to Extended view for SNP of interest
#' 
#' @param snp A SNP of interest.
#' @param url A url to HaploReg.
#' Default: <http://pubs.broadinstitute.org/mammals/haploreg/detail_v4.1.php?query=&id=>
#' Previously was: <"http://archive.broadinstitute.org/mammals/haploreg/detail_v4.1.php?query=&id=">
#' @return A list of tables t1, t2, ..., etc 
#' depending on information contained in HaploReg database.
#' @examples
#' tables <- getExtendedView(snp="rs10048158")
#' tables
#' @rdname haploR-getExtendedView
#' @export
getExtendedView <- function(snp, url=Haploreg.settings[["extended.view.url"]]) {
    
    res <- list()
    snp <- as.list(snp)
    for(s in snp) {
        # Construct a direct link:
        ext.url <- paste(url, s, sep="")
      
        # Get data:
        page <- tryCatch(
          {
            htmlParse(ext.url)
          }, error=function(e) {
            if(url.exists(ext.url)) {
                message(paste("URL does not seem to exist:", url))
            }
            message("Here's the original error message:")
            message(e$message)
            # Choose a return value in case of error
            return(NULL)
          }, warning=function(e) {
            message(e$message)
            # Choose a return value in case of warning
            return(NULL)
          }
        )
        if(is.null(page)) {
            next
        }
        
        tables <- readHTMLTable(page)
    
        #t1 <- readHTMLTable(page)[[1]]
        tables[[1]] <- tables[[1]][-1,]
        colnames(tables[[1]]) <- c("chr",	"pos hg19",	"chr2",	"pos (hg38)", "Reference", "Alternate", "AFR", "AMR",	"ASN", "EUR", "by GERP", "by SiPhy", "dbSNP functional annotation")
    
        plain.names <- xpathSApply(page, "//p", xmlValue)
        plain.names <- plain.names[plain.names != ""]
        table.names <- c("Sequence facts", 
                 "Closest annotated gene",
                 plain.names[4:length(plain.names)])
    
    
        if (length(tables) >=2) {
            #t2 <- readHTMLTable(page)[[2]]
            colnames(tables[[2]]) <- as.character(unlist(c(tables[[2]][1,])))
            tables[[2]] <- tables[[2]][-1,]
        }
    
    
        #table.names <- c(t.names, paste("t", 4:length(tables), sep=""))
        names(tables) <- table.names
        res[[s]] <- tables
    }
    return(res)
}