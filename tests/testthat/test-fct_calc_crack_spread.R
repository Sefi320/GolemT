
prices <- load_dflong()

cs <- calc_crack_spread(prices)

testthat::test_that("returns a dataframe", {
  testthat::expect_true(is.data.frame(cs))
})

testthat::test_that("has expected columns", {
  testthat::expect_setequal(colnames(cs), c("date", "crack_spread"))
})

testthat::test_that("has data", {
  testthat::expect_true(nrow(cs) > 1)
})

testthat::test_that("crack spread is numeric", {
  testthat::expect_true(is.numeric(cs$crack_spread))
})

testthat::test_that("crack spread formula is correct", {
  cl <- filter_futures(prices, "CL", contracts = 1) %>% dplyr::select(date, cl = value)
  rb <- filter_futures(prices, "RB", contracts = 1) %>% dplyr::select(date, rb = value)
  ho <- filter_futures(prices, "HO", contracts = 1) %>% dplyr::select(date, ho = value)

  manual <- dplyr::inner_join(cl, rb, by = "date") %>%
    dplyr::inner_join(ho, by = "date") %>%
    dplyr::mutate(expected = (2 * rb * 42 + 1 * ho * 42 - 3 * cl) / 3)

  joined <- dplyr::inner_join(cs, manual, by = "date")
  testthat::expect_equal(joined$crack_spread, joined$expected)
})
