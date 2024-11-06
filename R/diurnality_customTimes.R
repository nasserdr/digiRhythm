#' Computes the diurnality index, using different start and end definitions for
#' each day and night, based on an activity dataframe
#'
#' @param data a digiRhythm-friendly dataset
#' @param activity The number of non-useful lines to skip (lines to header)
#' @param timedata a dataset, including 4 columns of POSIXct format, including
#' date and time "day_start", "day_end", "night_start", "night_end"
#' @param save if NULL, the image is not saved. Otherwise, this parameter will
#' be the name of the saved image. it should contain the path and name without
#' the extension.
#'
#' @return A ggplot2 object that contains the Sliding diurnality plot in
#' addition to a dataframe with 2 col: date and sliding diurnality index
#'
#' @import ggplot2
#'
#' @examples
#' data("df516b_2", package = "digiRhythm")
#' data <- df516b_2
#' data <- remove_activity_outliers(data)
#' activity <- names(data)[2]
#' data("timedata", package = "digiRhythm")
#' timedata <- timedata
#' d_index <- diurnality_customTimes(data, activity, timedata)
#'
#' @export

diurnality_customTimes <- function(data,
                       activity,
                       timedata,
                       save = NULL) {
  start_date <- lubridate::date(data[, 1])[1]
  end_date <- last(lubridate::date(data[, 1]))

  dates <- unique(lubridate::date(data[, 1]))
  X <- xts::xts(x = data[[activity]], order.by = data[, 1])
  sampling <- dgm_periodicity(data)[["frequency"]]

  # Formatting time range of day and night
  timedata <- subset(timedata, lubridate::date(timedata$night_end) >=
    start_date & lubridate::date(timedata$night_end)
  <= end_date)
  day_range <- paste0(timedata$day_start, "/", timedata$day_end)
  night_range <- paste0(
    timedata$night_start, "/",
    timedata$night_end[2:nrow(timedata)]
  )

  # Compute the range of samples for the day and the night (Td & Tn)
  hms_day_start <- lubridate::hms(substr(timedata$day_start, 12, 19))
  hms_day_end <- lubridate::hms(substr(timedata$day_end, 12, 19))
  sample_size <- lubridate::hms(paste0("00:", sampling, ":00"))
  Td <- abs((hms_day_end - hms_day_start) / sample_size)

  hms_night_start <- lubridate::hms(substr(timedata$night_start[1:nrow(timedata)
  - 1], 12, 19))
  hms_midnight <- lubridate::hms("00:00:00")
  hms_24t <- lubridate::hms("24:00:00")
  hms_night_end <- lubridate::hms(substr(
    timedata$night_end[2:nrow(timedata)],
    12, 19
  ))
  Tn <- (hms_24t - hms_night_start + hms_night_end - hms_midnight) / sample_size

  # Computing Cd
  X_day <- X[day_range]
  Cd <- xts::period.apply(X_day, xts::endpoints(X_day, "days"), sum)

  # Computing day value
  day_val <- Cd / Td

  # Computing Cn
  X_night <- X[night_range]
  offset <- 3600 * lubridate::hour(lubridate::hms("12:00:00"))
  zoo::index(X_night) <- zoo::index(X_night) - offset
  Cn <- xts::period.apply(
    X_night, xts::endpoints(X_night, "days"),
    sum
  )

  # Computing night value
  night_val <- Cn / Tn

  # Putting indices in date format to account for missing days
  zoo::index(day_val) <- base::as.Date(zoo::index(day_val))
  zoo::index(night_val) <- base::as.Date(zoo::index(night_val))

  common_dates_series <- xts::merge.xts(day_val, night_val, join = "inner")

  dates_series <- seq(
    from = zoo::index(common_dates_series)[1],
    to = last(zoo::index(common_dates_series)), by = 1
  )

  all_dates_series <- xts::merge.xts(common_dates_series, dates_series)
  d <- all_dates_series

  # Computing the diurnality index
  df <- data.frame(
    date = zoo::index(d),
    diurnality = (zoo::coredata(d[, "day_val"]) - zoo::coredata(d[
      ,
      "night_val"
    ]))
    / (zoo::coredata(d[, "day_val"]) + zoo::coredata(d[, "night_val"]))
  )

  names(df) <- c("date", "diurnality")
  df <- na.omit(df)

  # Visualization
  diurnality <- ggplot(data = df, aes(x = date, y = diurnality)) +
    geom_line() +
    ylab("Diurnality Index") +
    xlab("Date") +
    ylim(-1, 1) +
    theme(
      axis.text = element_text(color = "#000000"),
      text = element_text(size = 15),
      panel.background = element_rect(fill = "white"),
      axis.line = element_line(linewidth = 0.5),
    ) +
    geom_hline(yintercept = 0, linetype = "dotted", col = "black")


  if (!is.null(save)) {
    cat("Saving image in :", save, "\n")
    ggsave(paste0(save, ".tiff"), diurnality,
      device = "tiff",
      width = 15, height = 6, units = "cm", dpi = 600
    )
  }

  print(diurnality)
}
