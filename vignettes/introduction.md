<!--
%\VignetteEngine{simplermarkdown::mdweave_to_html}
%\VignetteIndexEntry{Reading parquet files from Data Packages}
-->

---
title: Reading parquet data from Data Packages
author: Jan van der Laan
css: "style.css"
---

`datapackage.parquet` is an extension for the `datapackage` R package that adds
functionality for reading data from parquet files and writing data to parquet
files.  It also serves as an example how one can implement additional readers
for the `datapackage` package.

## Reading data

First an example on how to use the package to read from a Data Package:

```{.R}
library(datapackage)
library(datapackage.parquet)
```

When loading the `datapackage.parquet` package it registers a reader for Data
Resources with a format `parquet` or extension `parquet`. One of the example
resources in the package uses this format:

```{.R}
dp <- opendatapackage(system.file("example", package = "datapackage.parquet"))
```

To get the data one can simply do:
```{.R}
iris <- dpgetdata(dp, "iris")
iris |> head()
```
Or, to get the variables with a code list as a factor
```{.R}
iris <- dpgetdata(dp, "iris", to_factor = TRUE)
iris |> head()
```
Finally, it is also possible to get a connection to the parquet file. This
returns an an Arrow Tabular object. For this type of object operations from the
`dplyr` package are defined. For more information see the 
[Apache Arrow site](https://arrow.apache.org/). An example: 
```{.R}
library(dplyr)
iris <- dpgetconnection(dp, "iris")
iris |> 
  filter(Species == 2, Sepal.Length > 4) |> 
  mutate(ratio = Sepal.Length/Sepal.Width) |>
  collect()
```

## Writing data

When loading the package is also registers a writer for parquet files.
Therefore, when writing data for a Data Resource and the resource has 'parquet'
as its format, it will use `write_parquet` to write the file.

As an example let's create a Data Package with the `chickwts` dataset:

```{.R}
dir <- tempfile()
dp <- newdatapackage(dir, "chickwts")
```

We create the resource as regular, but specify `format = "parquet"`:
```{.R}
data(chickwts)
res <- dpgeneratedataresource(chickwts, name = "chickwts", 
  format = "parquet")
dptitle(res) <- "Chicken Weights by Feed Type"
res
```
As we can see by specifying the format both the format and the mediatype are set
to the correct values for parquet files.

Let's add the resource to the Data Package
```{.R}
dpresources(dp) <- res
dp
```
We can now write the data set:

```{.R}
dpwritedata(dpresource(dp, "chickwts"), chickwts)
```

This results in a parquet file:
```{.R}
list.files(dir)
```

Whick we can read back in using `dpgetdata`:
```{.R}
dpresource(dp, "chickwts") |> dpgetdata() |> head()
```
And if we want the categorical variables as factor:
```{.R}
dpresource(dp, "chickwts") |> dpgetdata(to_factor = TRUE) |> head()
```




