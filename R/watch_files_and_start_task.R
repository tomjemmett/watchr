#' Title
#'
#' @param task_fn 
#' @param ... 
#' @param delay_time 
#' @param max_retries 
#'
#' @return
#' @export
#'
#' @examples
watch_files_and_start_task <- function(task_fn, ..., delay_time = 1) {
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

    purrr::flatten_chr(ret)
  }

  task <- list(kill = \() NULL)
  previous_max_time <- -Inf

  task_fn <- \() try(task_fn())

  repeat {
    new_max_time <- max(fs::file_info(files_fn())$modification_time)

    # if files have changed, restart the task
    if (new_max_time > previous_max_time) {
      cli::cli_alert_info("{format(Sys.time(), '%Y-%m-%d %H:%M:%S')}: restarting app")
      task$kill()
      task <- callr::r_bg(task_fn)

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
    # check the task is alive, if it isn't increment our retry counter
    if (!task$is_alive()) {
      # if we try to retry the task too many times, exit
      stopifnot("task has failed to start" = retry_count == max_retries)
      retry_count <- retry_count + 1
      previous_max_time <- 0
    } else {
      # reset the retry counter as the task is running
      retry_count <- 0
    }
    
    Sys.sleep(delay_time)
  }
}