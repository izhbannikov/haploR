#' This function queries HaploReg web-based tool and returns results.
#' 
#' @param query Query (a vector of rsIDs).
#' @param file A text file (one refSNP ID per line).
#' @param study A particular study. See function \code{getHaploRegStudyList(...)}.
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
#' Default: <https://pubs.broadinstitute.org/mammals/haploreg/haploreg.php>
#' Prefiously was: <http://archive.broadinstitute.org/mammals/haploreg/haploreg.php>
#' @param timeout A \code{timeout} parameter for \code{curl}.
#' Default: 100
#' @param encoding sets the \code{encoding} for correct retrieval web-page content.
#' Default: \code{UTF-8}
#' @param querySNP A flag indicating to return query SNPs only. 
#' Default: \code{FALSE}
#' @param fields A set of fields to extract. Refer to the package vignette 
#' for available fields. Default: \code{All}.
#' @param verbose Verbosing output. Default: FALSE.
#' @return A data frame (table) with results similar to 
#' HaploReg uses.
#' @examples
#' library(haploR)
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
              url=Haploreg.settings[["base.url"]],
              timeout=100,
              encoding="UTF-8",
              querySNP=FALSE,
              fields=NULL,
              verbose=FALSE) {
    
    if(!is.null(query) & !is.null(file))
    {
        stop("'query' and 'file' can not be supplied simultaneously")
    }
    
    recTable <- data.frame(matrix(nrow=0, ncol=35))
    if(!is.null(query))
    {
        if(grepl("chr", query[1])) 
        {
            res <- lapply(1:length(query), function(i) {
                tryCatch({
                    simpleQuery(query=query[i], file=file, study=study, ldThresh=ldThresh, ldPop=ldPop, 
                              epi=epi, cons=cons, genetypes=genetypes, url=url, timeout=timeout,
                              encoding=encoding, querySNP=querySNP, fields=fields, verbose=verbose)
                  
                }, error=function(e){})
            })
            
            recTable <- ldply(res, data.frame)
            #recTable <- do.call(rbind.data.frame, res)
            recTable <- recTable[!duplicated(recTable), ]
        } else {
            recTable <- simpleQuery(query=query, file=file, study=study, ldThresh=ldThresh, ldPop=ldPop, 
                             epi=epi, cons=cons, genetypes=genetypes, url=url, timeout=timeout,
                             encoding=encoding, querySNP=querySNP, fields=fields, verbose=verbose)
            
          
        }
    } else if(!is.null(file)) 
    {
        con <- file(file)
        lines <- readLines(con)
        close(con)
        if(grepl("chr", lines[1]))
        {
            res <- lapply(1:length(lines), function(i) {
                tryCatch({
                    simpleQuery(query=lines[i], file=NULL, study=study, ldThresh=ldThresh, ldPop=ldPop, 
                          epi=epi, cons=cons, genetypes=genetypes, url=url, timeout=timeout,
                          encoding=encoding, querySNP=querySNP, fields=fields, verbose=verbose)
              
                }, error=function(e){})
            })
            recTable <- ldply(res, data.frame)
            recTable <- recTable[!duplicated(recTable), ]
        } 
        else 
        {
            recTable <- simpleQuery(query=query, file=file, study=study, ldThresh=ldThresh, ldPop=ldPop, 
                                  epi=epi, cons=cons, genetypes=genetypes, url=url, timeout=timeout,
                                  encoding=encoding, querySNP=querySNP, fields=fields, verbose=verbose)
          
        }
        
    } else if(!is.null(study))
    {
        recTable <- simpleQuery(query=query, file=file, study=study, ldThresh=ldThresh, ldPop=ldPop, 
                              epi=epi, cons=cons, genetypes=genetypes, url=url, timeout=timeout,
                              encoding=encoding, querySNP=querySNP, fields=fields, verbose=verbose)
      
    } else 
    {
        stop("Parameters 'query', 'study' and 'file' are NULL.")
    }
      
    return(as_tibble(recTable))
}

simpleQuery <- function(query=NULL, file=NULL,
                        study=NULL,
                        ldThresh=0.8, 
                        ldPop="EUR", 
                        epi="vanilla", 
                        cons="siphy", 
                        genetypes="gencode",
                        url=Haploreg.settings[["base.url"]],
                        timeout=100,
                        encoding="UTF-8",
                        querySNP=FALSE,
                        fields=NULL,
                        verbose=FALSE)
{
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
                 ldThresh=ifelse(!is.na(ldThresh), as.character(ldThresh), "1.1"), 
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
                 ldThresh=ifelse(!is.na(ldThresh), as.character(ldThresh), "1.1"), 
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
        r <- POST(url=url, body = body, encode="multipart",  timeout(timeout))
    
        dat <- content(r, "text", encoding=encoding)
        sp <- strsplit(dat, '\n')
        res.table <- data.frame(matrix(nrow=length(sp[[1]])-1, ncol=length(strsplit(sp[[1]][1], '\t')[[1]])), stringsAsFactors = FALSE)
        #res.table <- data.frame(matrix(nrow=length(sp[[1]])-1, ncol=length(strsplit(sp[[1]][1], '\t')[[1]])))
        colnames(res.table) <- strsplit(sp[[1]][1], '\t')[[1]]
    
        for(i in 2:length(sp[[1]])) {
            res.table[i-1,] <- strsplit(sp[[1]][i], '\t')[[1]]
        }
        
    }, error=function(e) {
        print(e)
    })
  
    #Convert numeric-like columns to actual numeric #
    for(i in 1:dim(res.table)[2]) {
        col.num.conv <- suppressWarnings(as.numeric(res.table[,i]))
        #na.rate <- length(which(is.na(col.num.conv)))/length(col.num.conv)
        if(!any(is.na(col.num.conv))) {
            res.table[,i] <- col.num.conv
        }
    }
    
    
    if(querySNP) {
        res.table <- res.table[which(res.table$is_query_snp == 1), ]
    }
  
    if(!is.null(fields)) {
        res.table <- res.table[, fields]
    }
  
    # Removing blank rows:
    res.table <- res.table[, colSums(is.na(res.table)) <= 1] 
    
    # Adding additional columns: 
    user.agent <- "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:33.0) Gecko/20100101 Firefox/33.0"
    body$output <- "html"
    request.data <- POST(url=url, body=body, encode="multipart",  timeout(timeout), user_agent(user.agent))
    html.content <- content(request.data, useInternalNodes=TRUE, encoding="ISO-8859-1",as="text")
    tmp.tables <- readHTMLTable(html.content)
  
    html.table <- NULL
    for(i in 4:length(tmp.tables)) {
        tmp.table <- tmp.tables[[i]]
        if(is.null(tmp.table))
        {
            next
        }
        
        n.col <- dim(tmp.table)[2]
        n.row <- dim(tmp.table)[1]
        
        if(n.col <= 6) 
        {
            next
        } 
    
        if(n.col < 23) {
            while(n.col < 23) {
                tmp.col <- data.frame(replicate(n.row, ""), stringsAsFactors = FALSE)
                colnames(tmp.col) <- paste("V",n.col+1, sep="")
                tmp.table <- cbind(tmp.table, tmp.col)
                n.col <- dim(tmp.table)[2]
            }
        }
    
        if(is.null(html.table)) {
            html.table <- tmp.table
        } else {   
            #print(head(tmp.table))
            colnames(html.table) <- colnames(tmp.table)
            #print("*****")
            #print(head(html.table))
            #print(dim(html.table))
            #print("=====")
            #print(head(tmp.table))
            #print(dim(tmp.table))
            html.table <- rbind(html.table, tmp.table)
        }
    }
  
    if(!is.null(html.table)) {
        tmp.table <- data.frame(html.table[, c(5,13:14)], stringsAsFactors = FALSE)
        tmp.table <- tmp.table[!duplicated(tmp.table), ]
        if("variant" %in% colnames(tmp.table)) {
            data.merged <- merge(res.table, tmp.table, by.x="rsID", by.y="variant")
        } else {
            data.merged <- merge(res.table, tmp.table, by.x="rsID", by.y="V5")
        }
        
        data.merged1 <- cbind(data.merged[["chr"]],
                          data.merged[["pos_hg38"]],
                          data.merged[["r2"]],
                          data.merged[["D'"]],
                          data.merged[["is_query_snp"]],
                          data.merged[["rsID"]],
                          data.merged[["ref"]],
                          data.merged[["alt"]],
                          data.merged[["AFR"]],
                          data.merged[["AMR"]],
                          data.merged[["ASN"]],
                          data.merged[["EUR"]],
                          data.merged[["GERP_cons"]],
                          data.merged[["SiPhy_cons"]],
                          data.merged[["Chromatin_States"]],
                          data.merged[["Chromatin_States_Imputed"]],
                          data.merged[["Chromatin_Marks"]],
                          data.merged[["DNAse"]],
                          data.merged[["Proteins"]],
                          data.merged[["eQTL"]],
                          data.merged[["gwas"]],
                          data.merged[["grasp"]],
                          data.merged[["Motifs"]],
                          data.merged[["GENCODE_id"]],
                          data.merged[["GENCODE_name"]],
                          data.merged[["GENCODE_direction"]],
                          data.merged[["GENCODE_distance"]],
                          data.merged[["RefSeq_id"]],
                          data.merged[["RefSeq_name"]],
                          data.merged[["RefSeq_direction"]],
                          data.merged[["RefSeq_distance"]],
                          data.merged[["dbSNP_functional_annotation"]],
                          data.merged[["query_snp_rsid"]])
        data.merged <- data.frame(data.merged1, data.merged[,34:35], stringsAsFactors = FALSE)
        #data.merged <- cbind(data.merged1, data.merged[,34:35])
    
        colnames(data.merged) <- c("chr", "pos_hg38", "r2", "D'", "is_query_snp", 
                               "rsID", "ref", "alt", "AFR", "AMR", 
                               "ASN", "EUR", "GERP_cons", "SiPhy_cons", 
                               "Chromatin_States",
                               "Chromatin_States_Imputed", "Chromatin_Marks", 
                               "DNAse", "Proteins", "eQTL",
                               "gwas", "grasp", "Motifs", "GENCODE_id", 
                               "GENCODE_name",
                               "GENCODE_direction", "GENCODE_distance", "RefSeq_id", 
                               "RefSeq_name", "RefSeq_direction",
                               "RefSeq_distance", "dbSNP_functional_annotation", 
                               "query_snp_rsid", "Promoter_histone_marks", 
                               "Enhancer_histone_marks")
    
    }
    
    # Make important columns to be numeric
    data.merged[["chr"]] <- as.num(data.merged[["chr"]])
    data.merged[["r2"]] <- as.num(data.merged[["r2"]])
    data.merged[["D'"]] <- as.num(data.merged[["D'"]])
    data.merged[["is_query_snp"]] <- as.num(data.merged[["is_query_snp"]])
    data.merged[["AFR"]] <- as.num(data.merged[["AFR"]])
    data.merged[["AMR"]] <- as.num(data.merged[["AMR"]])
    data.merged[["ASN"]] <- as.num(data.merged[["ASN"]])
    data.merged[["EUR"]] <- as.num(data.merged[["EUR"]])
    
    
    return(data.merged)
}