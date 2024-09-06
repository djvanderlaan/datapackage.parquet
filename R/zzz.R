
.onLoad <- function(libname, pkgname) {
  datapackage::dpaddreader("parquet", parquet_reader, 
    mediatypes = "application/x-parquet",
    extensions = "parquet")
  datapackage::dpaddwriter("parquet", parquet_write)
}

