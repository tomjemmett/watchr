#' Title
#'
#' @param fn
#' @param ...
#' @param delay_time
#'
#' @return
#' @export
#'
#' @examples
watch_files_and_start_task <- function(fn, ..., delay_time = 1) {
  files <- c(...)
  stopifnot("... argument not all characters" = is.character(files))
  fn()
  previous_max_time <- get_max_modified_time(files)
  # main loop
  retry_count <- 0 # in case tasks fail
  repeat {
    # see if any of the files have changed since the last loop iteration
    new_max_time <- get_max_modified_time(files)
    # if files have changed, restart the task
    if (new_max_time > previous_max_time) {
      cli::cli_alert_info("{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}: running function")
      fn()

      previous_max_time <- new_max_time
    }

    Sys.sleep(delay_time)
  }
}
