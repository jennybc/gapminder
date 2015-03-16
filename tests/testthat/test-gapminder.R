context("Data sanity check")

test_that("China imputation is not stupid", {
  
  ## https://github.com/jennybc/gapminder/issues/4
  tmp_file <- file.path(tempdir(), "gdat.dput")
  dput(gapminder, tmp_file)
  gap2 <- dget(tmp_file)
  expect_identical(gapminder, gap2)
  
})
