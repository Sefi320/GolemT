#' plot_seasonality
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd


plot_seasonality <- function(seasonality_matrix) {

  plotly::plot_ly(
    z          = seasonality_matrix,
    x          = colnames(seasonality_matrix),
    y          = rownames(seasonality_matrix),
    type       = "heatmap",
    colorscale = "RdYlGn",
    reversescale = FALSE
  ) %>%
    plotly::layout(
      xaxis = list(title = "Month"),
      yaxis = list(title = "Year")
    )
}
