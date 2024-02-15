<!--
%\VignetteEngine{simplermarkdown::mdweave_to_html}
%\VignetteIndexEntry{Reading parquet files from Data Packages}
-->

`datapackage.parquet` is an extension for the 
[`datapackage` R package](https://github.com/djvanderlaan/datapackage)
that adds functionality for reading data from parquet files. It also
serves as an example how one can implement additional readers for the
`datapackage` package.

First an example on how to use the package:

``` R
> library(datapackage)
> library(datapackage.parquet)
```

When loading the `datapackage.parquet` package it registers a reader for
Data Resources with a format `parquet` or extension `parquet`. One of
the example resources in the package uses this format:

``` R
> dp <- opendatapackage(system.file("example", package = "datapackage.parquet"))
```

To get the data one can simply do:

``` R
> iris <- dpgetdata(dp, "iris")
> iris |> head()
  Sepal.Length Sepal.Width Petal.Length Petal.Width Species
1          5.1         3.5          1.4         0.2       1
2          4.9         3.0          1.4         0.2       1
3          4.7         3.2          1.3         0.2       1
4          4.6         3.1          1.5         0.2       1
5          5.0         3.6          1.4         0.2       1
6          5.4         3.9          1.7         0.4       1
```

Or, to get the variables with a code list as a factor

``` R
> iris <- dpgetdata(dp, "iris", to_factor = TRUE)
> iris |> head()
  Sepal.Length Sepal.Width Petal.Length Petal.Width Species
1          5.1         3.5          1.4         0.2  setosa
2          4.9         3.0          1.4         0.2  setosa
3          4.7         3.2          1.3         0.2  setosa
4          4.6         3.1          1.5         0.2  setosa
5          5.0         3.6          1.4         0.2  setosa
6          5.4         3.9          1.7         0.4  setosa
```

Finally, it is also possible to get a connection to the parquet file.
This returns an an Arrow Tabular object. For this type of object
operations from the `dplyr` package are defined. For more information
see the [Apache Arrow site](https://arrow.apache.org/). An example:

``` R
> library(dplyr)

Attaching package: ‘dplyr’

 
The following objects are masked from ‘package:stats’:

    filter, lag

 
The following objects are masked from ‘package:base’:

    intersect, setdiff, setequal, union

 
> iris <- dpgetconnection(dp, "iris")
> iris |> 
+   filter(Species == 2, Sepal.Length > 4) |> 
+   mutate(ratio = Sepal.Length/Sepal.Width) |>
+   collect()
# A tibble: 50 × 6
   Sepal.Length Sepal.Width Petal.Length Petal.Width Species ratio
          <dbl>       <dbl>        <dbl>       <dbl>   <int> <dbl>
 1          7           3.2          4.7         1.4       2  2.19
 2          6.4         3.2          4.5         1.5       2  2   
 3          6.9         3.1          4.9         1.5       2  2.23
 4          5.5         2.3          4           1.3       2  2.39
 5          6.5         2.8          4.6         1.5       2  2.32
 6          5.7         2.8          4.5         1.3       2  2.04
 7          6.3         3.3          4.7         1.6       2  1.91
 8          4.9         2.4          3.3         1         2  2.04
 9          6.6         2.9          4.6         1.3       2  2.28
10          5.2         2.7          3.9         1.4       2  1.93
# ℹ 40 more rows
```
