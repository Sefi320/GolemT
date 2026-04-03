#' plot_storage_seasonality
#'
#' @description Plot EIA inventory/storage vs a rolling 5-year seasonal average band.
#'
#' @return A plotly chart
#'
#' @noRd
plot_storage_seasonality <- function(eia_data, role,
                                     y_label       = "Value",
                                     display_start = 2018) {

  df <- eia_data %>%
    dplyr::filter(role == !!role) %>%
    dplyr::mutate(
      year = lubridate::year(date),
      week = lubridate::week(date)
    )


  lookup <- df %>% dplyr::select(year, week, value)

  rolling_ref <- df %>%
    dplyr::filter(year >= display_start) %>%
    dplyr::select(date, year, week) %>%
    tidyr::crossing(lag = 1:5) %>%
    dplyr::mutate(ref_year = year - lag) %>%
    dplyr::left_join(
      lookup %>% dplyr::rename(ref_year = year, ref_value = value),
      by = c("ref_year", "week")
    ) %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(
      avg_5yr = mean(ref_value, na.rm = TRUE),
      min_5yr = min(ref_value, na.rm = TRUE),
      max_5yr = max(ref_value, na.rm = TRUE),
      .groups = "drop"
    )

  display <- df %>%
    dplyr::filter(year >= display_start) %>%
    dplyr::left_join(rolling_ref, by = "date")

  plotly::plot_ly(display, x = ~date) %>%
    plotly::add_ribbons(
      ymin      = ~min_5yr,
      ymax      = ~max_5yr,
      fillcolor = "rgba(70, 130, 180, 0.20)",
      line      = list(color = "transparent"),
      name      = "5-Yr Range",
      hoverinfo = "skip"
    ) %>%
    plotly::add_lines(
      y    = ~avg_5yr,
      line = list(color = "rgba(70, 130, 180, 0.75)", dash = "dash", width = 1.5),
      name = "5-Yr Avg"
    ) %>%
    plotly::add_lines(
      y    = ~value,
      line = list(color = "steelblue", width = 2),
      name = y_label
    ) %>%
    plotly::layout(
      xaxis     = list(title = ""),
      yaxis     = list(title = y_label),
      legend    = list(orientation = "h", x = 0, y = 1.08),
      hovermode = "x unified"
    )
}
