#' load_data
#'
#' @description A fct function that compiles all thedata needed for this app into a named list. The list will be used throughout the modules to call data needed
#'
#' @return List with data frames
#'
#' @noRd
load_data <- function() {

  cmt_data <- arrow::read_feather(system.file("extdata", "fred_data.feather", package = "GolemT"))

  eia_data <- arrow::read_feather(system.file("extdata", "eia_data.feather", package = "GolemT"))

  prices <- load_dflong()


  return(list(cmt_data = cmt_data, eia_data = eia_data, prices = prices))
}
