
#' Read the parquet data for a Data Resource
#' 
#' @param path path to the data set. 
#' 
#' @param resource a Data Resource.
#' @param to_factor convert columns to factor if the schema has a categories
#'   field for the column. Passed on to \code{\link{dpapplyschema}}.
#' @param as_connection reaturn an arrow connection to the parquet files instead
#'   of the data itself.
#' @param ... additional arguments are passed on to \code{\link[arrow]{read_parquet}}.
#'
#' @seealso
#' Generally used by calling \code{\link{dpgetdata}} from the
#' \code{datapackage} package.
#'
#' When the \code{datapackage.parquet} package is loaded the reader for parquet
#' files is registered with the \code{datapackage} package. Therefore, when
#' using \code{dpgetdata} to get the data for a data resource for which the data
#' is stored in a parquet file the correct reader is automatically used.
#'
#' @return
#' Returns a \code{data.frame} with the data or when \code{as_connection = TRUE}
#' an Arrow Table.
#'
#' @import datapackage
#' @export
parquet_reader <- function(path, resource, to_factor = FALSE, as_connection = FALSE, ...) {
  schema <- datapackage::dpschema(resource)
  if (is.null(schema)) {
    dta <- arrow::open_dataset(path, ...)
    if (!as_connection) {
      dta <- as.data.frame(dta)
      class(dta) <- "data.frame"
    }
  } else {
    dta <- arrow::open_dataset(path, ...)
    if (!as_connection) dta <- as.data.frame(dta)
    if (as_connection) {
      # Check if parquet file is valid; we only read the first few records this 
      # should catch most errors list wrong types and fields
      tmp <- utils::head(dta) |> as.data.frame()
      # Then we check these records; note that this will not catch all errors as, for
      # example fields not read in can be invalid; this is mainly the case when 
      # checking contraints, therefore we will not check these as this would give a 
      # false sense of safety
      check <- datapackage::dpcheckdataresource(tmp, resource, constraints = FALSE)
      if (!isTRUE(check)) stop(check)
    } else {
      dta <- datapackage::dpapplyschema(dta, resource, to_factor = to_factor)
      class(dta) <- "data.frame"
    }
  }
  structure(dta, resource = resource)
}

