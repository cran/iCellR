% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/F0057.R
\name{hto.anno}
\alias{hto.anno}
\title{Demultiplexing HTOs}
\usage{
hto.anno(hto.data = "data.frame", cov.thr = 10, assignment.thr = 80)
}
\arguments{
\item{hto.data}{HTO raw data}

\item{cov.thr}{A number which average coverage is divided by to set a threshold for low coverage. For example 10 means it is 10 time less than the average. default = 10.}

\item{assignment.thr}{A percent above which you decide to set as a good sample assignment/HTO, default = 80.}
}
\value{
An object of class iCellR
}
\description{
Demultiplexing HTOs
}
