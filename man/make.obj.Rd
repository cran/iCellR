% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/F0003.R
\name{make.obj}
\alias{make.obj}
\title{Create an object of class iCellR.}
\usage{
make.obj(x = NULL)
}
\arguments{
\item{x}{A data frame containing gene counts for cells.}
}
\value{
An object of class iCellR
}
\description{
This function takes data frame and makes an object of class iCellR.
}
\examples{
     demo <- read.table(
     file = system.file('extdata', 'demo_data.txt', package = 'iCellR'),
     as.is = TRUE)
     myDemo.obj <- make.obj(demo)
     myDemo.obj
}
