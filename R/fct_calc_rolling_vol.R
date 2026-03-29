#' calc_rolling_vol
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd


calc_rolling_vol <- function(returns_df, window = 30) {
  returns_df %>%
    dplyr::group_by(series) %>%
    dplyr::arrange(date, .by_group = TRUE) %>%
    dplyr::mutate(
      rolling_vol = slider::slide_dbl(
        daily_return,
        ~ sd(.x, na.rm = TRUE) * sqrt(252),
        .before = window - 1,
        .complete = TRUE
      )
    ) %>%
    dplyr::ungroup() %>%
    tidyr::drop_na()
}

