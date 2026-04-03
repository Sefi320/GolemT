#' plot_seasonality
#'
#' @description Takes matrix input from calc seaonality and plots it using plotly heatmap
#'
#' @return Heatmap by plotly
#'
#' @noRd


plot_seasonality <- function(seasonality_matrix) {

  plotly::plot_ly(
    z          = seasonality_matrix,
    x          = colnames(seasonality_matrix),
    y          = rownames(seasonality_matrix),
    type       = "heatmap",
    colorscale = "RdBu",
    reversescale = FALSE
  ) %>%
    plotly::layout(
      xaxis = list(title = "Month"),
      yaxis = list(title = "Year")
    )
}
