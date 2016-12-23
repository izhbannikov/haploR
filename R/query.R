#' This function queries Haploreg web-based tool and returns results.
#' 
#' @param query Variant (SNP) code, only one is supported now.
#' @param ldThresh LD threshold, r2 (select NA to only show query variants). 
#' Default: 0.8.
#' @param ldPop 1000G Phase 1 population for LD calculation. 
#' Can be: "AFR", "AMR", "ASN". Default: "EUR".
#' @param epi Source for epigenomes. 
#' Default: "ChromHMM (Core 15-state model)".
#' @param cons Mammalian conservation algorithm. 
#' Default: "SiPhy-omega".
#' @param output Output mode. Text by default.
#' @param url Haplotype url address. 
#' Default: "http://archive.broadinstitute.org/mammals/haploreg/haploreg.php"
#' @param verbose Verbosing output. Default: FALSE.
#' @return A data frame with results.
#' @examples
#' data <- queryHaploreg("rs10048158")
#' head(data)
#' @rdname haploR-methods
#' @export
queryHaploreg <- function(query, ldThresh=0.8, ldPop="EUR", 
                    epi="ChromHMM (Core 15-state model)", 
                    cons="siphy", output="text",
                    url="http://archive.broadinstitute.org/mammals/haploreg/haploreg.php",
                    verbose=FALSE) {
    
    body <- list(query = query, ldThresh=as.character(ldThresh), 
                 ldPop=ldPop, epi=epi, 
                 cons=cons, output=output)
  
    # Form encoded
    # Multipart encoded
    r <- POST(url, body = body, encode="multipart")
  
    bin <- content(r, "raw")
    data.bin <- readBin(bin, character())
    sp <- strsplit(data.bin, '\n')
    res.table <- data.frame(matrix(nrow=length(sp[[1]])-1, ncol=length(strsplit(sp[[1]][1], '\t')[[1]])))
    colnames(res.table) <- strsplit(sp[[1]][1], '\t')[[1]]
  
    for(i in 2:length(sp[[1]])) {
        res.table[i-1,] <- strsplit(sp[[1]][i], '\t')[[1]]
    }
  
    return(res.table)
}
