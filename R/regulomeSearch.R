#' This function queries RegulomeDB web-based tool 
#' and returns results in a data frame.
#' 
#' @param query Exact one query region in rsid or like "chr1:39492461-39492462"
#' @param genomeAssembly Genome assembly built: can be GRCh37 or GRCh38
#' @param limit It controls how many variants will be queried and returned for a large region. It can be a number (1000 by default) or "all". 
#' Please note that large number or "all" may get yourself hurt because you could get timeout or may even crash the server.
#' @param timeout A \code{timeout} parameter for \code{httr::GET}.
#' Default: 100
#' @return a list with the following items:
#' - guery_coordinates
#' - features
#' - regulome_score
#' - variants
#' - nearby_snps,
#' - assembly
#' @examples
#' data <- regulomeSearch("rs4791078")
#' head(data)
#' @rdname haploR-regulomeSummary
#' @export
regulomeSearch <- function(query=NULL, 
                          genomeAssembly = NULL,
                          limit=1000,
                          timeout=100) {
    
  
    if(is.null(genomeAssembly)) {
        genomeAssembly <- "GRCh37"
    }
  
    tryCatch({
        # Querying
        qr <- paste("https://", "www.regulomedb.org/regulome-search/?regions=", paste(query, collapse = '%0A'), "&genome=", genomeAssembly, "&limit=", limit, "&format=json", sep="")
        r <- GET(qr, timeout=timeout)
        
        # Extracting content
        raw <- content(r, "text") 
        json_content <- fromJSON(raw)
        
        ###
        guery_coordinates <- json_content$query_coordinates
        
        ###
        features1 <- lapply(json_content$features, function(x) {
          x[sapply(x, is.null)] <- NA
          unlist(x)
        })
        features <- t(data.frame(do.call("rbind", features1), check.names = FALSE, check.rows = FALSE))
        rownames(features) <- seq(1:nrow(features))
        
        ###
        regulome_score <- lapply(json_content$regulome_score, function(x) {
          x[sapply(x, is.null)] <- NA
          unlist(x)
        })
        regulome_score <- t(data.frame(do.call("rbind", regulome_score), check.names = FALSE, check.rows = FALSE))
        rownames(regulome_score) <- seq(1:nrow(regulome_score))
        
        tryCatch({
            variants <- lapply(json_content$variants, function(x) {
                x[sapply(x, is.null)] <- NA
                unlist(x)
            })
            variants <- t(data.frame(do.call("rbind", variants), check.names = FALSE, check.rows = FALSE))
            rownames(variants) <- seq(1:nrow(variants))
        }, error=function(e) {
          print(e)
          variants <- NULL
        })
        
        ###
        nearby_snps <- lapply(json_content$nearby_snps, function(x) {
          x[sapply(x, is.null)] <- NA
          unlist(x)
        })
        nearby_snps <- data.frame(do.call("rbind", nearby_snps))
        
        ###
        assembly <- json_content$assembly
        
        
    }, error=function(e) {
        print(e)
    })
    
    return(list(guery_coordinates=guery_coordinates, 
                features=features,
                regulome_score=regulome_score,
                variants=variants,
                nearby_snps=nearby_snps,
                assembly=assembly))
}
