context("plotMappedReads")

load(system.file(
    file.path("extdata", "bcb.rda"),
    package = "bcbioRNASeq"))

test_that("plotMappedReads", {
    p <- plotMappedReads(bcb)
    expect_is(p, "ggplot")
})
