#' This function queries RegulomeDB web-based tool 
#' and returns results in a data frame.
#' @param query Query (a vector of rsIDs or exact one query region in rsid or like "chr1:39492461-39492462").
#' @param genomeAssembly Genome assembly built: can be GRCh37 (default) or GRCh38.
#' @param limit It controls how many variants will be queried and returned for a large region. It can be a number (1000 by default) or "all". 
#' Please note that large number or "all" may get yourself hurt because you could get timeout or may even crash the server.
#' @param timeout A \code{timeout} parameter for \code{httr::GET}.
#' Default: 100
#' @return 
#' a data frame (table)
#' OR
#' a list with the following items:
#' - guery_coordinates
#' - features
#' - regulome_score
#' - variants
#' - nearby_snps,
#' - assembly
#' @examples
#' data <- queryRegulome(c("rs4791078","rs10048158"))
#' head(data)
#' @rdname haploR-queryRegulome
#' @export
queryRegulome <- function(query=NULL, 
                          genomeAssembly = "GRCh37",
                          limit=1000,
                          timeout=100) {
    res <- list()
    if(length(query) == 1) {
        res[[query]] <- regulomeSearch(query=query, genomeAssembly=genomeAssembly, limit=limit, timeout=timeout)
    } else if(length(query) > 1) {
        # Extract summary table
        summary <- regulomeSummary(query=query, genomeAssembly=genomeAssembly, limit=limit, timeout=timeout)
        # Extract individual variants
        res <- list()
        for(q in query) {
            res[[q]] <- regulomeSearch(query=q, genomeAssembly=genomeAssembly, limit=limit, timeout=timeout)
        }
        res$summary <- summary
    } else {
        stop("Invalid query")
    }
    
    return(res)
}
