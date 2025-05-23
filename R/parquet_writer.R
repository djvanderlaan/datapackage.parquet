#' Write the data of a Data Resource to a parquet file
#'
#' @param x \code{data.frame} with the data to write.
#' 
#' @param resource_name name of the Data Resource in the Data Package.
#'
#' @param datapackage the Data Package to which the file should be written.
#'
#' @param ... passed on to \code{\link[arrow]{write_parquet}}. 
#'
#' @details
#' Generally used by calling \code{\link[datapackage]{dp_write_data}} from the
#' 'datapackage' package.
#'
#' When the 'datapackage.parquet' package is loaded the writer for parquet
#' files is registered with the 'datapackage' package. Therefore, when using
#' \code{\link[datapackage]{dp_write_data}} to write the data for a data
#' resource for which the data is stored in a parquet file the correct writeer
#' is automatically used.
#'
#' @return
#' The function doesn't return anything. It is called for it's side effect of
#' creating CSV-files in the directory of the data package.
#'
#' @export 
parquet_writer <- function(x, resource_name, datapackage, ...) {
  dataresource <- datapackage::dp_resource(datapackage, resource_name)
  if (is.null(dataresource)) 
    stop("Data resource '", resource_name, "' does not exist in data package")
  # First check to see of dataresourc fits data
  datapackage::dp_check_dataresource(x, dataresource = dataresource, throw = TRUE)
  # Get location
  path <- datapackage::dp_path(dataresource, full_path = TRUE)
  if (is.null(path)) stop("Path is missing in dataresource.")
  # If create directories in datapackage
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  # Write
  arrow::write_parquet(x, sink = path, ...)
}


