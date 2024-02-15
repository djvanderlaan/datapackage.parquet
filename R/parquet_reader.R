
#' Read the paquet data for a Data Resource
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
#' Generally used by calling \code{\link{dpgetdata}}.
#'
#' @return
#' Returns a \code{data.frame} with the data or when \code{as_connection = TRUE}
#' an Arrow Table.
#'
#' @import datapackage
#' @export
parquet_reader <- function(path, resource, to_factor = FALSE, as_connection = FALSE, ...) {
  schema <- dpschema(resource)
  if (is.null(schema)) {
    dta <- arrow::read_parquet(path, as_data_frame = !as_connection, ...)
  } else {
    dta <- arrow::read_parquet(path, as_data_frame = !as_connection, ...)
    if (as_connection) {
      # Check if parquet file is valid
      # First try to convert the first few rows; this should already catch quite a few
      # possiblee issues; e.g. levels of factor not matching code list
      tmp <- dta$Take(1) |> as.data.frame()
      tmp <- dpapplyschema(tmp, resource, to_factor = to_factor)
      # However, we also want an integer column to be numeric etc. dpapplyschema will
      # accept character for most fields.
      for (fieldname in dpfieldnames(schema)) {
        field <- dpfield(schema, fieldname)
        type  <- dpproperty(field, "type")
        class <- class(tmp[[fieldname]])
        if (is.factor(tmp[[fieldname]]) && !is.null(dpproperty(field, "codelist"))) {
          # this is ok
        } else if (type == "boolean") {
          if (!methods::is(tmp[[fieldname]], "logical"))
            stop("Field '", fieldname, "' is of wrong type. Should be a logical")
        } else if (type == "date") {
          if (!methods::is(tmp[[fieldname]], "Date"))
            stop("Field '", fieldname, "' is of wrong type. Should be a Date.")
        } else if (type == "integer") {
          if (!methods::is(tmp[[fieldname]], "integer"))
            stop("Field '", fieldname, "' is of wrong type. Should be an integer.")
        } else if (type == "number") {
          if (!methods::is(tmp[[fieldname]], "numeric"))
            stop("Field '", fieldname, "' is of wrong type. Should be an numeric")
        } else if (type == "string") {
          if (!methods::is(tmp[[fieldname]], "character"))
            stop("Field '", fieldname, "' is of wrong type. Should be an character")
        }
      }
    } else {
      dta <- dpapplyschema(dta, resource, to_factor = to_factor)
    }
  }
  structure(dta, resource = resource)
}

