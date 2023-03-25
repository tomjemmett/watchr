#' Watch files for changes and run a function
#'
#' When any files that you pass in change, a new R process is started, and the
#' function that is passed in is started in that process. Previously running
#' tasks are killed, so there is only instance of one process running at any
#' given time.
#'
#' @param fn a function to run in a separate process when the files have changed
#' @param ... the files that you want to monitor for changes, see details
#' @param delay_time how often (in seconds) to check for changes to files,
#'     defaults to 1 second
#'
#' @details
#' The files that you want to monitor can either be passed in as vectors
#' of file names, or functions that returns files. It must point to files
#' rather than entire directories, but the files don't necessarily have to
#' exist. The functions are re-evaluated for each loop, so if you want to
#' find all files in a directory you can use a function, see examples.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # watch all of the files in the R directory, and the DESCRIPTION file for
#' # changes, and print a message to the screen.
#' watch_files_and_start_task(
#'   \() print(files have changed),
#'   "DESCRIPTION",
#'   \() dir("R", "*.R")
#' )
#' }
watch_files_and_start_task <- function(fn, ..., delay_time = 1) {
  files <- c(...)

  files_fn <- function() {
    ret <- lapply(files, \(f) {
      if (is.character(f)) {
        return(f)
      }
      if (is.function(f)) {
        return(f())
      }
      stop("Invalid data type")
    })

    unlist(ret)
  }

  task <- list(kill = \() NULL)
  previous_max_time <- -Inf

  repeat {
    new_max_time <- max(
      c(
        previous_max_time,
        fs::file_info(files_fn())$modification_time
      ),
      na.rm = TRUE
    )

    # if files have changed, restart the task
    if (new_max_time > previous_max_time) {
      cli::cli_alert_info(
        paste(
          "{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}:",
          "files changed, restarting task"
        )
      )
      task$kill()
      task <- callr::r_bg(fn)

      previous_max_time <- new_max_time
    }

    # show any output from the task
    while ((output <- task$read_output()) != "") {
      cat(output)
    }
    # show any errors from the task
    while ((error <- task$read_error()) != "") {
      cat(error)
    }

    Sys.sleep(delay_time)
  }
}
