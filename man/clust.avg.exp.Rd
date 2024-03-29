% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/F0021.R
\name{clust.avg.exp}
\alias{clust.avg.exp}
\title{Create a data frame of mean expression of genes per cluster}
\usage{
clust.avg.exp(
  x = NULL,
  data.type = "main",
  conds.to.avg = NULL,
  rounding.digits = 4,
  low.cell.filt = 5,
  round.num = FALSE
)
}
\arguments{
\item{x}{An object of class iCellR.}

\item{data.type}{Choose from "main", "atac", "atac.imputed" and "imputed", default = "main"}

\item{conds.to.avg}{Choose the conditions you want to average, default = NULL (all conditions).}

\item{rounding.digits}{integer indicating the number of decimal places (round) or significant digits (signif) to be used.}

\item{low.cell.filt}{filter out clusters with low number of cells, default = 5.}

\item{round.num}{Rounding of Numbers, default = FALSE.}
}
\value{
An object of class iCellR.
}
\description{
This function takes an object of class iCellR and creates an average gene expression for every cluster.
}
