context("plotExonicMappingRate")

load(system.file(
    file.path("extdata", "bcb.rda"),
    package = "bcbioRNASeq"))

test_that("plotExonicMappingRate", {
    p <- plotExonicMappingRate(bcb)
    expect_is(p, "ggplot")
})
