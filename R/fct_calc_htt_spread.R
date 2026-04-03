#' calc_htt_spread
#'
#' @description Computes the raw BRN-CL spread and the HTT-adjusted spread.
#' The adjusted spread removes the Cushing-to-Houston transport cost (HTT),
#' isolating the true Brent premium over WTI Houston.
#'
#' @param prices dflong-format price dataframe (from app_data()$prices)
#'
#' @return A dataframe with columns: date, brn_cl_raw, htt, brn_cl_adj
#'
#' @noRd

calc_htt_spread <- function(prices) {

  brn <- filter_futures(prices, "BRN", contracts = 1) %>%
    dplyr::select(date, brn = value)

  cl <- filter_futures(prices, "CL", contracts = 1) %>%
    dplyr::select(date, cl = value)

  htt <- filter_futures(prices, "HTT", contracts = 1) %>%
    dplyr::select(date, htt = value)

  dplyr::inner_join(brn, cl, by = "date") %>%
    dplyr::inner_join(htt, by = "date") %>%
    dplyr::mutate(
      brn_cl_raw = brn - cl,
      brn_cl_adj = brn - cl - htt
    ) %>%
    dplyr::select(date, brn_cl_raw, htt, brn_cl_adj)
}
