
fake_prices <- tibble::tibble(
  date   = as.Date(c("2020-01-01", "2020-01-01", "2020-01-01", "2020-01-02")),
  series = c("CL01", "CL02", "NG01", "CL01"),
  value  = c(50, 51, 2.5, 52)
)

testthat::test_that("filters to correct commodity", {
  result <- filter_futures(fake_prices, "CL")
  testthat::expect_true(all(stringr::str_detect(result$series, "^CL")))
})

testthat::test_that("excludes other commodities", {
  result <- filter_futures(fake_prices, "CL")
  testthat::expect_false(any(stringr::str_detect(result$series, "^NG")))
})

testthat::test_that("adds month column as integer", {
  result <- filter_futures(fake_prices, "CL")
  testthat::expect_true(is.integer(result$month))
})

testthat::test_that("contracts range filter works", {
  result <- filter_futures(fake_prices, "CL", contracts = 1)
  testthat::expect_true(all(result$month == 1))
})

testthat::test_that("has required columns", {
  result <- filter_futures(fake_prices, "CL")
  testthat::expect_true(all(c("date", "series", "value", "month") %in% colnames(result)))
})
