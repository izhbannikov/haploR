#' This function queries RegulomeDB web-based tool 
#' and returns results in a data frame.
#' 
#' @param query Query (a vector of rsIDs).
#' @param genomeAssembly Genome assembly built: can be GRCh37 or GRCh38
#' @param limit It controls how many variants will be queried and returned for a large region. It can be a number (1000 by default) or "all". 
#' Please note that large number or "all" may get yourself hurt because you could get timeout or may even crash the server.
#' @param timeout A \code{timeout} parameter for \code{httr::GET}.
#' Default: 100
#' @return a data frame (table)
#' @examples
#' data <- regulomeSummary(c("rs4791078","rs10048158"))
#' head(data)
#' @rdname haploR-regulomeSummary
#' @export
regulomeSummary <- function(query=NULL, 
                          limit=1000,
                          genomeAssembly = NULL,
                          timeout=100) {
    
    if(is.null(genomeAssembly)) {
        genomeAssembly <- "GRCh37"
    }
  
    tryCatch({
        # Querying
        qr <- paste("https://", "www.regulomedb.org/regulome-summary/?regions=", paste(query, collapse = '%0A'), "&genome=", genomeAssembly, "&limit=", limit, "&format=json", sep="")
        r <- GET(qr, timeout=timeout)
        
        # Extracting content
        raw <- content(r, "text") 
        json_content <- fromJSON(raw)
        out <- lapply(json_content$summaries, function(x) {
          x[sapply(x, is.null)] <- NA
          unlist(x)
        })
        
        out <- as.data.frame(do.call("rbind", out))
        
    }, error=function(e) {
        print(e)
    })
    
    return(res.table=as_tibble(out))
}
