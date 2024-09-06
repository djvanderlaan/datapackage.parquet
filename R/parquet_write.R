
#' Write the data of a Data Resource to a parquet file
#'
#' @param x \code{data.frame} with the data to write.
#' 
#' @param resourcename name of the Data Resource in the Data Package.
#'
#' @param datapackage the Data Package to which the file should be written.
#'
#' @param ... passed on to \code{arrow::write_parquet}. 
#'
#' @details
#' Generally used by calling \code{\link{dpwritedata}} from the
#' \code{datapackage} package.
#'
#' When the \code{datapackage.parquet} package is loaded the writer for parquet
#' files is registered with the \code{datapackage} package. Therefore, when
#' using \code{dpwritedata} to write the data for a data resource for which the
#' data is stored in a parquet file the correct writeer is automatically used.
#'
#' @return
#' The function doesn't return anything. It is called for it's side effect of
#' creating CSV-files in the directory of the data package.
#'
#' @export 
parquet_write <- function(x, resourcename, datapackage, ...) {
  dataresource <- datapackage::dpresource(datapackage, resourcename)
  if (is.null(dataresource)) 
    stop("Data resource '", resourcename, "' does not exist in data package")
  # First check to see of dataresourc fits data
  datapackage::dpcheckdataresource(x, dataresource = dataresource, throw = TRUE)
  # Get location
  path <- datapackage::dppath(dataresource, fullpath = TRUE)
  if (is.null(path)) stop("Path is missing in dataresource.")
  # Write
  arrow::write_parquet(x, sink = path, ...)
}


