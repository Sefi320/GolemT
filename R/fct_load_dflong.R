#' load_dflong
#'
#' @description A fct function that loads the dflong from RTL, transforms it, and feeds it globally to the app
#'
#' @return Returns a data frame.
#'
#' @noRd
#'
#'
load_dflong <- function() {

  df <- RTL::dflong

  return(df)
}
