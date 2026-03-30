#' calc_rolling_cor

#' @description Calculates rolling correlations on returns of 2 series, takes the returns_df from calc returns and calculates rolling correlation between 2 series and a window based on user's input. Used in rolling beta and in Co-dynamics tab.
#'
#' @return A wide data frame with columns date, rolling_correlation
#'
#' @noRd


calc_rolling_correlation <- function(returns_df, series_a, series_b, window = 60) {

  wide <- returns_df %>%
    dplyr::filter(series %in% c(series_a, series_b)) %>%
    dplyr::select(date, series, daily_return) %>%
    tidyr::pivot_wider(names_from = series, values_from = daily_return) %>%
    dplyr::arrange(date) %>%
    tidyr::drop_na()

  wide %>%
    dplyr::mutate(
      rolling_correlation = slider::slide2_dbl(
        .x = .data[[series_a]],
        .y = .data[[series_b]],
        .f = ~ cor(.x, .y),
        .before = window - 1,
        .complete = TRUE
      )
    ) %>%
    dplyr::select(date,rolling_correlation) %>%
    tidyr::drop_na()
}

