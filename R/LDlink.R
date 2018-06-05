#' This function queries HaploReg web-based tool and returns results.
#' 
#' @param snps A list of snps (a vector of rsIDs, or a file, one SNP per line).
#' @param r2d Show r2 or D'. Default: \code{r2}
#' @param population A particular study.
#' Default: \code{ALL}.
#' @param snp.gene.map A list (map) in which a gene is a key.
#' Example: list("GENE1"=c("SNP1", "SNP2", "SNP3"), "GENE2"=c("SNP4", "SNP5"))
#' Default: \code{NA}
#' @return A list of two: (1) raw LD matrix and (2) colored (fancy) matrix with LD gradient.
#' @examples
#' library(haploR)
#' data <- LDlink.LDmatrix(c("rs10048158","rs4791078"))
#' head(data)
#' @rdname haploR-LDlink.LDmatrix
#' @export
LDlink.LDmatrix <- function(snps, r2d="r2", population="ALL", snp.gene.map=NA) {
    url <- "https://analysistools.nci.nih.gov/LDlink/LDlinkRest/ldmatrix"
    avail.pop <- c("YRI","LWK","GWD","MSL","ESN","ASW","ACB",
                   "MXL","PUR","CLM","PEL","CHB","JPT","CHS",
                   "CDX","KHV","CEU","TSI","FIN","GBR","IBS",
                   "GIH","PJL","BEB","STU","ITU",
                   "ALL", "AFR", "AMR", "EAS", "EUR", "SAS")
    
    # Checking parameters for validity
    if(!(r2d %in% c("r2", "d"))) {
        stop("Not valid r2d")
    }
    
    if(!(population %in% avail.pop)) {
        stop("Not valid population")
    }
    
    query <- c()
    if(mode(snps) %in% c("logical","numeric","complex","character")) {
        # Assume it is a file
        if(file.exists(snps)) {
            # Try to read data into lines
            tryCatch({
                query <- readLines(snps)
                query <- gsub("\n", "", query)
                query <- gsub("\r", "", query)
            }, error=function(e) {
                print(e)
                stop()
            }, warning=function(w) {
                print(w)
            })
            query <- paste(query, collapse = '%0A')  # %0A - new line character '\n'
        } else {
            query <- paste(snps, collapse = '%0A')  # %0A - new line character '\n'
        }
       
    }
    
    reference <- floor(runif(1) * (99999 - 10000 + 1))
    body <- list(paste("snps=",query, sep=""), 
                 "pop=ALL", 
                 paste("reference=",reference, sep=""),
                 paste("r2_d=","r2",sep=""))
    
    t.url <- paste(url, "?", paste(unlist(body), collapse = "&"), sep="")
    r <- GET(url=t.url)
    #dat <- content(r, "text")
    
    file.url <- paste("https://analysistools.nci.nih.gov/LDlink/tmp/r2_", reference, ".txt", sep="")
    #r <- GET(url=file.url)
    raw.ldmat <- read.csv(file=file.url, sep="\t")

    #r <- GET(url=paste("https://analysistools.nci.nih.gov/LDlink/tmp/matrix", reference, ".json", sep=""))
    #dat <- content(r, "parsed")
    
    # Manipulation
    ldmat <- raw.ldmat
    if(!(is.na(snp.gene.map))) {
        ldmat <- raw.ldmat
        cnames<-colnames(ldmat)[-1]
    
        ldmat <- rbind(NA, ldmat)
        ldmat <- cbind(NA, ldmat)
    
        for(i in 1:length(cnames)) {
            ldmat[1, i+2] <- snp.gene.map[[cnames[i]]]
        }
    
        for(i in 2:dim(ldmat)[1]) {
            ldmat[i, 1] <- snp.gene.map[[cnames[i-1]]]
        }
    }
    
    ld.matrix.out <- datatable(ldmat) %>% formatStyle(
            colnames(ldmat),
            backgroundColor = styleInterval(c(0, 0.5, 0.75, 0.85), 
                                            c('white', 'lightyellow', "yellow", "orange", "red"))
    )
    
    return(list(raw.matrix=raw.ldmat, stylish.matrix=ld.matrix.out))
}