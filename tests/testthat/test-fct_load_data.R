

l <- load_data()


testthat::test_that("Returns list of 3", {
  testthat::expect_length(l,3)
})


testthat::test_that("Correct objects returned",{
  testthat::expect_setequal(names(l),c("cmt_data","eia_data","prices"))

})

testthat::test_that("has data", {
  testthat::expect_true(nrow(l$cmt_data) > 1)
  testthat::expect_true(nrow(l$eia_data) > 1)
  testthat::expect_true(nrow(l$prices) > 1)
})






