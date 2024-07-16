#' Plot a an single actogram over a period of time for a specific variable
#'
#' Takes an activity dataset as input and plot and save an actogram of the
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
#' @return A ggplot2 object that contains the actogram plot
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
#' start <- "2020-05-01" # year-month-day
#' end <- "2020-08-13" # year-month-day
#' activity_alias <- "Motion Index"
#' my_actogram <- actogram(df, activity, activity_alias, start, end,
#'   save = NULL)
#' print(my_actogram)
actogram <- function(
    df,
    activity,
    activity_alias,
    start,
    end,
    save = "actogram") {
  start <- lubridate::date(start)
  end <- lubridate::date(end)

  names(df)[1] <- "datetime"

  df$date <- lubridate::date(df$datetime)
  data_to_plot <- df %>%
    filter(lubridate::date(datetime) >= start) %>%
    filter(lubridate::date(datetime) <= end)
  data_to_plot$time <- format(data_to_plot$datetime, format = "%H:%M", tz = "CET")
  data_to_plot <- data_to_plot %>% select(-datetime)

  data_to_plot$date_numeric <- xtfrm(as.Date(data_to_plot$date, format = "%Y-%m-%d"))


  equally_spaced_select <- function(x) {
    indices <- seq(1, length(x), by = 5)
    return(x[indices])
  }

  if (length(unique(data_to_plot$date_numeric)) > 15) {
    breaks_for_y_axis <- equally_spaced_select(unique(data_to_plot$date_numeric))
    labels_for_y_axis <- equally_spaced_select(unique(data_to_plot$date))
  } else {
    breaks_for_y_axis <- unique(data_to_plot$date_numeric)
    labels_for_y_axis <- unique(data_to_plot$date)
  }

  act_plot <- ggplot(
    data_to_plot,
    aes(
      x = time,
      y = date_numeric,
      fill = .data[[activity]]
    )
  ) +
    geom_tile() +
    xlab("Time") +
    ylab("Date") +
    scale_fill_gradient(
      name = activity_alias,
      low = "#FFFFFF",
      high = "#000000",
      na.value = "yellow"
    ) +
    theme_classic() +
    theme(plot.title = element_text(hjust = 0.5)) +
    scale_x_discrete(breaks = c("03:00", "09:00", "15:00", "21:00")) +
    theme(
      text = element_text(size = 15, color = "black"),
      axis.text = element_text(color = "black"),
      panel.background = element_rect(fill = "white"),
      axis.line = element_line(size = 0.5)
    ) +
    scale_y_reverse(
      breaks = breaks_for_y_axis,
      labels = labels_for_y_axis
    )

  if (!is.null(save)) {
    cat("Saving image in :", save, "\n")
    ggsave(
      paste0(save, ".tiff"),
      act_plot,
      device = "tiff",
      width = 15,
      height = 6,
      units = "cm",
      dpi = 600
    )
  }
  print(act_plot)
  return(act_plot)
}
