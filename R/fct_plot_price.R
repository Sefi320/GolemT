#' plot_price
#'
#' @description A fct function to plot the front month contract historical prices
#'
#' @return A plotly output
#'
#' @noRd
#'
#'
#'
#'

plot_price <- function(x, cmdty = "CL") {

  events <- market_events %>%
    dplyr::filter(stringr::str_detect(commodities, paste0(cmdty, "|All")))

  shapes <- purrr::map(seq_len(nrow(events)), function(i) {
    list(
      type  = "line",
      x0    = events$date[i],
      x1    = events$date[i],
      y0    = 0,
      y1    = 1,
      yref  = "paper",
      line  = list(color = "firebrick", dash = "dash", width = 1)
    )
  })

  annotations <- purrr::map(seq_len(nrow(events)), function(i) {
    list(
      x          = events$date[i],
      y          = 1,
      yref       = "paper",
      text       = events$event[i],
      showarrow  = FALSE,
      textangle  = -90,
      xanchor    = "right",
      font       = list(size = 9, color = "firebrick")
    )
  })

  x %>%
    plotly::plot_ly(x = ~date, y = ~value, type = "scatter", mode = "lines",
                    line = list(color = "steelblue")) %>%
    plotly::layout(
      shapes      = shapes,
      annotations = annotations,
      xaxis       = list(title = ""),
      yaxis       = list(title = "Price")
    ) %>%
    return()
}
