#' build_curve
#'
#' @description Filters the prices of all contracts for a specific date, I will use this for the animations later on in the app
#'
#' @return Snapshot of prices of contracts on a given day.
#'
#' @noRd

build_curve <- function(futures_df, target_date) {
  futures_df %>%
    dplyr::filter(date == target_date) %>%
    dplyr::select(month, price = value) %>%
    dplyr::arrange(month)
}
