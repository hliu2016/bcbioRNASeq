% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/methods-plotCountDensity.R
\docType{methods}
\name{plotCountDensity}
\alias{plotCountDensity}
\alias{plotCountDensity}
\alias{plotCountDensity,bcbioRNASeq-method}
\alias{plotCountDensity,data.frame-method}
\title{Plot Count Density}
\usage{
plotCountDensity(object, ...)

\S4method{plotCountDensity}{bcbioRNASeq}(object, interestingGroups,
  normalized = "tmm", style = "solid",
  color = viridis::scale_color_viridis(discrete = TRUE),
  fill = viridis::scale_fill_viridis(discrete = TRUE))

\S4method{plotCountDensity}{data.frame}(object,
  interestingGroups = "sampleName", style = "solid",
  color = viridis::scale_color_viridis(discrete = TRUE),
  fill = viridis::scale_fill_viridis(discrete = TRUE))
}
\arguments{
\item{object}{Object.}

\item{...}{\emph{Additional arguments (for the S4 generic definition).}}

\item{interestingGroups}{Category to use to group samples. In the plotting
functions, this will define color and shape, where applicable. If unset,
this is automatically determined by the metadata set inside the
\link{bcbioRNASeq} object. When set to \code{NULL}, this will default to
\code{sampleName}.}

\item{normalized}{Count normalization method. See \code{\link[=counts]{counts()}} documentation
for more information.}

\item{style}{Desired plot style (\code{line} or \code{solid}).}

\item{color}{Desired ggplot color scale. Defaults to
\code{\link[viridis:scale_color_viridis]{viridis::scale_color_viridis()}}. Must supply discrete values. When set to
\code{NULL}, the default ggplot2 color palette will be used. If manual color
definitions are desired, we recommend using
\code{\link[ggplot2:scale_color_manual]{ggplot2::scale_color_manual()}}.}

\item{fill}{Desired ggplot fill scale. Defaults to
\code{\link[viridis:scale_fill_viridis]{viridis::scale_fill_viridis()}}. Must supply discrete values. When set to
\code{NULL}, the default ggplot2 color palette will be used. If manual color
definitions are desired, we recommend using \code{\link[ggplot2:scale_fill_manual]{ggplot2::scale_fill_manual()}}.}
}
\value{
\link{ggplot}.
}
\description{
Plot Count Density
}
\examples{
load(system.file(
    file.path("extdata", "bcb.rda"),
    package = "bcbioRNASeq"))

# bcbioRNASeq
plotCountDensity(bcb, style = "solid")
plotCountDensity(
    bcb,
    style = "line",
    interestingGroups = "sampleName",
    fill = NULL)

# data.frame
df <- meltLog10(bcb, normalized = "tmm")
plotCountDensity(df)
}
\seealso{
Other Quality Control Plots: \code{\link{plot53Bias}},
  \code{\link{plotCountsPerGene}},
  \code{\link{plotExonicMappingRate}},
  \code{\link{plotGenderMarkers}},
  \code{\link{plotGeneSaturation}},
  \code{\link{plotGenesDetected}}, \code{\link{plotGene}},
  \code{\link{plotIntronicMappingRate}},
  \code{\link{plotMappedReads}},
  \code{\link{plotMappingRate}},
  \code{\link{plotRRNAMappingRate}},
  \code{\link{plotTotalReads}}
}
\author{
Michael Steinbaugh, Rory Kirchner, Victor Barrera
}
