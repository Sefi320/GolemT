#' calc_returns
#'
#' @description A fct function used to calculate the daily, cumulative, and period returns for a commodity. this will be used for rolling cor, vol, beta, and seasonality
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd


calc_daily_returns <- function(df, method = "log") {
    df %>%
    dplyr::group_by(series) %>%
    dplyr::arrange(date, .by_group = TRUE) %>%
    dplyr::mutate(
      daily_return = if (method == "log") {
        log(value / dplyr::lag(value))
        } else {
          value - dplyr::lag(value)
        }
      ) %>%
      dplyr::ungroup() %>%
      tidyr::drop_na()
  }


# this will be used in each module after calling filter_futures which will become the df to pass into here
