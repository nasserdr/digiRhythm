#' Computes the Degree of Function coupling (DFC), Harmonic Part (HP) and Weekly
#' Lomb-Scargle Spectrum (LSP Spec) for one variable in an activity dataset.
#' The dataset should be digiRhythm friendly.
#'
#' The computation of DFC/HP/LSP parameters is done using a rolling window of 7 days (i.e.,
#' first, we compute the parameters of Days 1-7 then, of days 2-8 and so on).
#' For each window of the 7 days, the function will compute the LSP spectrum to
#' determine the power of each frequency. Using Baluev (2008), we will compute the
#' significance of the amplitude of each frequency component and determine whether
#' it is significant or not. Then, we will have all the significant frequencies,
#' whose amplitudes' summation will be denominated as SUMSIG. Among all the available
#' frequencies, some are harmonic (those that correspond to waves of period
#' 24h, 12h, 24h/3, 24h/4, ...). As a result, we will have frequency components
#' that are significant and harmonic, whose powers' summation is called SSH (sum
#' significant and harmonic). The summation of all frequency components up to a
#' frequency reflecting a 24h period is called SUMALL. Therefore, DFC and HP are
#' computed as follows:
#'
#' DFC <- SSH / SUMSIG
#' HP <- SSH / SUMALL
#'
#'
#' @param data The activity data set.
#' @param activity The name of the activity.
#' @param sampling The sampling period of the data set in minutes.
#' the Lomb Scargle Periodogram is computed.
#' @param sig The significance level that should be used to determine the
#' significant frequency component.
#' @param rolling_window The rolling window used to compute the LSP. Default is 7 days.
#' @param plot if TRUE, the DFC/HP plot will be shown.
#' @param verbose if TRUE, print weekly progress.
#' @param plot_harmonic_part if TRUE, it shows the harmonic part in the DFC plot
#' @param plot_lsp if TRUE, the LSP of each sliding week will be plotted
#'
#' @return A list containing 2 dataframe. DFC dataframe that contain the
#' results of a DFC computation and SPEC Dataframe that contains the result of
#' spectrum computation.
#' The DFC contains 3 columns:
#' ** The date in format YYYY-MM-DD.
#' ** The DFC computed using a @rolling_window days.
#' ** The Harmonic Part (ratio).
#' Data are supposed to sampled with a specific smpling rate. It should be the same sampling rate
#' as in the given argument @sampling
#' Missing days are not permitted. If you have data with half day, it should be
#' removed.
#'
#' @import ggplot2
#' @importFrom lubridate date
#'
#' @export
#' @examples
#' sampling_period <- 15 * 60  # seconds
#' two_weeks <- 2 * 7 * 24 * 60 * 60  # seconds
#' amplitude_24h <- 5
#' amplitude_12h <- 3
#' noise_sd <- 2
#' time_seq <- seq(0, two_weeks, by = sampling_period)
#' time_posix <- as.POSIXct(time_seq, origin = "1970-01-01", tz = "UTC")
#' sine_24h <- amplitude_24h * sin(2 * pi * time_seq / (24 * 60 * 60))
#' sine_12h <- amplitude_12h * sin(2 * pi * time_seq / (12 * 60 * 60))
#' noise <- rnorm(length(time_seq), mean = 0, sd = noise_sd)
#' data <- sine_24h + sine_12h + noise
#' df <- data.frame(time = time_posix, value = data)
#######################################################

# Old example, but too much computation time for a submission on CRAN
# start <- Sys.time()
# data("df516b_2", package = "digiRhythm")
# df <- df516b_2[1:672, c(1, 2)]
# df <- remove_activity_outliers(df)
# df_act_info(df)
# activity <- names(df)[2]
# my_dfc_1 <- dfc(df, activity, sampling = 15)
# print(paste('time taken:', Sys.time() - start))

dfc <- function(
    data,
    activity,
    sampling = 15, # in minutes
    sig = 0.05,
    rolling_window = 7,
    plot = TRUE,
    plot_harmonic_part = TRUE,
    verbose = TRUE,
    plot_lsp = TRUE) {
  data <- as.data.frame(data, row.names = NULL)

  print(utils::head(data))
  if (!is_dgm_friendly(data)) {
    stop("The data is not digiRhythm friendly. type ?is_dgm_friendly in your console for more information")
  }


  data$date <- lubridate::date(data$datetime)

  days <- seq(
    data$date[1],
    last(data$date),
    1
  )
  if (length(days) < 2) {
    stop("You need at least 2 days of data to run the Degree of Functional Coupling algorithm")
  }


  if (length(days) < rolling_window) {
    stop("The number of rolling widown should be bigger than the number of days in the dataset.")
  }

  dfc <- NULL
  spec <- NULL
  from <- NULL

  dfc <- data.frame(
    from = character(),
    to = character(),
    dfc = numeric(),
    hp = numeric()
  ) # The data frame for DFC

  spec <- data.frame(
    fromtodate = character(),
    sample = numeric(),
    freq = numeric(),
    power = numeric(),
    pvalue = numeric()
  ) # The data frame for SPEC

  n_days_scanned <- length(days) - rolling_window - 1
  print(n_days_scanned)
  for (i in 1:n_days_scanned) {
    index_start_day <- i
    index_end_day <- i + rolling_window - 1

    if (verbose) {
      cat("Processing dates ", format(days[index_start_day]), " until ", format(days[index_end_day]), "\n")
    }

    samples_per_day <- 24 * 60 / sampling # The number of data points per day

    # Filtering the next seven days by date (not by index - in case of missing data, filtering by index would make errors)

    data_week <- data %>%
      dplyr::filter(date >= days[index_start_day]) %>%
      dplyr::filter(date <= days[index_end_day])


    # Selecting the first column (datetime) and the activity column
    df_var <- data_week %>% select(1, `activity`)
    lsp <- lomb_scargle_periodogram(df_var, alpha = sig, plot = TRUE)
    # Computing the p-values for each frequency
    # From timbre: seems they did not take the case where p>0.01 into account
    # p = [1.0 - pow(1.0 - math.exp(-x), 2.0 * nout / ofac) for x in py]


    # Adjusting the length of the vectors in case of missing data.
    # In case of no missing data, I expect 96 samples (if sampling = 15 min),
    # Therefore, I expect all other vector having 96 cells
    if (length(lsp$lsp_data$power) < samples_per_day) {
      len <- length(lsp$lsp_data$power)
      expy <- exp(-lsp$lsp_data$power)
    } else {
      len <- samples_per_day
      expy <- exp(-lsp$lsp_data$power[1:len])
    }

    lsp_data <- lsp$lsp_data[1:len, ]
    harm_power <- lsp_data$power[lsp_data$status_harmonic == "Harmonic"] # The harmonic powers

    sumall <- sum(lsp_data$power) # sum of all powers
    ssh <- sum(lsp_data$power[lsp_data$power >= lsp$sig.level &
      lsp_data$status_harmonic == "Harmonic"])
    sumsig <- sum(lsp_data$power[which(lsp_data$power >= lsp$sig.level)]) # sum of all significant

    # frequencies (each one has a power)
    # sumall: sum of powers for all frequencies (96) ==> 100: ALL
    # sumsig: 10 significant frequencies ==> 20             : subset of ALL
    # ssh: a subset of 10 ( 5 frequencies) ==> 10           : Subset of a subset of ALL
    # Because sumsig is always smaller than sumall and HP and DFC, then DFC is always
    # Bigger than HP

    HP <- ssh / sumall
    DFC <- ssh / sumsig

    spec <- rbind(spec, data.frame(
      rep(paste0(format(days[index_start_day]), "_to_", format(days[index_end_day])), len),
      1:len,
      (1:len) / 7,
      lsp_data$power,
      lsp_data$p_values
    ))
    dfc[i, ] <- c(format(days[index_start_day]), format(days[index_end_day]), DFC, HP)
    if (verbose) {
      print(dfc[i, ])
    }
  }
  dfc$from <- as.Date(dfc$from, format("%Y-%m-%d"))
  dfc$to <- as.Date(dfc$to, format("%Y-%m-%d"))
  dfc$dfc <- as.numeric(dfc$dfc)
  dfc$hp <- as.numeric(dfc$hp)

  if (plot_harmonic_part) {
    dfc_plot <- ggplot(dfc, aes(x = from)) +
      geom_line(aes(y = dfc, linetype = "Degree of functional coupling (%)")) +
      geom_line(aes(y = hp, linetype = "Harmonic part")) +
      xlab("") +
      ylab("") +
      # xlim(df$date[1], last(df$date)) +
      theme(
        axis.text.x = element_text(size = rel(1.5), color = "black"),
        axis.text.y = element_text(size = rel(1.5), color = "black"),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(size = 0.5),
        legend.key = element_rect(fill = "white"),
        legend.key.width = unit(0.5, "cm"),
        legend.justification = "left",
        legend.key.size = unit(7, "pt"),
        legend.title = element_blank(),
        legend.position = c(0.7, 0.75),
        plot.margin = margin(0, 0.5, 0, 0, "cm")
      )
  } else {
    dfc_plot <- ggplot(dfc, aes(x = from)) +
      geom_line(aes(y = dfc, linetype = "Degree of functional coupling (%)")) +
      xlab("") +
      ylab("") +
      # xlim(df$date[1], last(df$date)) +
      theme(
        axis.text.x = element_text(size = rel(1.5), color = "black"),
        axis.text.y = element_text(size = rel(1.5), color = "black"),
        axis.line = element_line(size = 0.5),
        legend.key = element_rect(fill = "white"),
        legend.key.width = unit(0.5, "cm"),
        legend.justification = "left",
        legend.key.size = unit(7, "pt"),
        legend.title = element_blank(),
        legend.position = c(0.7, 0.75),
        plot.margin = margin(0, 0.5, 0, 0, "cm")
      )
  }
  if (plot) {
    print(dfc_plot)
  }

  dfc_plot$spec <- spec
  return(dfc_plot)
}
