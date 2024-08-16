library(datapackage)
library(datapackage.parquet)

source("helpers.R")

dp <- opendatapackage(system.file("example", package = "datapackage.parquet"))

data(iris)
iris_orig <- iris

iris1 <- dpgetdata(dp, "iris")
iris$Species <- as.integer(iris$Species)
expect_equal(as.data.frame(iris1), iris, attributes = FALSE)

iris1 <- dpgetdata(dp, "iris", to_factor = TRUE)
expect_equal(as.data.frame(iris1), iris_orig, attributes = FALSE)

# In iris2 data is stores already as factor; this should not matter
iris2 <- dpgetdata(dp, "iris2")
expect_equal(as.data.frame(iris2), iris, attributes = FALSE)

iris2 <- dpgetdata(dp, "iris", to_factor = TRUE)
expect_equal(as.data.frame(iris2), iris_orig, attributes = FALSE)


# Check if connection works
library(dplyr)
con <- dpgetconnection(dp, "iris")
iris3 <- con |> 
  filter(Species == 2, Sepal.Length > 4)  |>
  collect()
iris <- iris[iris$Species == 2 & iris$Sepal.Length > 4, ]
expect_equal(as.data.frame(iris3), iris, attributes = FALSE)

