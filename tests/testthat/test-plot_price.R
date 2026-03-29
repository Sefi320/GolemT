
fake_prices <- tibble::tibble(
  date   = as.Date(c("2020-01-01", "2020-01-02")),
  series = c("CL01", "CL01"),
  value  = c(50, 52)
)

testthat::test_that("returns a plotly object for valid input", {
  testthat::expect_s3_class(plot_price(fake_prices, "CL"), "plotly")
})

testthat::test_that("does not crash for unknown commodity", {
  testthat::expect_s3_class(plot_price(fake_prices, "XX"), "plotly")
})

