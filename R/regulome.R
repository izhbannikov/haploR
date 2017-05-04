#' This function queries RegulomeDB \url{www.regulomedb.org} web-based tool 
#' and returns results in a data frame.
#' 
#' @param query Query (a vector of rsIDs).
#' @param format An output format. 
#' Can be on of the following: \code{full} - plain text,
#' \code{bed} -  BED (Browser Extensible Data) format, 
#' see e.g. <https://genome.ucsc.edu/FAQ/FAQformat.html#format5.1>,
#' \code{gff} - GFF (General Feature Format), 
#' see e.g. <https://genome.ucsc.edu/FAQ/FAQformat.html#format3>
#' Only \code{full} is currently supported. 
#' @param url Regulome url address. 
#' Default: <http://www.regulomedb.org/results>
#' @param timeout A \code{timeout} parameter for \code{curl}.
#' Default: 10
#' @param check_bad_snps Checks if all SNPs are annotated.
#' Default: \code{TRUE}
#' @param verbose Verbosing output. Default: FALSE.
#' @return A list of two:
#' (1) a data frame (table) and
#' (2) a list of bad SNP IDs. 
#' Bad SNP ID are those IDs 
#' that were not found in 1000 Genomes 
#' Phase 1 data
#' @examples
#' data <- queryRegulome(c("rs4791078","rs10048158"))
#' head(data[["res.table"]])
#' head(data[["bad.snp.id"]])
#' @rdname haploR-queryRegulome
#' @export
queryRegulome <- function(query=NULL, 
                          format = "full",
                          url="http://www.regulomedb.org/results",
                          timeout=10,
                          check_bad_snps=TRUE,
                          verbose=FALSE) {
  
    if(format != "full") {
        stop("Sorry! Only 'full' output format is supported now.")
    }
    
    res.table <- data.frame()
    bad.snp.id <- c()
    
    tryCatch({
        # First find the bad snp ids #
        qr <- paste(query, collapse = ',') 
        if(check_bad_snps) {
            dataHaploReg <- queryHaploreg(qr,timeout=timeout)
            bad.snp.id <- dataHaploReg[which(dataHaploReg$GENCODE_id == "" &
                                         dataHaploReg$chr == "" & 
                                         dataHaploReg$dbSNP_functional_annotation == ""), "rsID"]
        
            query <- query[which(!(query %in% bad.snp.id))]
        }
        # End of filtering bad snps #
        
        # Searching #
        qr <- paste(query, collapse='\n')
        encode <- "multipart"
  
        body <- list(data = qr)
        # Form encoded
        # Multipart encoded
        r <- POST(url, body = body, encode = encode, timeout(timeout))
        bin <- content(r, "raw")
        dat <- readBin(bin, character())
  
        # Download results
        doc.html <- htmlTreeParse(dat, useInternalNodes = TRUE)
        sid <- unlist(xpathApply(doc.html, "//input[@name='sid']", 
                                 xmlGetAttr, 'value'))
        url <- "http://www.regulomedb.org/download/"
        body <- list(format=format, sid = sid)
        # Form encoded
        # Multipart encoded
        r <- POST(url, body = body, encode = encode,  timeout(timeout))
        bin <- content(r, "raw")
        dat <- readBin(bin, character())
  
        ## Parsing output results ##
        sp <- strsplit(dat, '\n')[[1]]
        res.header <- unlist(strsplit(sp[1], '\t'))
        res.rows <- lapply(2:length(sp), 
                           function(n) { unlist(strsplit(sp[n], '\t')) } )
        res.table <- do.call(rbind.data.frame, res.rows)
        colnames(res.table) <- res.header
    }, error=function(e) {
        print(e)
    })
    
    for(i in 1:dim(res.table)[2]) {
        res.table[,i] <- as.character(res.table[,i])
        col.num.conv <- suppressWarnings(as.numeric(res.table[,i]))
        na.rate <- length(which(is.na(col.num.conv)))/length(col.num.conv)
        if(na.rate <= 0.5) {
            res.table[,i] <- col.num.conv
        }
    }
    
    return(list(res.table=as_tibble(res.table), bad.snp.id=bad.snp.id))
}