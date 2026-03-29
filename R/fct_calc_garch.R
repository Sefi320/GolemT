#' calc_garch
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd


calc_garch <- function(returns_df, series_name, out = "chart") {

  x <- returns_df %>%
    dplyr::filter(series == series_name) %>%
    dplyr::arrange(date) %>%
    dplyr::select(date, daily_return) %>%
    dplyr::rename(!!series_name := daily_return)

  RTL::garch(x = x, out = out)
}
