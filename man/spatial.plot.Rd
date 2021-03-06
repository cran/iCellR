% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/F0070.R
\name{spatial.plot}
\alias{spatial.plot}
\title{Plot nGenes, UMIs and perecent mito, genes, clusters and more on spatial image}
\usage{
spatial.plot(
  x = NULL,
  cell.size = 1,
  cell.colors = c("gray", "red"),
  back.col = "black",
  col.by = "clusters",
  conds.to.plot = NULL,
  gene = NULL,
  data.type = "main",
  scaleValue = TRUE,
  min.scale = 0,
  max.scale = 2.5,
  anno.clust = FALSE,
  anno.size = 4,
  anno.col = "white",
  cell.transparency = 1,
  interactive = TRUE,
  out.name = "plot"
)
}
\arguments{
\item{x}{An object of class iCellR.}

\item{cell.size}{A numeric value for the size of the cells, default = 1.}

\item{cell.colors}{Colors for heat mapping the points in "scatterplot", default = c("gray","red").}

\item{back.col}{A color for the plot background, default = "black".}

\item{col.by}{Choose between "clusters", "mt","UMIs","nGenes", "cc" (cell cycle) or "gene", default = "clusters".}

\item{conds.to.plot}{Choose the conditions you want to see in the plot, default = NULL (all conditions).}

\item{gene}{Gene name/names to be plotted, if col.by = "gene".}

\item{data.type}{Choose from "main" or "imputed", default = "main".}

\item{scaleValue}{Scale the colors, default = FALSE.}

\item{min.scale}{If scaleValue = TRUE, set a number for min, default = -2.5.}

\item{max.scale}{If scaleValue = TRUE, set a number for max, default = 2.5.}

\item{anno.clust}{Annotate cluster names on the plot, default = TRUE.}

\item{anno.size}{If anno.clust is TRUE set font size, default = 3.}

\item{anno.col}{If anno.clust is TRUE set color, default = "white".}

\item{cell.transparency}{Color transparency for points in "scatterplot" and "boxplot", default = 1.}

\item{interactive}{If set to TRUE an interactive HTML file will be created, default = TRUE.}

\item{out.name}{If "interactive" is set to TRUE, the out put name for HTML, default = "plot".}
}
\value{
An object of class iCellR.
}
\description{
This function takes an object of class iCellR and creates spatial plots.
}
