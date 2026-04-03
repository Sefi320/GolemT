fake_prices_seasonal <- tibble::tibble(
  date   = seq(as.Date("2018-01-01"), as.Date("2023-12-31"), by = "day"),
  series = "CL01",
  value  = 60 + 10 * sin(2 * pi * as.numeric(format(
    seq(as.Date("2018-01-01"), as.Date("2023-12-31"), by = "day"), "%j"
  )) / 365) + stats::rnorm(
    length(seq(as.Date("2018-01-01"), as.Date("2023-12-31"), by = "day")), 0, 1
  )
)

testthat::test_that("returns a matrix", {
  result <- calc_seasonality(fake_prices_seasonal, "CL01")
  testthat::expect_true(is.matrix(result))
})

testthat::test_that("matrix has 12 columns — one per month", {
  result <- calc_seasonality(fake_prices_seasonal, "CL01")
  testthat::expect_equal(ncol(result), 12)
})

testthat::test_that("matrix rows correspond to years in the data", {
  result <- calc_seasonality(fake_prices_seasonal, "CL01")
  years  <- as.integer(rownames(result))
  testthat::expect_true(all(years >= 2018 & years <= 2023))
})

testthat::test_that("all matrix values are numeric", {
  result <- calc_seasonality(fake_prices_seasonal, "CL01")
  testthat::expect_true(is.numeric(result))
})
