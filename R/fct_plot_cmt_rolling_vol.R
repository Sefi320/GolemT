#' plot_cmt_rolling_vol
#'
#' @description Rolling volatility of daily yield changes for the 2Y and 10Y
#' CMT tenors, with Fed policy event markers.
#'
#' @return A plotly output
#'
#' @noRd
plot_cmt_rolling_vol <- function(cmt_data, window = 60) {

  vol <- cmt_data %>%
    dplyr::filter(role == "cmt", maturity %in% c(2, 10)) %>%
    dplyr::select(date, maturity, price) %>%
    dplyr::arrange(maturity, date) %>%
    dplyr::group_by(maturity) %>%
    dplyr::mutate(
      change      = price - dplyr::lag(price),
      label       = paste0(maturity, "Y"),
      rolling_vol = slider::slide_dbl(change, ~sd(.x, na.rm = TRUE),
                                      .before = window - 1, .complete = TRUE)
    ) %>%
    dplyr::filter(!is.na(rolling_vol)) %>%
    dplyr::ungroup()

  events <- market_events %>%
    dplyr::filter(stringr::str_detect(commodities, "CMT"))

  shapes <- purrr::map(seq_len(nrow(events)), function(i) {
    list(
      type = "line",
      x0   = events$date[i], x1 = events$date[i],
      y0   = 0, y1 = 1, yref = "paper",
      line = list(color = "firebrick", dash = "dash", width = 1)
    )
  })

  annotations <- purrr::map(seq_len(nrow(events)), function(i) {
    list(
      x         = events$date[i], y = 1, yref = "paper",
      text      = events$event[i], showarrow = FALSE,
      textangle = -90, xanchor = "right",
      font      = list(size = 9, color = "firebrick")
    )
  })

  plotly::plot_ly(vol, x = ~date, y = ~rolling_vol, color = ~label,
                  type = "scatter", mode = "lines",
                  colors = c("2Y" = "#f59e0b", "10Y" = "steelblue")) %>%
    plotly::layout(
      shapes      = shapes,
      annotations = annotations,
      xaxis       = list(title = ""),
      yaxis       = list(title = "Rolling Yield Volatility (% pts)"),
      hovermode   = "x unified"
    )
}
