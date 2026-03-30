#' calc_seasonality
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd


calc_seasonality <- function(prices_df, series_name) {

  monthly <- prices_df %>%
    dplyr::filter(series == series_name) %>%
    dplyr::arrange(date) %>%
    tsibble::as_tsibble(key = series, index = date) %>%
    tsibble::group_by_key() %>%
    tsibble::index_by(month_year = ~ tsibble::yearmonth(.)) %>%
    dplyr::summarise(avg_price = mean(value, na.rm = TRUE))

  decomp <- monthly %>%
    fabletools::model(feasts::STL(avg_price ~ season(window = 13))) %>%
    fabletools::components()

  decomp %>%
    tibble::as_tibble() %>%
    dplyr::mutate(
      year  = lubridate::year(as.Date(month_year)),
      month = lubridate::month(as.Date(month_year))
    ) %>%
    dplyr::select(year, month, season_year) %>%
    tidyr::pivot_wider(names_from = month, values_from = season_year) %>%
    tibble::column_to_rownames("year") %>%
    as.matrix()
}
