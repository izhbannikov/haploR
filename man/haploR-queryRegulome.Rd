% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/regulome.R
\name{queryRegulome}
\alias{queryRegulome}
\title{This function queries RegulomeDB web-based tool 
and returns results in a data frame.}
\usage{
queryRegulome(
  query = NULL,
  genomeAssembly = "GRCh37",
  limit = 1000,
  timeout = 100
)
}
\arguments{
\item{query}{Query (a vector of rsIDs or exact one query region in rsid or like "chr1:39492461-39492462").}

\item{genomeAssembly}{Genome assembly built: can be GRCh37 (default) or GRCh38.}

\item{limit}{It controls how many variants will be queried and returned for a large region. It can be a number (1000 by default) or "all". 
Please note that large number or "all" may get yourself hurt because you could get timeout or may even crash the server.}

\item{timeout}{A \code{timeout} parameter for \code{httr::GET}.
Default: 100}
}
\value{
a data frame (table)
OR
a list with the following items:
- guery_coordinates
- features
- regulome_score
- variants
- nearby_snps,
- assembly
}
\description{
This function queries RegulomeDB web-based tool 
and returns results in a data frame.
}
\examples{
data <- queryRegulome(c("rs4791078","rs10048158"))
head(data)
}
