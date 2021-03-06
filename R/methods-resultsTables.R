#' Differential Expression Results Tables
#'
#' @rdname resultsTables
#' @name resultsTables
#' @author Michael Steinbaugh
#'
#' @inheritParams AllGenerics
#' @inheritParams basejump::annotable
#'
#' @param lfc Log fold change ratio (base 2) cutoff. Does not apply to
#'   statistical hypothesis testing, only gene filtering in the results tables.
#'   See [results()] for additional information about using `lfcThreshold` and
#'   `altHypothesis` to set an alternative hypothesis based on expected fold
#'   changes.
#' @param annotable Join Ensembl gene annotations to the results. Apply gene
#'   identifier to symbol mappings. If `TRUE`, the function will attempt to
#'   detect the organism from the gene identifiers (rownames; "ensgene" column)
#'   and automatically obtain the latest annotations from Ensembl using
#'   [basejump::annotable()]. If set `FALSE`/`NULL`, then gene annotations will
#'   not be added to the results. This is useful when working with a poorly
#'   annotated genome. Alternatively, a previously saved annotable [data.frame]
#'   can be passed in.
#' @param summary Show summary statistics as a Markdown list.
#' @param headerLevel Markdown header level.
#' @param write Write CSV files to disk.
#' @param dir Directory path where to write files.
#'
#' @return Results [list].
#'
#' @examples
#' load(system.file(
#'     file.path("extdata", "bcb.rda"),
#'     package = "bcbioRNASeq"))
#' load(system.file(
#'     file.path("extdata", "res.rda"),
#'     package = "bcbioRNASeq"))
#'
#' annotable <- annotable(bcb)
#'
#' resTbl <- resultsTables(
#'     res,
#'     lfc = 0.25,
#'     annotable = annotable,
#'     summary = FALSE,
#'     write = FALSE)
#' names(resTbl)
NULL



# Constructors =================================================================
#' Markdown List of Results Files
#'
#' Enables looping of results contrast file links for RMarkdown.
#'
#' @author Michael Steinbaugh
#' @keywords internal
#'
#' @param resTbl List of results tables generated by [resultsTables()].
#' @param dir Output directory.
#'
#' @return [writeLines()].
#' @noRd
.mdResultsTables <- function(resTbl, dir) {
    if (!dir.exists(dir)) {
        stop("DE results directory missing", call. = FALSE)
    }
    all <- resTbl[["allFile"]]
    deg <- resTbl[["degFile"]]
    degLFCUp <- resTbl[["degLFCUpFile"]]
    degLFCDown <- resTbl[["degLFCDownFile"]]
    mdList(c(
        paste0("[`", all, "`](", file.path(dir, all), "): ",
               "All genes, sorted by Ensembl identifier."),
        paste0("[`", deg, "`](", file.path(dir, deg), "): ",
               "Genes that pass the alpha (FDR) cutoff."),
        paste0("[`", degLFCUp, "`](", file.path(dir, degLFCUp), "): ",
               "Upregulated DEG; positive log2 fold change."),
        paste0("[`", degLFCDown, "`](", file.path(dir, degLFCDown), "): ",
               "Downregulated DEG; negative log2 fold change.")
    ))
}



#' @importFrom basejump annotable camel sanitizeAnnotable snake
#' @importFrom dplyr arrange desc left_join
#' @importFrom readr write_csv
#' @importFrom rlang !! sym
#' @importFrom S4Vectors metadata
#' @importFrom tibble rownames_to_column
.resultsTablesDESeqResults <- function(
    object,
    lfc = 0,
    annotable = TRUE,
    summary = TRUE,
    headerLevel = 3,
    write = FALSE,
    dir = file.path("results", "differential_expression"),
    quiet = FALSE) {
    contrast <- .resContrastName(object)
    fileStem <- snake(contrast)

    # Alpha level, slotted in `DESeqResults` metadata
    alpha <- metadata(object)[["alpha"]]

    all <- object %>%
        as.data.frame() %>%
        rownames_to_column("ensgene") %>%
        as("tibble") %>%
        camel(strict = FALSE) %>%
        arrange(!!sym("ensgene"))

    # Add Ensembl gene annotations (annotable), if desired
    if (isTRUE(annotable)) {
        # Match genome against the first gene identifier by default
        organism <- rownames(object) %>%
            .[[1]] %>%
            detectOrganism()
        annotable <- annotable(organism, quiet = quiet)
    }
    if (!is.null(annotable)) {
        checkAnnotable(annotable)
        # Drop the nested lists (e.g. entrez), otherwise the CSVs will fail to
        # save when `write = TRUE`.
        annotable <- sanitizeAnnotable(annotable)
        all <- left_join(all, annotable, by = "ensgene")
    }

    # Check for overall gene expression with base mean
    baseMeanGt0 <- all %>%
        arrange(desc(!!sym("baseMean"))) %>%
        .[.[["baseMean"]] > 0, , drop = FALSE]
    baseMeanGt1 <- baseMeanGt0 %>%
        .[.[["baseMean"]] > 1, , drop = FALSE]

    # All DEG tables are sorted by BH adjusted P value
    deg <- all %>%
        .[!is.na(.[["padj"]]), , drop = FALSE] %>%
        .[.[["padj"]] < alpha, , drop = FALSE] %>%
        arrange(!!sym("padj"))
    degLFC <- deg %>%
        .[.[["log2FoldChange"]] > lfc |
              .[["log2FoldChange"]] < -lfc, , drop = FALSE]
    degLFCUp <- degLFC %>%
        .[.[["log2FoldChange"]] > 0, , drop = FALSE]
    degLFCDown <- degLFC %>%
        .[.[["log2FoldChange"]] < 0, , drop = FALSE]

    # File paths
    allFile <- paste(fileStem, "all.csv.gz", sep = "_")
    degFile <- paste(fileStem, "deg.csv.gz", sep = "_")
    degLFCUpFile <- paste(fileStem, "deg_lfc_up.csv.gz", sep = "_")
    degLFCDownFile <- paste(fileStem, "deg_lfc_down.csv.gz", sep = "_")

    resTbl <- list(
        contrast = contrast,
        # Cutoffs
        alpha = alpha,
        lfc = lfc,
        # Tibbles
        all = all,
        deg = deg,
        degLFC = degLFC,
        degLFCUp = degLFCUp,
        degLFCDown = degLFCDown,
        # File paths
        allFile = allFile,
        degFile = degFile,
        degLFCUpFile = degLFCUpFile,
        degLFCDownFile = degLFCDownFile)

    if (isTRUE(summary)) {
        if (!is.null(headerLevel)) {
            mdHeader(
                "Summary statistics",
                level = headerLevel,
                asis = TRUE)
        }
        mdList(
            c(paste(nrow(all), "genes in count matrix"),
              paste("base mean > 0:", nrow(baseMeanGt0), "genes (non-zero)"),
              paste("base mean > 1:", nrow(baseMeanGt1), "genes"),
              paste("alpha cutoff:", alpha),
              paste("lfc cutoff:", lfc, "(applied in tables only)"),
              paste("deg pass alpha:", nrow(deg), "genes"),
              paste("deg lfc up:", nrow(degLFCUp), "genes"),
              paste("deg lfc down:", nrow(degLFCDown), "genes")),
            asis = TRUE)
    }

    if (isTRUE(write)) {
        # Write the CSV files
        dir.create(dir, recursive = TRUE, showWarnings = FALSE)

        write_csv(all, file.path(dir, allFile))
        write_csv(deg, file.path(dir, degFile))
        write_csv(degLFCUp, file.path(dir, degLFCUpFile))
        write_csv(degLFCDown, file.path(dir, degLFCDownFile))

        # Output file information in Markdown format
        .mdResultsTables(resTbl, dir)
    }

    resTbl
}



# Methods ======================================================================
#' @rdname resultsTables
#' @export
setMethod(
    "resultsTables",
    signature("DESeqResults"),
    .resultsTablesDESeqResults)
