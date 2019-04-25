context("Individual functions for DADA2 outputs")
dir="/Users/subramanianp4/git/nephele2/pipelines/datavis16s/testdata/dada2"

expect_html_identical <- function(ref, qry) {
  info <- paste("ref is", ref, "qry is", qry)
  ref <- readLines(file.path(dir, ref))
  qry <- readLines(file.path(dir, qry))
  ref <- grep("htmlwidget", ref, invert=T, value=T)
  qry <- grep("htmlwidget", qry, invert=T, value=T)

  expect_identical(ref, qry, info=info)
}


## DECIPHER
test_that("adivboxplot with decipher outputs returns no error and expected warning and expected output", {
  unlink(file.path(dir, "graphs", "*"), recursive = T)
  expect_warning(vv <- capture.output(adiv <- adivboxplot(datafile=file.path(dir, "decipher_OTU_table.txt"), mapfile=file.path(dir,"mayank.txt.no_gz"), sampdepth=10000, tsvfile=T, outdir=file.path(dir, "graphs"))), 'chosen rarefy size \\(10000\\) is smaller than the smallest amount of reads in any sample \\(11371\\)')
  expect_equal(adiv, 0)
  expect_identical(readLines(file.path(dir, "graphs/alphadiv.txt")), readLines(file.path(dir, "decipher_graphs/alphadiv.txt")))
  expect_html_identical( "graphs/alphadiv.html",  "decipher_graphs/alphadiv.html")
})

test_that("rarefactioncurve with decipher returns no error and expected output", {
  unlink(file.path(dir, "graphs", "*"), recursive = T)
  vv <- capture.output(rfc <- rarefactioncurve(datafile=file.path(dir, "decipher_OTU_table.txt"), mapfile=file.path(dir,"mayank.txt.no_gz"), tsvfile=T, outdir=file.path(dir, "graphs")))
  expect_equal(rfc, 0)
})
