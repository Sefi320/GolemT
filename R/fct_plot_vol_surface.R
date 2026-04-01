#' plot_vol_surface
#'
#' @description Plots the 3D volatilty surface for chosen months. I will use this to show the difference in vol between contracts close to expiry vs further away
#'
#' @return A plotly surface
#'
#' @noRd


plot_vol_surface <- function(prices_df, cmdty, contracts = c(1:6, 34:36), window = 30, method = "log", start, end) {

  vol_df <- prices_df %>%
    filter_futures(cmdty, contracts = contracts) %>%
    dplyr::filter(date >= start, date <= end) %>%
    calc_daily_returns(method = method) %>%
    calc_rolling_vol(window = window)

  vol_wide <- vol_df %>%
    dplyr::select(date, month, rolling_vol) %>%
    tidyr::pivot_wider(names_from = month, values_from = rolling_vol) %>%
    dplyr::arrange(date)

  z_matrix <- vol_wide %>%
    dplyr::select(-date) %>%
    as.matrix()

  plotly::plot_ly(
    x = as.integer(colnames(z_matrix)),
    y = vol_wide$date,
    z = z_matrix,
    type = "surface"
  ) %>%
    plotly::layout(
      scene = list(
        xaxis = list(title = "Contract Month"),
        yaxis = list(title = "Date"),
        zaxis = list(title = "Annualised Vol")
      )
    )
}
