#' Outputs some information about the activity dataframe
#'
#' @param df The dataframe containing the activity data
#' @return No return value. Prints the head and tail as well as the starting and
#'  end date of a digiRhythm friendly dataframe.
#' @export
#'

df_act_info <- function(df) {
  print("First days of the data set: ")
  print(utils::head(df))

  print("Last days of the data set: ")
  print(utils::tail(df))

  print(paste("The dataset contains", length(unique(as.Date(df[, 1]))), "Days"))

  first <- as.Date(df[1, 1])

  print(paste("Starting date is:", first))

  last <- as.Date(df[nrow(df), 1])
  print(paste("Last date is:", last))
}

#' Remove outliers from the data
#'
#' @param df The dataframe containing the activity data
#'
#' @return return a dataframe where columns start the second one have undergone
#' an outlier removal.
#' @export
#'


remove_activity_outliers <- function(df) {
  data <- as.data.frame(df)
  for (i in 2:ncol(df)) {
    Q <- stats::quantile(data[, i], probs = c(.25, .75), na.rm = TRUE)
    iqr <- stats::IQR(data[, i])
    up <- Q[2] + 1.5 * iqr # Upper Range
    low <- Q[1] - 1.5 * iqr # Lower Range
    non_outliers <- which(data[, i] <= up | data[, i] >= low)
    outliers <- which(data[, i] > up | data[, i] < low)
    mean_without_outliers <- mean(data[non_outliers, i], na.rm = TRUE)
    data[outliers, i] <- mean_without_outliers
  }
  data
}


#' Print if Verbose is true
#'
#' @param string The string to print
#' @param verbose if TRUE, print the string
#'
#' @return No return value. Prints the string concatenated with a verbose if the
#'  latter is not NULL.
#'

print_v <- function(
    string,
    verbose) {
  if (verbose) {
    cat(string, "\n")
  }
}

#' Returns the periodicity of a digiRhythm dataframe
#'
#' @param data a digiRhythm friendly dataframe
#'
#' @return returns a periodicity object of type xts.
#' @export
#' @examples
#' data("df516b_2", package = "digiRhythm")
#' df <- df516b_2
#' dgm_periodicity(df)
#'
dgm_periodicity <- function(data) {
  xts_data <- xts::xts(
    x = data[, 2],
    order.by = data[, 1]
  )

  xts::periodicity(xts_data)
}


#' Returns p-value of a frequency peak according to pbaluev (2008) given Z,
#' fmax and tm. Reused from the LOMB library (https://rdrr.io/cran/lomb/)
#'
#' @param Z the power of the frequency
#' @param fmax the maximum frequency in the spectrum
#' @param tm the time grid of the original time series
#' @return an intermediate calculation step needed to compute the p-value
#' according to
#' pbaluev (2008).
#'

pbaluev <- function(Z, fmax, tm) {
  # Adapted from astropy timeseries
  # (https://docs.astropy.org/en/stable/timeseries/index.html)
  N <- length(tm)
  Dt <- mean(tm^2) - mean(tm)^2
  NH <- N - 1
  NK <- N - 3
  fsingle <- (1 - Z)^(0.5 * NK)
  Teff <- sqrt(4 * pi * Dt) # Effective baseline
  W <- fmax * Teff
  ggamma_NH <- sqrt(2 / N) * exp(lgamma(N / 2) - lgamma((N - 1) / 2))
  tau <- ggamma_NH * W * (1 - Z)^(0.5 * (NK - 1)) * sqrt(0.5 * NH * Z)
  p <- -(exp(-tau) - 1) + fsingle * exp(-tau)
  return(p)
}

#' Returns the level given the p-value computed with pbaluev (2008). Copied from
#'  the LOMB library.
#'
#' @param Z the power of the frequency
#' @param fmax the maximum frequency in the spectrum
#' @param tm the time grid of the original time series
#' @param alpha the significance level
#'
#' @return Returns the level given the p-value computed with pbaluev (2008).
#'

levopt <- function(Z, alpha, fmax, tm) {
  prob <- pbaluev(Z, fmax, tm)
  (log(prob) - log(alpha))^2
}

#' Function to calculate the smallest possible harmonic to consider given
#' a sampling frequency. The minimum possible harmonic = 2 x the period of the
#' maximum frequency according to the Shanon theorem. Example: if the sampling
#' period is 15 min, the minimum possible treatable period is 30 minutes and
#' that corresponds to the 48th harmonic (24 hours * 60 minutes / 48 =
#' 30 minutes)
#'
#' @param sampling_period_in_minutes The sampling period of the acquired
#' data in minutes
#'
#' @return Returns the smallest possible harmonic (of 24 hours) to consider
#' given a sampling frequency.
#' @export

highest_possible_harm_cutoff <- function(sampling_period_in_minutes) {
  harmonics <- seq(1, 1000)
  harmonic_periods <- 24 * 60 / harmonics
  all_reachable_harmonic_period <- harmonics[harmonic_periods >=
    2 * sampling_period_in_minutes]
  l <- max(all_reachable_harmonic_period)
  return(as.numeric(l))
}
