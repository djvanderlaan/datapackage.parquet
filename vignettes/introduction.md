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
functionality for reading data from parquet files.  It also serves as an example
how one can implement additional readers for the `datapackage` package.

First an example on how to use the package:

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

