#' Events
#'
#' @description A utils function that contains a tibble with macro events i want to higlight for each commodity
#'
#' @return Tibble with information
#'
#' @noRd
#'
#'


market_events <- tibble::tibble(
  date = as.Date(c(
    "2020-03-06",
    "2020-03-11",
    "2020-04-09",
    "2021-02-10",
    "2022-02-24",
    "2022-03-16",
    "2023-07-26",
    "2024-09-18"
  )),
  event = c(
    "Russia-Saudi price war begins",
    "COVID pandemic declared",
    "OPEC+ historic 9.7mb/d cut",
    "Winter Storm Uri",
    "Russia invades Ukraine",
    "Fed begins 2022 hike cycle",
    "Final Fed hike",
    "Fed pivot — first cut"
  ),
  commodities = c(
    "BRN",
    "All",
    "BRN",
    "NG, HO",
    "BRN, CL, NG",
    "CMT, BRN",
    "CMT",
    "CMT"))
