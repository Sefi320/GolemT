

fake_returns <- tibble::tibble(
  date         = c(as.Date("2020-01-15"), as.Date("2020-01-16"),
                   as.Date("2020-02-15"), as.Date("2021-01-15")),
  series       = "CL01",
  daily_return = c(0.01, 0.01, 0.02, 0.03)
)


result <- fake_returns %>%
          calc_seasonality("CL01")

testthat::test_that("Has 2 years of data", {
  testthat::expect_equal(nrow(result), 2)

})


testthat::test_that("Has 2 months", {
  testthat::expect_equal(ncol(result), 2)
})

testthat::test_that("returns a matrix", {
  testthat::expect_true(is.matrix(result))
})

testthat::test_that("known input produces known output", {
  testthat::expect_equal(result["2020", "1"], 0.01, tolerance = 1e-6)
})


