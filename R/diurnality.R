#' Computes the diurnality index based on an activity dataframe
#'
#' @param data a digiRhythm-friendly dataset
#' @param activity The number of non-useful lines to skip (lines to header)
#' @param day_time an array containing the start and end of the day period. Default:
#' c("06:30:00", "16:30:00").
#' @param night_time an array containing the start and end of the night period. Default:
#' c("18:00:00", "T05:00:00").
#' @param save if NULL, the image is not saved. Otherwise, this parameter will
#' be the name of the saved image. it should contain the path and name without
#' the extension.
#'
#' @return A ggplot2 object that contains the diurnality plot in addition to a dataframe with 2 col: date and diurnality index
#'
#' @import ggplot2
#'
#' @examples
#' data("df516b_2", package = "digiRhythm")
#' data <- df516b_2
#' data <- remove_activity_outliers(data)
#' activity <- names(data)[2]
#' d_index <- diurnality(data, activity)
#'
#' @export

diurnality <- function(data,
                       activity,
                       day_time = c("06:30:00", "16:30:00"),
                       night_time = c("18:00:00", "T05:00:00"),
                       save = NULL) {
  # di = (cd/td - cn/tn)/(cd/td + cn/tn)

  dates <- unique(lubridate::date(data[, 1]))
  X <- xts::xts(
    x = data[[activity]],
    order.by = data[, 1]
  )

  sampling <- dgm_periodicity(data)[["frequency"]]

  # Code Addition 1
  # Formatting the time range of the day
  start_day <- paste0(
    "T",
    sprintf("%02d", attr(lubridate::hms(day_time[1]), "hour")),
    ":",
    sprintf("%02d", attr(lubridate::hms(day_time[1]), "minute")),
    ":00"
  )

  end_day <- paste0(
    "T",
    sprintf("%02d", attr(lubridate::hms(day_time[2]), "hour")),
    ":",
    sprintf("%02d", attr(lubridate::hms(day_time[2]), "minute")),
    ":00"
  )

  day_range <- paste0(start_day, "/", end_day)

  # Formatting the time range of the night
  start_night <- paste0(
    "T",
    sprintf("%02d", attr(lubridate::hms(night_time[1]), "hour")),
    ":",
    sprintf("%02d", attr(lubridate::hms(night_time[1]), "minute")),
    ":00"
  )

  end_night <- paste0(
    "T",
    sprintf("%02d", attr(lubridate::hms(night_time[2]), "hour")),
    ":",
    sprintf("%02d", attr(lubridate::hms(night_time[2]), "minute")),
    ":00"
  )

  night_range <- paste0(start_night, "/", end_night)

  # Compute the range of samples for the day and the night
  hms_day_start <- lubridate::hms(day_time[1])
  hms_day_end <- lubridate::hms(day_time[2])
  sample_size <- lubridate::hms(paste0("00:", sampling, ":00"))
  Td <- abs((hms_day_end - hms_day_start) / sample_size)

  hms_night_start <- lubridate::hms(night_time[1])
  hms_midnight <- lubridate::hms("00:00:00")
  hms_24t <- lubridate::hms("24:00:00")
  hms_night_end <- lubridate::hms(night_time[2])
  Tn <- (hms_24t - hms_night_start + hms_night_end - hms_midnight) / sample_size

  # Check conditions about the day and night time (overlapping, misplacement)
  if (hms_day_end > hms_night_start) {
    stop("The end of the day_time period should proceed the beginning of the night_time period")
  }

  if (lubridate::hour(hms_night_end) < 1) {
    stop("The of the nightly period should be after midnight")
  }

  if (lubridate::hour(hms_night_end) > 11) {
    stop("The end of the nightly period cannot be after mid-day! Come on!")
  }

  X_day <- X[day_range]
  Cd <- xts::period.apply(X_day, xts::endpoints(X_day, "days"), sum)

  # Computing Td for the motion index
  # Td <- 40 # 40 samples * 15 minutes = 10 hours
  day_val <- Cd / Td

  # Computing Cn for the motion index
  X_night <- X[paste0(dates[1], "T12:00:00", "/", last(dates))]
  X_night <- X_night[night_range]
  X_night <- X[night_range]

  offset <- 3600 * lubridate::hour(hms_night_start)
  zoo::index(X_night) <- zoo::index(X_night) - offset
  shift <- lubridate::hour(hms_24t - hms_night_start + hms_night_end - hms_midnight)
  shifted_night_range <- paste0("T00:00:00/T", shift, ":00:00")
  X_night <- X_night[shifted_night_range]
  Cn <- xts::period.apply(X_night, xts::endpoints(X_night, "days"), sum)

  # Computing Tn for the motion index
  # Tn <- 44 #44 samples * 15 minutes = 11 hours
  night_val <- Cn / Tn

  # Putting indices in date format to account for missing days
  zoo::index(day_val) <- base::as.Date(zoo::index(day_val))
  zoo::index(night_val) <- base::as.Date(zoo::index(night_val))

  common_dates_series <- xts::merge.xts(day_val, night_val, join = "inner")

  dates_series <- seq(
    from = zoo::index(common_dates_series)[1],
    to = last(zoo::index(common_dates_series)),
    by = 1
  )

  all_dates_series <- xts::merge.xts(common_dates_series, dates_series)
  d <- all_dates_series

  # computing the dirunality index
  df <- data.frame(
    date = zoo::index(d),
    diurnality = (zoo::coredata(d[, "day_val"]) - zoo::coredata(d[, "night_val"])) / (zoo::coredata(d[, "day_val"]) + zoo::coredata(d[, "night_val"]))
  )
  names(df) <- c("date", "diurnality")
  df <- na.omit(df)

  diurnality <- ggplot(data = df, aes(x = date, y = diurnality)) +
    geom_line() +
    ylab("Diurnality Index") +
    xlab("Date") +
    ylim(-1, 1) +
    theme(
      axis.text = element_text(color = "#000000"),
      text = element_text(size = 15),
      panel.background = element_rect(fill = "white"),
      axis.line = element_line(size = 0.5),
    ) +
    geom_hline(yintercept = 0, linetype = "dotted", col = "black")

  if (!is.null(save)) {
    cat("Saving image in :", save, "\n")
    ggsave(
      paste0(save, ".tiff"),
      diurnality,
      device = "tiff",
      width = 15,
      height = 6,
      units = "cm",
      dpi = 600
    )
  }

  print(diurnality)
}
