#' Plot daily average over a period of time for a specific variable.
#'
#' Takes an activity dataset as input and plot and save the daily average of the
#' specified activity column
#' @param df The dataframe containing the activity data
#' @param activity the name of activity
#' @param activity_alias A string containing the name of the activity to be
#' shown on the graph.
#' @param start The start day (in "%Y-%m-%d" format).
#' @param end The end day (in "%Y-%m-%d" format).
#' @param save if NULL, the image is not saved. Otherwise, this parameter will
#' be the name of the saved image. it should contain the path and name without
#' the extension.
#'
#' @return None
#'
#' @import magrittr
#' @import ggplot2
#' @import dplyr
#' @import lubridate
#'
#' @export
#'
#' @examples
#' data("df516b_2")
#' df <- df516b_2
#' activity <- names(df)[2]
#' start <- "2020-05-01" # year-month-day
#' end <- "2020-08-13" # year-month-day
#' activity_alias <- "Motion Index"
#' my_daa <- daily_average_activity(df, activity, activity_alias, start, end,
#'   save = NULL
#' )
#' print(my_daa)
daily_average_activity <- function(
    df,
    activity,
    activity_alias,
    start,
    end,
    save) {
  index_col_date = length(df) + 1
  df[, index_col_date] <- lubridate::date(df[,1])
  # data_to_plot <- df %>%
  #   filter(lubridate::date(datetime) >= start) %>%
  #   filter(lubridate::date(datetime) <= end)

  data_to_plot <- df[as.Date(df[,1]) >= start & as.Date(df[,1]) <= end, ]
  index_col_time <- length(data_to_plot) + 1
  data_to_plot$time <- format(data_to_plot[,1], format = "%H:%M")


  start <- lubridate::date(start)
  end <- lubridate::date(end)

  sum_of_activity_over_all_days_per_sample = NULL
  sum_of_activity_over_all_days_per_sample =  data.frame(
    time = as.character(),
    average = as.numeric()
  )

  for(t in unique(data_to_plot$time)){
    tdf <- data_to_plot %>% filter(time == t)
    mean = mean(tdf[[activity]])
    sum_of_activity_over_all_days_per_sample <- rbind(
      sum_of_activity_over_all_days_per_sample,
      data.frame(
        time = t,
        average = mean)
    )
  }

  s <- sum_of_activity_over_all_days_per_sample

  s$datetime <- paste(data_to_plot[1,index_col_date], s$time)
  s$datetime <- as.POSIXct(s$datetime, format("%Y-%m-%d %H:%M"))
  s <- s %>% select(datetime, average)

  avg_act_plot <- ggplot(
    s,
    aes(
      x = datetime,
      y = average
    )
  ) +
    geom_line() +
    xlab("Time") +
    ylab(paste0("Daily Average of ", activity_alias)) +
    scale_x_datetime(date_labels = "%H:%M") +
    theme_classic() +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme(
      axis.text = element_text(color = "black"),
      text = element_text(size = 15),
      panel.background = element_rect(fill = "white"),
      axis.line = element_line(size = 0.5)
    )


  if (!is.null(save)) {
    cat("Saving image in :", save, "\n")
    ggsave(
      paste0(save, ".tiff"),
      avg_act_plot,
      device = "tiff",
      width = 15,
      height = 6,
      units = "cm",
      dpi = 600
    )
  }

  print(avg_act_plot)

  return(avg_act_plot)
}
