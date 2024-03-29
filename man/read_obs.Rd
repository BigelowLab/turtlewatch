% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/obs.R
\name{read_obs}
\alias{read_obs}
\title{Read the observations}
\usage{
read_obs(filename = system.file("Anecdata_Export.geojson", package =
  "turtlewatch"), simplify = TRUE, keep_species = c("Chelonia mydas",
  "Eretmochelys imbricata imbricata"), keep_years = 2011:2016)
}
\arguments{
\item{filename}{character, the fully qualified filename}

\item{simplify}{logical if TRUE then simplify the dataset including
honoring keep_species and keep_years}

\item{keep_species}{character the species to keep}

\item{keep_years}{numeric 4-digit years to keep}
}
\value{
simple feature POINT dataset
}
\description{
Read the observations
}
