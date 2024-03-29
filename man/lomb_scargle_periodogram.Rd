% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lomb_scargle_periodogram.R
\name{lomb_scargle_periodogram}
\alias{lomb_scargle_periodogram}
\title{Computes the Lomb Scargle Periodogram and returns the information needed for
computing the DFC and HP. A plot visualizing the Harmonic Frequencies presence
in the spectrum is possible. The function is inspired from the Lomb library in
a great part, with modifications to fit the requirements of harmonic powers and
computation of the DFC. This function is inspired by the lsp function from the
lomb package and adapted to add different colors for harmonic and non harmonic
frequencies in the signal. For more information about lomb::lsp, please refer
to: https://cran.r-project.org/web/packages/lomb/}
\usage{
lomb_scargle_periodogram(
  data,
  alpha = 0.01,
  sampling = 15,
  plot = TRUE,
  extra_info_plot = TRUE
)
}
\arguments{
\item{data}{a digiRhythm friendly dataframe of only two columns}

\item{alpha}{the statistical significance for the false alarm}

\item{sampling}{the sampling period in minutes. default = 15 min.}

\item{plot}{if TRUE, the LSP will be plotted}

\item{extra_info_plot}{if True, extra information will be shown on the plot}
}
\value{
a list that contains a dataframe (detailed below), the significance
level and alpha (for the record). The dataframe contains the power the frequency,
the frequency in HZ, the p values according to Baluev 2008, the period that corresponds
to the frequency in seconds and in hours and finally, a boolean to tell whether
the frequency is harmonic or not.
}
\description{
Computes the Lomb Scargle Periodogram and returns the information needed for
computing the DFC and HP. A plot visualizing the Harmonic Frequencies presence
in the spectrum is possible. The function is inspired from the Lomb library in
a great part, with modifications to fit the requirements of harmonic powers and
computation of the DFC. This function is inspired by the lsp function from the
lomb package and adapted to add different colors for harmonic and non harmonic
frequencies in the signal. For more information about lomb::lsp, please refer
to: https://cran.r-project.org/web/packages/lomb/
}
\examples{
data("df516b_2", package = "digiRhythm")
data <- df516b_2[1:672, c(1,2)]
sig <- 0.01
lomb_scargle_periodogram(data, alpha = sig, plot = TRUE)
}
