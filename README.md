<!--
%\VignetteEngine{simplermarkdown::mdweave_to_html}
%\VignetteIndexEntry{Reading parquet files from Data Packages}
-->

`datapackage.parquet` is an extension for the `datapackage` R package
that adds functionality for reading data from parquet files and writing
data to parquet files. It also serves as an example how one can
implement additional readers for the `datapackage` package.

## Reading data

First an example on how to use the package to read from a Data Package:

``` r
> library(datapackage)
> library(datapackage.parquet)
```

When loading the `datapackage.parquet` package it registers a reader for
Data Resources with a format `parquet` or extension `parquet`. One of
the example resources in the package uses this format:

``` r
> dp <- open_datapackage(system.file("example", 
+         package = "datapackage.parquet"))
```

To get the data one can simply do:

``` r
> iris <- dp_get_data(dp, "iris")
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

``` r
> iris <- dp_get_data(dp, "iris", convert_categories = "to_factor")
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

``` r
> library(dplyr)

Attaching package: ‘dplyr’

 
The following objects are masked from ‘package:stats’:

    filter, lag

 
The following objects are masked from ‘package:base’:

    intersect, setdiff, setequal, union

 
> iris <- dp_get_connection(dp, "iris")
> iris |> 
+   filter(Species == 2, Sepal.Length > 4) |> 
+   mutate(ratio = Sepal.Length/Sepal.Width) |>
+   collect()
# A tibble: 50 × 6
   Sepal.Length Sepal.Width Petal.Length Petal.Width Species ratio
 *        <dbl>       <dbl>        <dbl>       <dbl>   <int> <dbl>
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

## Writing data

When loading the package is also registers a writer for parquet files.
Therefore, when writing data for a Data Resource and the resource has
‘parquet’ as its format, it will use `write_parquet` to write the file.

As an example let’s create a Data Package with the `chickwts` dataset:

``` r
> dir <- tempfile()
> dp <- new_datapackage(dir, "chickwts")
```

We create the resource as regular, but specify `format = "parquet"`:

``` r
> data(chickwts)
> res <- dp_generate_dataresource(chickwts, name = "chickwts", 
+   format = "parquet")
> dp_title(res) <- "Chicken Weights by Feed Type"
> res
[chickwts] Chicken Weights by Feed Type

Selected properties:
path     :"chickwts.parquet"
format   :"parquet"
mediatype:"application/x-parquet"
encoding :"utf-8"
schema   :Table Schema [2] "weight" "feed"
```

As we can see by specifying the format both the format and the mediatype
are set to the correct values for parquet files.

Let’s add the resource to the Data Package

``` r
> dp_resources(dp) <- res
> dp
[chickwts] 

Location: </tmp/RtmpbKC30q/file2247e432b33ab6>
Resources:
[chickwts] Chicken Weights by Feed Type
```

We can now write the data set:

``` r
> dp_write_data(dp_resource(dp, "chickwts"), chickwts)
```

This results in a parquet file:

``` r
> list.files(dir)
[1] "chickwts.parquet" "datapackage.json"
```

Whick we can read back in using `dp_get_data`:

``` r
> dp_resource(dp, "chickwts") |> dp_get_data() |> head()
  weight feed
1    179    2
2    160    2
3    136    2
4    227    2
5    217    2
6    168    2
```

And if we want the categorical variables as factor:

``` r
> dp_resource(dp, "chickwts") |> dp_get_data(convert_categories = "to_factor") |> head()
  weight      feed
1    179 horsebean
2    160 horsebean
3    136 horsebean
4    227 horsebean
5    217 horsebean
6    168 horsebean
```
