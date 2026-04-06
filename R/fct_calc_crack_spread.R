#' calc_crack_spread
#'
#' @description Computes the 3-2-1 crack spread: the implied refining margin
#' from processing 3 barrels of crude into 2 barrels of gasoline and 1 barrel
#' of heating oil. RB and HO are in USD/gallon; multiply by 42 to convert to
#' USD/barrel before applying the spread formula.
#'
#' @param prices dflong-format price dataframe (from app_data()$prices)
#'
#' @return A dataframe with columns: date, crack_spread
#'
#' @noRd

calc_crack_spread <- function(prices) {

  cl <- filter_futures(prices, "CL", contracts = 1) %>%
    dplyr::select(date, cl = value)

  rb <- filter_futures(prices, "RB", contracts = 1) %>%
    dplyr::select(date, rb = value)

  ho <- filter_futures(prices, "HO", contracts = 1) %>%
    dplyr::select(date, ho = value)

  dplyr::inner_join(cl, rb, by = "date") %>%
    dplyr::inner_join(ho, by = "date") %>%
    dplyr::mutate(
      crack_spread = (2 * rb * 42 + 1 * ho * 42 - 3 * cl) / 3
    ) %>%
    dplyr::select(date, crack_spread)
}
