#' This function queries HaploReg web-based tool and returns results.
#' 
#' @param query Query (a vector of rsIDs).
#' @param file A text file (one refSNP ID per line).
#' @param study A particular study. See function \code{getStudyList(...)}.
#' Default: \code{NULL}.
#' @param ldThresh LD threshold, r2 (select NA to only show query variants). 
#' Default: 0.8.
#' @param ldPop 1000G Phase 1 population for LD calculation. 
#' Can be: "AFR", "AMR", "ASN". Default: "EUR".
#' @param epi Source for epigenomes. 
#' Possible values: \code{vanilla} for ChromHMM (Core 15-state model);
#' \code{imputed} for ChromHMM (25-state model using 12 imputed marks);
#' \code{methyl} for H3K4me1/H3K4me3 peaks;
#' \code{acetyl} for H3K27ac/H3K9ac peaks.
#' Default: \code{vanilla}.
#' @param cons Mammalian conservation algorithm. 
#' Possible values: \code{gerp} for GERP,
#' \code{siphy} for SiPhy-omega,
#' \code{both} for both.
#' Default: \code{siphy}.
#' @param genetypes Show position relative to.
#' Possible values: \code{gencode} for Gencode genes;
#' \code{refseq} for RefSeq genes;
#' \code{both} for both.
#' Default: \code{gencode}.
#' @param url HaploReg url address. 
#' Default: <http://archive.broadinstitute.org/mammals/haploreg/haploreg.php>
#' @param verbose Verbosing output. Default: FALSE.
#' @return A data frame (table) with results similar to 
#' HaploReg uses.
#' @examples
#' data <- queryHaploreg(c("rs10048158","rs4791078"))
#' head(data)
#' @rdname haploR-queryHaploreg
#' @export
queryHaploreg <- function(query=NULL, file=NULL,
                          study=NULL,
                          ldThresh=0.8, 
                          ldPop="EUR", 
                          epi="vanilla", 
                          cons="siphy", 
                          genetypes="gencode",
                          url="http://archive.broadinstitute.org/mammals/haploreg/haploreg.php",
                          verbose=FALSE) {
    
  
    trunc <- 1000 # can be 0 2 3 4 5 1000
    oligo <- 1000 # can be 1, 6, 1000
    output <- "text"
    
    if(!is.null(study)) {
      if(class(study) == "list") {
          gwas_idx <- study$id
      } else {
         stop("Parameter study is not a list with 
              study id and study name.")
      }
    } else {
        gwas_idx <- "0"
    }
    
    
    if(!is.null(file)) {
      query <- upload_file(file)
      body <- list(upload_file=query, 
                   gwas_idx=gwas_idx,
                   ldThresh=as.character(ldThresh), 
                   ldPop=ldPop, epi=epi, 
                   cons=cons, 
                   genetypes=genetypes,
                   trunc=as.character(trunc),
                   oligo=as.character(oligo),
                   output=output)
      
    } else {
      query <- paste(query, collapse = ',') 
      body <- list(query=query, 
                   gwas_idx=gwas_idx,
                   ldThresh=as.character(ldThresh), 
                   ldPop=ldPop, epi=epi, 
                   cons=cons, 
                   genetypes=genetypes,
                   trunc=as.character(trunc),
                   oligo=as.character(oligo),
                   output=output)
      
    }
    res.table <- data.frame()
    tryCatch({
        # Form encoded: multipart encoded
        r <- POST(url=url, body = body, encode="multipart",  timeout(10))
  
        dat <- content(r, "text")
        sp <- strsplit(dat, '\n')
        res.table <- data.frame(matrix(nrow=length(sp[[1]])-1, ncol=length(strsplit(sp[[1]][1], '\t')[[1]])))
        colnames(res.table) <- strsplit(sp[[1]][1], '\t')[[1]]
  
        for(i in 2:length(sp[[1]])) {
            res.table[i-1,] <- strsplit(sp[[1]][i], '\t')[[1]]
        }
    }, error=function(e) {
        print(e)
    })
    
    return(res.table)
}
