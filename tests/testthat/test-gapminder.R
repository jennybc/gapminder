test_that("China imputation is not stupid", {
  ## https://github.com/jennybc/gapminder/issues/4
  tmp_file <- file.path(tempdir(), "gdat.dput")
  on.exit(unlink(tmp_file))
  dput(gapminder, tmp_file)
  gap2 <- dget(tmp_file)
  expect_identical(gapminder, gap2)
})

test_that("data objects are unchanged", {
  expect_snapshot_value(gapminder, style = "serialize")
  expect_snapshot_value(gapminder_unfiltered, style = "serialize")
  expect_snapshot_value(country_colors, style = "serialize")
  expect_snapshot_value(continent_colors, style = "serialize")
  expect_snapshot_value(country_codes, style = "serialize")
})
