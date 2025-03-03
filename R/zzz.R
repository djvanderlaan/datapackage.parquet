
.onLoad <- function(libname, pkgname) {
  datapackage::dp_add_reader("parquet", parquet_reader, 
    mediatypes = "application/x-parquet",
    extensions = "parquet")
  datapackage::dp_add_writer("parquet", parquet_writer)
}

