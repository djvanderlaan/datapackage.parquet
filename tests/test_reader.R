library(datapackage)
library(datapackage.parquet)
source("helpers.R")

data(iris)

dp <- open_datapackage(system.file("example", package = "datapackage.parquet"))

dta <- dp_get_data(dp, "iris")
expect_equal(iris$Sepal.Length, dta$Sepal.Length, attributes = FALSE)
expect_equal(as.integer(iris$Species), dta$Species, attributes = FALSE)
expect_equal(class(dta$Species), "integer")

dta <- dp_get_data(dp, "iris", convert_categories = "to_factor")
attr(dta, "resource") <- NULL
expect_equal(class(dta), "data.frame")
expect_equal(dta, iris, attributes = FALSE)
expect_equal(class(dta$Species), "factor")
expect_equal(levels(dta$Species), levels(iris$Species))


# ============================================
# 

# Generate datapackage
dir <- tempfile()
dp <- new_datapackage(dir, "test")

dta <- data.frame(
    integer = 1:5,
    string = letters[1:5],
    factor = factor(c(1,1,2,1,NA), levels=1:3, labels=LETTERS[1:3]),
    date = as.Date(c("2024-01-01", "2024-01-02", NA, "2024-02-05", "2024-02-06"))
  )
res <- dp_generate_dataresource(dta, "test", format = "parquet")
dp_resources(dp) <- res
arrow::write_parquet(dta, file.path(dir, "test.parquet"))

test <- dp_get_data(dp, "test", convert_categories = "to_factor")
expect_equal(test, dta, attributes = FALSE)

test <- dp_get_data(dp, "test", convert_categories = "to_factor")
expect_equal(test, dta, attributes = FALSE)

test <- dp_get_connection(dp, "test") |> dplyr::collect()
expect_equal(as.data.frame(test), dta, attributes = FALSE)

# ============================================
# Columns are wronf types
dta2 <- dta
dta2$factor <- as.integer(dta2$factor)
for (col in names(dta2)) dta2[[col]] <- as.character(dta2[[col]])
arrow::write_parquet(dta2, file.path(dir, "test.parquet"))

# dp_get_data is more robust; this will also convert string to 
# the correct types
test <- dp_get_data(dp, "test", convert_categories = "no") 
expect_equal(test, dta, attributes = FALSE)

# dpgetdata is more robust; this will also convert string to 
# the correct types
test <- dp_get_data(dp, "test", convert_categories = "to_factor")
expect_equal(test, dta, attributes = FALSE)

# dp_get_connection checks types
expect_error(test <- dp_get_connection(dp, "test") |> dplyr::collect() )

# ============================================
# Wrong column names

dta2 <- dta
names(dta2) <- paste0("foo_", names(dta2))
arrow::write_parquet(dta2, file.path(dir, "test.parquet"))

expect_error(test <- dp_get_data(dp, "test", convert_categories = "no"))
expect_error(test <- dp_get_data(dp, "test", convert_categories = "to_factor"))
expect_error(test <- dp_get_connection(dp, "test") |> dplyr::collect())

# ============================================
# FActor stored as integer
dta2 <- dta
dta2$factor <- as.integer(dta2$factor)
arrow::write_parquet(dta2, file.path(dir, "test.parquet"))

test <- dp_get_data(dp, "test", convert_categories = "no")
expect_equal(test, dta, attributes = FALSE)

test <- dp_get_data(dp, "test", convert_categories = "to_factor")
expect_equal(test, dta, attributes = FALSE)

test <- dp_get_connection(dp, "test") |> dplyr::collect() 
expect_equal(as.data.frame(test), dta, attributes = FALSE)


# Cleanup

ignore <- file.remove(list.files(dir, full.names = TRUE))
ignore <- file.remove(dir)

