% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dfc.R
\name{dfc}
\alias{dfc}
\title{Computes the Degree of Function coupling (DFC), Harmonic Part (HP) and Weekly
Lomb-Scargle Spectrum (LSP Spec) for one variable in an activity dataset.
The dataset should be digiRhythm friendly.}
\usage{
dfc(
  data,
  activity,
  sampling = 15,
  sig = 0.05,
  plot = TRUE,
  plot_harmonic_part = TRUE,
  verbose = TRUE,
  plot_lsp = TRUE
)
}
\arguments{
\item{data}{The activity data set.}

\item{activity}{The name of the activity.}

\item{sampling}{The sampling period of the data set in minutes.
the Lomb Scargle Periodogram is computed.}

\item{sig}{The significance level that should be used to determine the
significant frequency component.}

\item{plot}{if TRUE, the DFC/HP plot will be shown.}

\item{plot_harmonic_part}{if TRUE, it shows the harmonic part in the DFC plot}

\item{verbose}{if TRUE, print weekly progress.}

\item{plot_lsp}{if TRUE, the LSP of each sliding week will be plotted}
}
\value{
A list containing 2 dataframe. DFC dataframe that contain the
results of a DFC computation and SPEC Dataframe that contains the result of
spectrum computation.
The DFC contains 3 columns:
** The date
** The DFC computed over 7 days (but we only extract the first 24 hours = 96 values)
** The Harmonic Part
Data are supposed to sampled with a specific smpling rate. It should be the same sampling rate
as in the given argument @sampling
Missing days are not permitted. If you have data with half day, it should be
removed.
}
\description{
The computation of DFC/HP/LSP parameters is done using a rolling window of 7 days (i.e.,
first, we compute the parameters of Days 1-7 then, of days 2-8 and so on).
For each window of the 7 days, the function will compute the LSP spectrum to
determine the power of each frequency. Using Baluev (2008), we will compute the
significance of the amplitude of each frequency component and determine whether
it is significant or not. Then, we will have all the significant frequencies,
whose amplitudes' summation will be denominated as SUMSIG. Among all the available
frequencies, some are harmonic (those that correspond to waves of period
24h, 12h, 24h/3, 24h/4, ...). As a result, we will have frequency components
that are significant and harmonic, whose powers' summation is called SSH (sum
significant and harmonic). The summation of all frequency components up to a
frequency reflecting a 24h period is called SUMALL. Therefore, DFC and HP are
computed as follows:
}
\details{
DFC <- SSH / SUMSIG
HP <- SSH / SUMALL
}
\examples{
data("df516b_2", package = "digiRhythm")
df <- df516b_2[1:672, c(1,2)]
df <- remove_activity_outliers(df)
df_act_info(df)
activity = names(df)[2]
my_dfc <- dfc(df, activity, sampling = 15)
}
