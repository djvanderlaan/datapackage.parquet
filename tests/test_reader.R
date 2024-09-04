library(datapackage)
library(datapackage.parquet)
source("helpers.R")

data(iris)

dp <- opendatapackage(system.file("example", package = "datapackage.parquet"))

dta <- dpgetdata(dp, "iris")
expect_equal(iris$Sepal.Length, dta$Sepal.Length, attributes = FALSE)
expect_equal(as.integer(iris$Species), dta$Species, attributes = FALSE)
expect_equal(class(dta$Species), "integer")

dta <- dpgetdata(dp, "iris", to_factor = TRUE)
attr(dta, "resource") <- NULL
expect_equal(class(dta), "data.frame")
expect_equal(dta, iris, attributes = FALSE)
expect_equal(class(dta$Species), "factor")
expect_equal(levels(dta$Species), levels(iris$Species))


# ============================================
# 

# Generate datapackage
dir <- tempfile()
dp <- newdatapackage(dir, "test")

dta <- data.frame(
    integer = 1:5,
    string = letters[1:5],
    factor = factor(c(1,1,2,1,NA), levels=1:3, labels=LETTERS[1:3]),
    date = as.Date(c("2024-01-01", "2024-01-02", NA, "2024-02-05", "2024-02-06"))
  )
res <- dpgeneratedataresource(dta, "test", format = "parquet")
dpresources(dp) <- res
arrow::write_parquet(dta, file.path(dir, "test.parquet"))

test <- dpgetdata(dp, "test", to_factor = FALSE)
expect_equal(test, dta, attributes = FALSE)

test <- dpgetdata(dp, "test", to_factor = TRUE)
expect_equal(test, dta, attributes = FALSE)

test <- dpgetconnection(dp, "test") |> dplyr::collect()
expect_equal(as.data.frame(test), dta, attributes = FALSE)

# ============================================
# Columns are wronf types
dta2 <- dta
dta2$factor <- as.integer(dta2$factor)
for (col in names(dta2)) dta2[[col]] <- as.character(dta2[[col]])
arrow::write_parquet(dta2, file.path(dir, "test.parquet"))

# dpgetdata is more robust; this will also convert string to 
# the correct types
test <- dpgetdata(dp, "test", to_factor = FALSE) 
expect_equal(test, dta, attributes = FALSE)

# dpgetdata is more robust; this will also convert string to 
# the correct types
test <- dpgetdata(dp, "test", to_factor = TRUE)
expect_equal(test, dta, attributes = FALSE)

# dpgetconnection checks types
expect_error(test <- dpgetconnection(dp, "test") |> dplyr::collect() )

# ============================================
# Wrong column names

dta2 <- dta
names(dta2) <- paste0("foo_", names(dta2))
arrow::write_parquet(dta2, file.path(dir, "test.parquet"))

expect_error(test <- dpgetdata(dp, "test", to_factor = FALSE))
expect_error(test <- dpgetdata(dp, "test", to_factor = TRUE))
expect_error(test <- dpgetconnection(dp, "test") |> dplyr::collect())

# ============================================
# FActor stored as integer
dta2 <- dta
dta2$factor <- as.integer(dta2$factor)
arrow::write_parquet(dta2, file.path(dir, "test.parquet"))

test <- dpgetdata(dp, "test", to_factor = FALSE)
expect_equal(test, dta, attributes = FALSE)

test <- dpgetdata(dp, "test", to_factor = TRUE)
expect_equal(test, dta, attributes = FALSE)

test <- dpgetconnection(dp, "test") |> dplyr::collect() 
expect_equal(as.data.frame(test), dta, attributes = FALSE)


# Cleanup

ignore <- file.remove(list.files(dir, full.names = TRUE))
ignore <- file.remove(dir)

