get_modified_time <- function(file) {
  max(fs::file_info(file)$modification_time)
}
