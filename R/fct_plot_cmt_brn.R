#' plot_cmt_brn
#'
#' @description Plots BRN front-month price against the 10Y CMT yield to show
#' how Fed rate cycles suppress dollar-denominated oil demand.
#'
#' @return A plotly output
#'
#' @noRd
plot_cmt_brn <- function(brn_prices, cmt_data) {

  y10 <- dplyr::filter(cmt_data, role == "cmt", maturity == 10)

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
    plotly::add_lines(data = brn_prices, x = ~date, y = ~value,
                      name = "BRN", line = list(color = "steelblue", width = 2)) %>%
    plotly::add_lines(data = y10, x = ~date, y = ~price,
                      name = "10Y Yield (%)",
                      line = list(color = "#a78bfa", width = 2, dash = "dot"),
                      yaxis = "y2") %>%
    plotly::layout(
      shapes      = shapes,
      annotations = annotations,
      xaxis       = list(title = ""),
      yaxis       = list(title = "BRN Price (USD)"),
      yaxis2      = list(title = "10Y Yield (%)", overlaying = "y", side = "right"),
      hovermode   = "x unified"
    )
}
