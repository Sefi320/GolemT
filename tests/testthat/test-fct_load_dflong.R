
df <- load_dflong()

  testthat::test_that("returns df", {
  testthat::expect_true(is.data.frame(df))
})


  testthat::test_that("has data", {
    testthat::expect_true(nrow(df) > 1)
  })


testthat::test_that("returns all columns", {
  testthat::expect_setequal(colnames(df),c("date","series","value"))

})


