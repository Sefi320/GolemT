
prices <- load_dflong()

spread <- calc_htt_spread(prices)

testthat::test_that("returns a dataframe", {
  testthat::expect_true(is.data.frame(spread))
})

testthat::test_that("has expected columns", {
  testthat::expect_setequal(colnames(spread), c("date", "brn_cl_raw", "htt", "brn_cl_adj"))
})

testthat::test_that("has data", {
  testthat::expect_true(nrow(spread) > 1)
})

testthat::test_that("adjusted spread equals raw minus htt", {
  testthat::expect_equal(spread$brn_cl_adj, spread$brn_cl_raw - spread$htt)
})
