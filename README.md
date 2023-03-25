
# `{watchr}`

<!-- badges: start -->
[![R-CMD-check](https://github.com/tomjemmett/watchr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/tomjemmett/watchr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`{watchr}` provides functions for watching files and then running code whenever
those files change.

## Installation

You can install the development version of `{watchr}` from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("tomjemmett/watchr")
```

## Usage

There are two functions, `watch_files_and_run_function` and `watch_files_and_start_task`.

Both functions take the same arguments, but the difference is the former runs the function
in the same R process, so the check for files changing is blocked until the function
completes. The latter starts running a task in the background, the task is killed and
restarted each time the files change.

The task function is designed for long running tasks, e.g. running a shiny application.

The files which you want to monitor are passed into the `...` argument. This allows you to
pass in lists of files, or functions that return lists of files.

For example, you could monitor the files in the `R/` directory, and the `DESCRIPTION` file
like so:

``` r
watch_files_and_run_function(
  \() print("files changed"),
  "DESCRIPTION",
  dir("R/", pattern = "*.R")
)
```

However, if we were to add files to the `R/` directory, these wont be detected until we
restart the watch function. Instead, you could pass in an anonymous function to run the
`dir` function every time the watch function runs, like so:

``` r
watch_files_and_run_function(
  \() print("files changed"),
  "DESCRIPTION",
  \() dir("R/", pattern = "*.R")
)
```