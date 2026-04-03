#' plot_rate_cycle
#'
#' @description Plots 2Y and 10Y CMT yields over time with Fed policy event markers.
#'
#' @return A plotly output
#'
#' @noRd
plot_rate_cycle <- function(cmt_data) {

  y10 <- dplyr::filter(cmt_data, role == "cmt", maturity == 10)
  y2  <- dplyr::filter(cmt_data, role == "cmt", maturity == 2)

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

  plotly::plot_ly() %>%
    plotly::add_lines(data = y10, x = ~date, y = ~price,
                      name = "10Y", line = list(color = "steelblue", width = 2)) %>%
    plotly::add_lines(data = y2, x = ~date, y = ~price,
                      name = "2Y", line = list(color = "#f59e0b", width = 2)) %>%
    plotly::layout(
      shapes      = shapes,
      annotations = annotations,
      xaxis       = list(title = ""),
      yaxis       = list(title = "Yield (%)"),
      hovermode   = "x unified"
    )
}
