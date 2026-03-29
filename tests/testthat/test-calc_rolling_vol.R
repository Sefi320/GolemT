

fake_returns <- tibble::tibble(
  date         = as.Date("2020-01-01") + 0:59,
  series       = "CL01",
  daily_return = rnorm(60, mean = 0, sd = 0.02)
)

testthat::test_that("adds rolling_vol column", {
  result <- calc_rolling_vol(fake_returns)
  testthat::expect_true("rolling_vol" %in% colnames(result))
})


testthat::test_that("rolling_vol is positive after window", {
  result <- calc_rolling_vol(fake_returns, window = 30)
  testthat::expect_true(all(result$rolling_vol[30:60] > 0, na.rm = TRUE))
})

testthat::test_that("larger window produces smoother output", {
  result_30  <- calc_rolling_vol(fake_returns, window = 10)
  result_60  <- calc_rolling_vol(fake_returns, window = 30)
  sd_30 <- sd(result_30$rolling_vol, na.rm = TRUE)
  sd_60 <- sd(result_60$rolling_vol, na.rm = TRUE)
  testthat::expect_true(sd_30 > sd_60)
})

testthat::test_that("works with multiple series", {
  multi <- dplyr::bind_rows(
    fake_returns,
    dplyr::mutate(fake_returns, series = "CL02")
  )
  result <- calc_rolling_vol(multi)
  testthat::expect_equal(length(unique(result$series)), 2)
})
