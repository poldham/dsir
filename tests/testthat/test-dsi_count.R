test_that("dsi_count returns charcacter", {
  expect_invisible(bahamas <- dsi_count(country = "bahamas", db = "nuccore"), "character")
})

kenya_all <- dsi_count(country = "kenya", db = "nuccore")
kenya_homo <- dsi_count(country = "(Kenya AND Homo sapiens[ORGN])", db = "nuccore")
kenya_not <- dsi_count(country = "(Kenya NOT Homo sapiens[ORGN])", db = "nuccore")

test_that("dsi_counts tally", {
  expect_true((kenya_homo + kenya_not) == kenya_all)
})

test_that("dsi_count with date works", {
  expect_true((kenya_homo + kenya_not) == kenya_all)
})
