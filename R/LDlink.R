#' This function queries HaploReg web-based tool and returns results.
#' 
#' @param snps A list of snps (a vector of rsIDs, or a file, one SNP per line).
#' @param r2d Show r2 or D'. Default: \code{r2}
#' @param population A particular genetic population.
#' Default: \code{ALL}.
#' @return A list of three: (1) raw LD r2 matrix, 
#' (2) colored (fancy) matrix with LD r2 gradient (an object of classses \code{datatables}, \code{htmlwidget}),
#' (3) raw LD D-prime matrix.
#' @examples
#' library(haploR)
#' data <- LDlink.LDmatrix(c("rs10048158","rs4791078"))
#' head(data)
#' @rdname haploR-LDlink.LDmatrix
#' @export
LDlink.LDmatrix <- function(snps, r2d="r2", population="ALL") {
    
    url <- LD.settings[["ldmatrix.url"]]
    avail.pop <- LD.settings[["avail.pop"]]
    avail.ld <- LD.settings[["avail.ld"]]
    file.r2.url <- LD.settings[["ldmatrix.file.r2.url"]]
    file.dprime.url <- LD.settings[["ldmatrix.file.dprime.url"]]
    
    # Checking parameters for validity
    if(!(r2d %in% avail.ld)) {
        stop("Not valid r2d")
    }
    
    if(!(population %in% avail.pop)) {
        stop("Not valid population")
    }
    
    query <- c()
    snps.to.upload <- c()
    if(mode(snps) %in% c("logical","numeric","complex","character")) {
        # Assume it is a file
        if(file.exists(snps)) {
            # Try to read data into lines
            tryCatch({
                snps.to.upload <- readLines(snps)
                snps.to.upload <- gsub("\n", "", snps.to.upload)
                snps.to.upload <- gsub("\r", "", snps.to.upload)
            }, error=function(e) {
                print(e)
                stop()
            }, warning=function(w) {
                print(w)
            })
            query <- paste(snps.to.upload, collapse = '%0A')  # %0A - new line character '\n'
        } else {
            snps.to.upload <- snps
            query <- paste(snps.to.upload, collapse = '%0A')  # %0A - new line character '\n'
        }
       
    }
    
    
    
    reference <- floor(runif(1) * (99999 - 10000 + 1))
    body <- list(paste("snps=",query, sep=""), 
                 paste("pop=", population, sep=""), 
                 paste("reference=",reference, sep=""),
                 paste("r2_d=","r2",sep=""))
    
    t.url <- paste(url, "?", paste(unlist(body), collapse = "&"), sep="")
    r <- GET(url=t.url)
    #dat <- content(r, "text")
    
    # Download r2 data
    file.r2.url <- paste(file.r2.url, reference, ".txt", sep="")
    raw.ldmat.r2 <- read.csv(file=file.r2.url, sep="\t")
    
    # Download D prime data
    file.dprime.url <- paste(file.dprime.url, reference, ".txt", sep="")
    raw.ldmat.dprime <- read.csv(file=file.dprime.url, sep="\t")

    #r <- GET(url=paste("https://analysistools.nci.nih.gov/LDlink/tmp/matrix", reference, ".json", sep=""))
    #dat <- content(r, "parsed")
    
    # Manipulation
    # load gene names using haploreg:
    snp.gene.map <- NA
    tryCatch({
        haploreg.data <- data.frame(queryHaploreg(query=unique(snps.to.upload), querySNP = TRUE, timeout = 1000), stringsAsFactors=FALSE)
        snp.gene <- unique(haploreg.data[, c("query_snp_rsid", "GENCODE_name")])
        snp.gene$GENCODE_name <- as.character(snp.gene$GENCODE_name)
        snp.gene$query_snp_rsid <- as.character(snp.gene$query_snp_rsid)
        snp.gene.map <- setNames(snp.gene$GENCODE_name, snp.gene$query_snp_rsid)
    }, error=function(e) {
        print(e)
    }, waring=function(w) {
        print(w)
    })
    
    ldmat <- raw.ldmat.r2
    
    if(!(is.na(snp.gene.map))) {
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
    
    return(list(raw.matrix.r2=raw.ldmat.r2, 
                stylish.matrix.r2=ld.matrix.out, 
                raw.matrix.dprime=raw.ldmat.dprime))
}