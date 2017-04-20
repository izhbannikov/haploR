#' This function queries HaploReg web-based tool 
#' in order to see a list of GWAS.
#' 
#' @param url A url to HaploReg.
#' Default: <http://archive.broadinstitute.org/mammals/haploreg/haploreg.php>
#' @return A list of studies. Each study is itself a list
#' of two: \code{name}, \code{id}.
#' @examples
#' studies <- getStudyList()
#' studies
#' @rdname haploR-getStudyList
#' @export
getStudyList <- function(
url="http://archive.broadinstitute.org/mammals/haploreg/haploreg.php") {
  
    doc.html <- htmlTreeParse(url, useInternalNodes = TRUE)
  
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
