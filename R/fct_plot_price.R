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
plot_price <- function(x, cmdty = "CL", dxy = NULL) {

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

  p <- x %>%
    plotly::plot_ly(x = ~date, y = ~value, type = "scatter", mode = "lines",
                    name = cmdty,
                    line = list(color = "steelblue")) %>%
    plotly::layout(
      shapes      = shapes,
      annotations = annotations,
      xaxis       = list(title = ""),
      yaxis       = list(title = "Price")
    )

  if (!is.null(dxy)) {
    p <- p %>%
      plotly::add_lines(
        data = dxy,
        x = ~date, y = ~price,
        name = "DXY",
        line = list(color = "#f59e0b", dash = "dot"),
        yaxis = "y2"
      ) %>%
      plotly::layout(
        yaxis2 = list(title = "DXY", overlaying = "y", side = "right")
      )
  }

  return(p)
}
