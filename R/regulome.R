#' This function queries Regulome \url{www.regulomedb.org} web-based tool 
#' and returns results in a data frame.
#' 
#' @param query Query (a vector of rsIDs).
#' @param format An output format. 
#' Only \code{full} is currently supported.
#' @param url Regulome url address. 
#' Default: <http://www.regulomedb.org/results>
#' @param verbose Verbosing output. Default: FALSE.
#' @return A data frame (table) or an object with results similar to 
#' Regulome uses.
#' @examples
#' data <- queryRegulome(c("rs4791078","rs10048158"))
#' head(data)
#' @rdname haploR-queryRegulome
#' @export
queryRegulome <- function(query=NULL, 
                          format = "full",
                          url="http://www.regulomedb.org/results",
                          verbose=FALSE) {
  
  if(format != "full") {
    stop("Sorry! Only 'full' output format is supported now.")
  }
  
  # Searching
  qr <- paste(query, collapse='\n')
  encode <- "multipart"
  
  body <- list(data = qr)
  # Form encoded
  # Multipart encoded
  r <- POST(url, body = body, encode = encode)
  bin <- content(r, "raw")
  dat <- readBin(bin, character())
  
  # Download results
  doc.html <- htmlTreeParse(dat, useInternalNodes = TRUE)
  sid <- unlist(xpathApply(doc.html, "//input[@name='sid']", 
                           xmlGetAttr, 'value'))
  url="http://www.regulomedb.org/download/"
  body <- list(format=format, sid = sid)
  # Form encoded
  # Multipart encoded
  r <- POST(url, body = body, encode = encode)
  bin <- content(r, "raw")
  dat <- readBin(bin, character())
  
  ## Parsing output results ##
  sp <- strsplit(dat, '\n')[[1]]
  res.header <- unlist(strsplit(sp[1], '\t'))
  res.rows <- lapply(2:length(sp), 
                     function(n) { unlist(strsplit(sp[n], '\t')) } )
  res.table <- do.call(rbind.data.frame, res.rows)
  colnames(res.table) <- res.header
  
  return(res.table)
}