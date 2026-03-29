

fake_prices <- tibble::tibble(
  date   = as.Date(c("2020-01-01", "2020-01-02", "2020-01-03")),
  series = c("CL01", "CL01", "CL01"),
  value  = c(100, 110, 55)
)

testthat::test_that("adds daily_return column", {
  result <- calc_daily_returns(fake_prices)
  testthat::expect_true("daily_return" %in% colnames(result))
})

testthat::test_that("log return is correct for known input", {
  result <- calc_daily_returns(fake_prices)
  testthat::expect_equal(result$daily_return[1], log(110 / 100), tolerance = 1e-6)
})

testthat::test_that("diff return is correct for known input", {
  result <- calc_daily_returns(fake_prices, method = "diff")
  testthat::expect_equal(result$daily_return[1], 10)
})


testthat::test_that("works correctly with multiple series", {
  multi <- tibble::tibble(
    date   = as.Date(c("2020-01-01", "2020-01-02", "2020-01-01", "2020-01-02")),
    series = c("CL01", "CL01", "NG01", "NG01"),
    value  = c(100, 110, 2, 3)
  )
  result <- calc_daily_returns(multi)
  testthat::expect_true(all(is.na(result$daily_return[result$date == as.Date("2020-01-01")])))
})
