context("Data sanity check")

test_that("China imputation is not stupid", {
  
  ## https://github.com/jennybc/gapminder/issues/4
  tmp_file <- file.path(tempdir(), "gdat.dput")
  dput(gapminder, tmp_file)
  gap2 <- dget(tmp_file)
  expect_identical(gapminder, gap2)
  
})

test_that("data objects are unchanged", {
  
  expect_equal_to_reference(gapminder, "gapminder.rds")
  expect_equal_to_reference(gapminder, "gapminder_unfiltered.rds")
  expect_equal_to_reference(country_colors, "country_colors.rds")
  expect_equal_to_reference(continent_colors, "continent_colors.rds")
  
})
