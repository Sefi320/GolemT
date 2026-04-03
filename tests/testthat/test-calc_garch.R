fake_returns_garch <- tibble::tibble(
  date         = seq(as.Date("2017-07-01"), as.Date("2023-07-31"), by = "day"),
  series       = "CL01",
  daily_return = stats::rnorm(
    length(seq(as.Date("2017-07-01"), as.Date("2023-07-31"), by = "day")), 0, 0.02
  )
)

testthat::test_that("runs without error on valid input", {
  testthat::expect_no_error(
    calc_garch(fake_returns_garch, series_name = "CL01", out = "data")
  )
})

testthat::test_that("filters to only the requested series before passing to garch", {
  two_series <- dplyr::bind_rows(
    fake_returns_garch,
    dplyr::mutate(fake_returns_garch, series = "NG01", daily_return = daily_return * 2)
  )
  result_single <- calc_garch(fake_returns_garch, series_name = "CL01", out = "data")
  result_multi  <- calc_garch(two_series,         series_name = "CL01", out = "data")
  testthat::expect_equal(result_single, result_multi)
})

testthat::test_that("returns a non-null result", {
  result <- calc_garch(fake_returns_garch, series_name = "CL01", out = "data")
  testthat::expect_false(is.null(result))
})
