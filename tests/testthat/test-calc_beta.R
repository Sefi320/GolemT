fake_returns <- tibble::tibble(
  date         = rep(as.Date("2020-01-01") + 0:99, 2),
  series       = rep(c("CL01", "RB01"), each = 100),
  daily_return = c(rnorm(100, 0, 0.02), rnorm(100, 0, 0.02))
)

# beta calc test data, used to see if the calcs are done correctly

x <- rnorm(100, 0, 0.02)
perfect_returns <- tibble::tibble(
  date         = rep(as.Date("2020-01-01") + 0:99, 2),
  series       = rep(c("CL01", "RB01"), each = 100),
  daily_return = c(x, 2 * x)
)


test_that("returns correct columns", {
  result <- calc_rolling_beta(fake_returns, "CL01", "RB01")
  testthat::expect_equal(colnames(result), c("date", "rolling_beta"))
})

test_that("beta is 1 when series are identical", {
  result <- calc_rolling_beta(perfect_returns, "CL01", "CL01")
  testthat::expect_equal(mean(result$rolling_beta), 1, tolerance = 2e-6)
})

test_that("beta is 2 when series_y = 2 * series_x", {
  result <- calc_rolling_beta(perfect_returns, "CL01", "RB01")
  testthat::expect_equal(mean(result$rolling_beta, na.rm = TRUE), 2, tolerance = 1e-6)
})
