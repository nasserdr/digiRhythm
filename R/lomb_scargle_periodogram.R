#' Computes the Lomb Scargle Periodogram and returns the information needed for
#' computing the DFC and HP. A plot visualizing the Harmonic Frequencies
#' presence in the spectrum is possible. The function is inspired from the Lomb
#' library in a great part, with modifications to fit the requirements of
#' harmonic powers and computation of the DFC. This function is inspired by the
#' lsp function from the lomb package and adapted to add different colors for
#' harmonic and non harmonic frequencies in the signal. For more information
#' about lomb::lsp, please refer
#' to: https://cran.r-project.org/web/packages/lomb/
#'
#' @param data a digiRhythm friendly dataframe of only two columns
#' @param sampling the sampling period in minutes. default = 15 min.
#' @param alpha the statistical significance for the false alarm
#' @param harm_cutoff the order of the highest harmonic needed to be considered.
#' An integer equal to 1, 2, 3, ... Default is 12.
#' @param plot if TRUE, the LSP will be plotted
#' @param extra_info_plot if True, extra information will be shown on the plot
#'
#' @return a list that contains a dataframe (detailed below), the significance
#' level and significance (for the record). The dataframe contains the power the
#' frequency, the frequency in HZ, the p values according to Baluev 2008, the
#' period that corresponds to the frequency in seconds and in hours and finally,
#' a boolean to tell whether the frequency is harmonic or not.
#'
#' @import ggplot2
#'
#' @export
#'
#' @examples
#' data("df516b_2", package = "digiRhythm")
#' data <- df516b_2[1:672, c(1, 2)]
#' lomb_scargle_periodogram(data, alpha = 0.01, harm_cutof = 12, plot = TRUE)
#'
lomb_scargle_periodogram <- function(data, alpha = 0.01, harm_cutoff = 12,
                                     sampling = 15, plot = TRUE,
                                     extra_info_plot = TRUE) {
  if (!is_dgm_friendly(data, verbose = TRUE)) {
    stop("The data is not digiRhythm friendly. type ?is_dgm_friendly in your
         console for more information")
  }

  theoretical_cutoff <- lowest_possible_harmonic_period(sampling)

  # Check if the needed cutoff harmonic is bigger than the theoretical cutoff
  if (harm_cutoff > theoretical_cutoff) {
    warning("The sought harmonic cutoff is bigger than what is possible given
    the sampling period. The cutoff harmonic should correspond to a period that
       is at least 2 times the sampling period. For example, with a sampling
       period of 15 min, the lowest possible period that can be treated is 30
       min, which corresponds to the 48th harmonic period.")
    print(paste0("changing the harmoinc cutoff to ", theoretical_cutoff))
    used_harmonic_cutoff <- theoretical_cutoff
  } else {
    used_harmonic_cutoff <- harm_cutoff
  }

  x <- data
  start <- as.Date(x[1, 1])
  # print(start)
  end <- as.Date(x[nrow(x), 1])
  # print(end)

  from_to <- paste(
    "From",
    start,
    "To",
    end
  )

  ofac <- 1
  names <- colnames(x)
  times <- x[, 1]
  x <- x[, 2]

  times <- times[!is.na(x)]
  x <- x[!is.na(x)]

  nobs <- length(x)

  times <- as.numeric(times)
  start <- min(times)
  end <- max(times)
  av.int <- mean(diff(times))

  o <- order(times)
  times <- times[o]
  x <- x[o]

  y <- cbind(times, x)
  colnames(y) <- names

  datanames <- colnames(y)
  t <- y[, 1]
  y <- y[, 2]


  n <- length(y)
  tspan <- t[n] - t[1]
  fr.d <- 1 / tspan # Sampling frequency
  step <- 1 / (tspan * ofac)
  step

  f.max <- floor(0.5 * n * ofac) * step

  freq <- seq(fr.d, f.max, by = step)

  # Replace the frequencies that are the nearest to the harmonic corresponding
  # frequencies by the actual harmonic frequencies. #24h,12h, 8h, ....
  harmonic_periods_seconds <- 24 * 3600 / seq(1, used_harmonic_cutoff)

  harmonics_frequencies_hz <- 1 / harmonic_periods_seconds

  l <- lapply(harmonics_frequencies_hz, function(x) {
    which.min(abs(x - freq))
  })
  l <- unlist(l)

  freq[l] <- harmonics_frequencies_hz


  n.out <- length(freq)

  x <- t * 2 * pi
  y <- y - mean(y)
  norm <- 1 / sum(y^2)

  w <- 2 * pi * freq
  PN <- rep(0, n.out)
  for (i in 1:n.out) {
    wi <- w[i]
    tau <- 0.5 * atan2(sum(sin(wi * t)), sum(cos(wi * t))) / wi
    arg <- wi * (t - tau)
    cs <- cos(arg)
    sn <- sin(arg)
    A <- (sum(y * cs))^2
    B <- sum(cs * cs)
    C <- (sum(y * sn))^2
    D <- sum(sn * sn)
    PN[i] <- A / B + C / D
  }

  PN <- norm * PN

  scanned <- freq
  fmax <- max(freq)
  p.values <- lapply(PN, function(x) {
    pbaluev(x, fmax, tm = t)
  })

  p.values <- unlist(p.values)
  level <- pracma::fibsearch(levopt, 0, 1, alpha, fmax = fmax, tm = t)$xmin

  # Returns a list that contains:
  # 1. an LSP dataframe with the following cols: Freq, Power, Harmonc Status,
  # corresponding period in hours, pvalue (Baluev) of the frequency.
  # 2. sig.level

  lsp_data <- data.frame(
    power = PN,
    frequency_hz = freq,
    p_values = p.values
  )

  lsp_data <- lsp_data %>% mutate(period_seconds = (1 / frequency_hz))
  lsp_data <- lsp_data %>% mutate(period_hours = period_seconds / 3600)

  harmonic_periods <- 24 / seq(1, used_harmonic_cutoff) # 24h, 12h, 8h, ....
  l <- lapply(harmonic_periods, function(x) {
    which.min(abs(x - lsp_data$period_hours))
  })

  l <- unlist(l)
  lsp_data$status_harmonic <- "Non-Harmonic"
  lsp_data$status_harmonic[l] <- "Harmonic"


  output <- list(lsp_data = lsp_data, sig.level.power = level, alpha = alpha)

  len <- 24 * 60 / sampling

  # According to the cutoff harmonic, the LSP plot will be displayed only
  # up to the frequency that corresponds to the cutoff harmonic. The graph will
  # disregard all the frequencies that are higher than the cutoff harmonic + 1
  # cuotff_plus_one <- used_harmonic_cutoff + 1
  # freq_cutoff_plus_one = 24 / cuotff_plus_one

  index_freq_cutoff_plus_one <- which.min(abs(24 / used_harmonic_cutoff -
    lsp_data$period_hours))

  lsp_data <- lsp_data[1:index_freq_cutoff_plus_one, ]

  hdata <- lsp_data %>%
    filter(status_harmonic == "Harmonic") %>%
    select(frequency_hz, power, period_hours) %>%
    mutate(new_h = paste(round(period_hours, digits = 2), "h"))

  if (plot) {
    p <- ggplot(
      data = lsp_data,
      aes(x = frequency_hz, y = power)
    ) +
      ylim(c(0, 1.2 * max(lsp_data$power))) +
      geom_col(aes(fill = status_harmonic)) +
      geom_hline(yintercept = level, linetype = "dotted") +
      labs(fill = "Status", y = "Power", x = "Frequency (Hz)")
    if (extra_info_plot) {
      p <- p + theme(
        panel.background = element_rect(fill = "white"),
        axis.text = element_text(color = "#000000"),
        text = element_text(size = 15),
        axis.line = element_line(size = 0.5),
        legend.key = element_rect(fill = "white"),
        legend.key.width = unit(0.5, "cm"),
        legend.justification = "right",
        legend.position = c(1, 0.89),
        plot.margin = margin(t = 50)
      ) +
        geom_text(data = hdata, mapping = aes(
          x = frequency_hz,
          y = power,
          label = new_h,
          angle = 90,
          hjust = -0.4
        )) + ggtitle(paste("LSP for ", datanames[2], from_to))
    } else {
      p <- p + theme(
        panel.background = element_rect(fill = "white"),
        axis.text = element_text(color = "#000000"),
        text = element_text(size = 15),
        axis.line = element_line(size = 0.5),
        legend.position = "none",
        plot.margin = margin(t = 50)
      ) +
        geom_text(data = hdata, mapping = aes(
          x = frequency_hz,
          y = power,
          label = new_h,
          angle = 90,
          hjust = -0.4
        ))
    }

    print(p)
  }
  return(output)
}
