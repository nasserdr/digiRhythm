#' Computes the diurnality index based on an activity dataframe
#'
#' @param data a digiRhythm-friendly dataset
#' @param activity The number of non-useful lines to skip (lines to header)
#' @param plot if True, show the plot of diurnality index on the screen
#'
#' @return A dataframe with 2 col: date and diurnality index
#'
#' @importFrom lubridate date
#' @importFrom xts xts period.apply
#' @importFrom zoo index coredata
#'
#' @examples
#' data("df516b_2", package = "digiRhythm")
#' data <- df516b_2
#' data <- remove_activity_outliers(data)
#' activity = names(data)[2]
#' d_index <- diurnality(data, activity)

#' @export

diurnality <- function(data, activity, plot = FALSE){

  #di = (cd/td - cn/tn)/(cd/td + cn/tn)

  dates <- unique(lubridate::date(data$datetime))
  X <- xts(
    x = data[[activity]],
    order.by = data$datetime
  )

  X_day <- X["T06:30:00/T16:30:00"]
  Cd <- period.apply(X_day, endpoints(X_day, "days"), sum)

  #Computing Td for the motion index
  Td <- 40 # 40 samples * 15 minutes = 10 hours
  day_val <- Cd/Td

  #Computing Cn for the motion index
  X_night <- X[paste0(dates[1], "T15:00:00", "/", last(dates))]
  X_night <- X_night["T18:00:00/T05:00:00"]

  offset <- 3600*18
  zoo::index(X_night) <- zoo::index(X_night) - offset
  X_night <- X_night["T00:00:00/T11:00:00"]
  Cn <- period.apply(X_night, endpoints(X_night, "days"), sum)

  #Computing Tn for the motion index
  Tn <- 44 #44 samples * 15 minutes = 11 hours
  night_val <- Cn/Tn


  df <- data.frame(
    date = dates,
    diurnality = (coredata(day_val) - coredata(night_val))/(coredata(day_val) + coredata(night_val))
  )

  p <- ggplot(data = df, aes(x = dates, y = diurnality)) +
    geom_line() +
    ylab("Date") +
    xlab("Diurnality Index") +
    theme(
      axis.text.x = element_text(color = "#000000"),
      axis.text.y = element_text(color = "#000000"),
      text = element_text(size = 12),
      panel.background = element_rect(fill = "white"),
      axis.line = element_line(size = 0.5),
    )

  if (plot) {
    print(p)
  }

}
