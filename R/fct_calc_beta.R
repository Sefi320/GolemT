#' calc_beta
#'
#' @description Runs a rolling regression on returns with a specified window. X is the dependent, and Y is the independent (hedging instrument) i.e CL is Y and RB is X
#'
#' @return Returns dataframe with columns, date and rolling_beta
#'
#' @noRd


calc_rolling_beta <- function(returns_df, series_x, series_y, window = 60) {

  wide <- returns_df %>%
    dplyr::filter(series %in% c(series_x, series_y)) %>%
    dplyr::select(date, series, daily_return) %>%
    tidyr::pivot_wider(names_from = series, values_from = daily_return) %>%
    dplyr::arrange(date) %>%
    tidyr::drop_na()

  wide %>%
    dplyr::mutate(
      rolling_beta = slider::slide2_dbl(
        .x = .data[[series_x]],
        .y = .data[[series_y]],
        .f = ~ coef(lm(.y ~ .x))[2],
        .before = window - 1,
        .complete = TRUE
      )
    ) %>%
    dplyr::select(date, rolling_beta) %>%
    tidyr::drop_na()
}
