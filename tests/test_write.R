library(datapackage)
library(datapackage.parquet)

source("helpers.R")


dir <- tempfile()


dta <- data.frame(
  int = c(1L, 2L, NA_integer_, 4L, 5L),
  num = c(1.3, 1.6, 2.0, 1E10, NA),
  factor = factor(c(NA, NA, 2, 1, 2), levels = 1:3, labels = LETTERS[1:3]),
  date = as.Date("2024-01-01") + c(1, NA, 2, 4, 5)
  )

res <- dpgeneratedataresource(dta, "name", format = "parquet")

dp <- newdatapackage(dir)

dpresources(dp) <- res

# Write the data
dpwritedata(dpresource(dp, "name"), data = dta)

# Read back in and check if we gat the original data back
tmp <- dp |> dpresource("name") |> dpgetdata(to_factor = TRUE)
expect_equal(tmp, dta, attributes = FALSE)
expect_equal(levels(tmp$factor), c("A", "B", "C"))

# Read back in and check if we gat the original data back
tmp <- dp |> dpresource("name") |> dpgetdata(to_factor = FALSE)
expect_equal(tmp, dta, attributes = FALSE)
expect_equal(levels(tmp$factor), NULL)

# Try to write invalid data
dta2 <- dta
dta2$factor <- as.character(dta2$factor)
expect_error(dpwritedata(dpresource(dp, "name"), data = dta2))

# Try to write invalid data
dta2 <- dta
dta2$date <- as.integer(dta2$date)
expect_error(dpwritedata(dpresource(dp, "name"), data = dta2))

# Empry dataset
dta2 <- dta[FALSE,]
dpwritedata(dpresource(dp, "name"), data = dta2)
tmp <- dp |> dpresource("name") |> dpgetdata(to_factor = FALSE)
expect_equal(tmp, dta2, attributes = FALSE)
expect_equal(levels(tmp$factor), NULL)
tmp <- dp |> dpresource("name") |> dpgetdata(to_factor = TRUE)
expect_equal(tmp, dta2, attributes = FALSE)
expect_equal(levels(tmp$factor), c("A", "B", "C"))

# Cleanup
ignore <- file.remove(list.files(dir, full.names = TRUE))
ignore <- file.remove(dir)

