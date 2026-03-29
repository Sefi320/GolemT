#' filter_futures
#'
#' @description A fct function that filters that dflong dataframe by commodity and by front month contract
#'
#' @return Returns filtered df of front month contract for prce plots
#'
#' @noRd



filter_futures <- function(prices, cmdty = "CL", contracts = NULL) {

  x <- prices %>%
    dplyr::filter(stringr::str_detect(series, paste0("^", cmdty))) %>%
    dplyr::mutate(month = as.integer(stringr::str_extract(series, "[0-9]+")))

  if (!is.null(contracts)) {
    x <- x %>% dplyr::filter(month %in% contracts)
  }

  return(x)
}
