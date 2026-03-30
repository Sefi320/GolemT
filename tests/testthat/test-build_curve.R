

fake_futures <- tibble::tibble(
  date  = as.Date(c("2020-01-01", "2020-01-01", "2020-01-01", "2020-01-02")),
  series = c("CL01", "CL02", "CL03", "CL01"),
  month = c(1L, 2L, 3L, 1L),
  value = c(50, 51, 52, 48)
)

test_that("returns correct columns", {
  result <- build_curve(fake_futures, as.Date("2020-01-01"))
  testthat::expect_equal(colnames(result), c("month", "price"))
})

test_that("ordered by month", {
  result <- build_curve(fake_futures, as.Date("2020-01-01"))
  testthat::expect_equal(result$month, c(1L, 2L, 3L))
})

test_that("returns empty data frame for missing date", {
  result <- build_curve(fake_futures, as.Date("2099-01-01"))
  testthat::expect_equal(nrow(result), 0)
})

test_that("only returns requested date", {
  result <- build_curve(fake_futures, as.Date("2020-01-01"))
  testthat::expect_equal(nrow(result), 3)
})
