#' This function queries HaploReg web-based tool 
#' in order to see a list of GWAS.
#' 
#' @param url A url to HaploReg.
#' Default: <https://pubs.broadinstitute.org/mammals/haploreg/haploreg.php>
#' @return A list of studies. Each study is itself a list
#' of two: \code{name}, \code{id}.
#' @examples
#' studies <- getStudyList()
#' studies
#' @rdname haploR-getStudyList
#' @export
getStudyList <- function(
url=Haploreg.settings[["study.url"]]) {
    
    doc.html <- tryCatch(
      {
        htmlTreeParse(url, useInternalNodes = TRUE)
      }, error=function(e) {
        if(url.exists(url)) {
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
    
    if(is.null(doc.html)) {
        return(doc.html)
    }
    # Extract all the paragraphs (HTML tag is p, starting at
    # the root of the document). Unlist flattens the list to
    # create a character vector.
    snames <- unlist(xpathApply(doc.html, '//select[@name=\'gwas_idx\']/option', xmlValue))
    ids <- unlist(xpathApply(doc.html, '//select[@name=\'gwas_idx\']/option', xmlGetAttr, 'value'))
    
    studies <- lapply(1:length(snames), 
                    function(n) {study <- list(name=snames[n], id=ids[[n]])})
  
    names(studies) <- snames
  
    if(studies[[1]]$name == "") {
        studies[[1]] <- NULL
    }
  
    return(studies)
}
