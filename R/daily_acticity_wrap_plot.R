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
#' @param sampling_rate the sampling rate of the data.
#' @param ncols the number of columns to spread the graphs on.
#' be the name of the saved image. it should contain the path and name without
#' the extension.
#'
#' @return None
#'
#' @importFrom magrittr %>%
#' @importFrom stats time
#' @import ggplot2
#' @importFrom lubridate date
#' @import dplyr
#'
#' @export
#'
#' @examples
#' data("df516b_2")
#' df <- df516b_2
#' activity <- names(df)[2]
#' activity_alias <- 'Motion Index'
#' start <- "2020-05-01" #year-month-day
#' end <- "2020-05-07" #year-month-day
#' ncols <- 3
#' sampling_rate <- 30
#' my_dwp <- daily_activity_wrap_plot(df, activity, activity_alias, start, end, sampling_rate,
#' ncols)


daily_activity_wrap_plot <- function(
  df,
  activity,
  activity_alias,
  start,
  end,
  sampling_rate,
  ncols,
  save = 'daily_wrap_plot'

){
  start <- lubridate::date(start)
  end <- lubridate::date(end)

  df$date <- lubridate::date(df$datetime)
  data_to_plot <- df %>% filter(date >= start) %>% filter(date <= end)

  data_to_plot$time <- format(data_to_plot$datetime, format = "%H:%M", tz = "CET")



  # days <- unique(data_to_plot$date)
  # l <- ceiling(length(days)/ncols)

  # batch1 <- data_to_plot %>% filter(data_to_plot$date <= days[l])
  # batch2 <- data_to_plot %>% filter(data_to_plot$date > days[l])

  time2 = rep(1:(24*60/sampling_rate), length(unique(data_to_plot$date)))
  data_to_plot$time2 <- time2[1:dim(data_to_plot)[1]]

  avg_plot <- ggplot(data_to_plot, aes(
    x = time2,
    y = !!as.name(activity)))+
    geom_area() +
    facet_wrap(~date, ncol = ncols) +
    ggtitle(paste(activity_alias, "(", data_to_plot$date[1], "-", last(data_to_plot$date),")")) +
    xlab("Time") +
    theme(
      panel.background = element_rect(fill = "white"),
      legend.key = element_rect(fill = "white"),
      legend.key.width= unit(0.5, "cm"),
      legend.justification="left",
      legend.key.size = unit(7, "pt"),
      strip.background = element_blank(),
      strip.text.x = element_blank(),
      axis.title.y=element_blank(),
      axis.text.y=element_blank(),
      axis.ticks.y=element_blank(),
      axis.line=element_blank(),
      plot.title = element_text(hjust = 0.5),
      legend.position=c(0.05,0.89)) +
    scale_x_continuous(
      breaks = seq(sampling_rate - 2, 24*60/sampling_rate - sampling_rate+4, length.out = 4),
      labels = c("03:00", "09:00", "15:00", "21:00")
    )


  print(avg_plot)
  return(avg_plot)
}
