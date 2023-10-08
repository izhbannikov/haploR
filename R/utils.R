#' Converts vector of strings to numeric vector
#
#' @param x Input vector of strings.
#' @param na.strings A string which represents \code{NA}.
#' Default: "NA"
#' @return A numeric vector
#' @examples 
#' library(haploR)
#' as.num(c("1", "2", "X"), na.strings="X")
#' @rdname haploR-as.num
#' @export
as.num <- function(x, na.strings = "NA") {
    stopifnot(is.character(x))
    na = x %in% na.strings
    x[na] = 0
    x = as.numeric(x)
    x[na] = NA_real_
    x
}
