
  get_modified_time <- function(file) {
    max(fs::file_info(files)$modification_time)
  }