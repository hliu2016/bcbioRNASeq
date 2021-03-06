#' Plot Intronic Mapping Rate
#'
#' @rdname plotIntronicMappingRate
#' @name plotIntronicMappingRate
#' @family Quality Control Plots
#' @author Michael Steinbaugh, Rory Kirchner, Victor Barrera
#'
#' @inherit plotTotalReads
#'
#' @examples
#' load(system.file(
#'     file.path("extdata", "bcb.rda"),
#'     package = "bcbioRNASeq"))
#'
#' # bcbioRNASeq
#' plotIntronicMappingRate(bcb)
#' plotIntronicMappingRate(
#'     bcb,
#'     interestingGroups = "sampleName",
#'     fill = NULL)
#'
#' # data.frame
#' df <- metrics(bcb)
#' plotIntronicMappingRate(df)
NULL



# Constructors =================================================================
#' @importFrom basejump uniteInterestingGroups
#' @importFrom ggplot2 aes_ coord_flip geom_bar ggplot labs ylim
#' @importFrom viridis scale_fill_viridis
.plotIntronicMappingRate <- function(
    object,
    interestingGroups = "sampleName",
    warnLimit = 20,
    fill = viridis::scale_fill_viridis(discrete = TRUE),
    flip = TRUE) {
    metrics <- uniteInterestingGroups(object, interestingGroups)
    p <- ggplot(
        metrics,
        mapping = aes_(
            x = ~sampleName,
            y = ~intronicRate * 100,
            fill = ~interestingGroups)
    ) +
        geom_bar(stat = "identity") +
        labs(title = "intronic mapping rate",
             x = "sample",
             y = "intronic mapping rate (%)",
             fill = paste(interestingGroups, collapse = ":\n")) +
        ylim(0, 100)
    if (!is.null(warnLimit)) {
        p <- p + qcWarnLine(warnLimit)
    }
    if (!is.null(fill)) {
        p <- p + fill
    }
    if (isTRUE(flip)) {
        p <- p + coord_flip()
    }
    p
}



# Methods ======================================================================
#' @rdname plotIntronicMappingRate
#' @importFrom viridis scale_color_viridis
#' @export
setMethod(
    "plotIntronicMappingRate",
    signature("bcbioRNASeq"),
    function(
        object,
        interestingGroups,
        warnLimit = 20,
        fill = viridis::scale_fill_viridis(discrete = TRUE),
        flip = TRUE) {
        if (is.null(metrics(object))) {
            return(NULL)
        }
        if (missing(interestingGroups)) {
            interestingGroups <- basejump::interestingGroups(object)
        }
        .plotIntronicMappingRate(
            metrics(object),
            interestingGroups = interestingGroups,
            warnLimit = warnLimit,
            fill = fill,
            flip = flip)
    })



#' @rdname plotIntronicMappingRate
#' @export
setMethod(
    "plotIntronicMappingRate",
    signature("data.frame"),
    .plotIntronicMappingRate)
