
fake_returns <- tibble::tibble(
  date         = rep(as.Date("2020-01-01") + 0:99, 2),
  series       = rep(c("CL01", "RB01"), each = 100),
  daily_return = c(rnorm(100, 0, 0.02), rnorm(100, 0, 0.02))
)


result <- fake_returns %>% calc_rolling_correlation("CL01","RB01")

test_that("Returns correct columns",{
  testthat::expect_equal(colnames(result), c("date","rolling_correlation"))
})

test_that("Values between -1 & 1",{

  testthat::expect_true(min(result$rolling_correlation) >= -1)
  testthat::expect_true(max(result$rolling_correlation) <= 1)
})

