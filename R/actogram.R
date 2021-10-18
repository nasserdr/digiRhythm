#' Plot a an single actogram over a period of time for a specific variable
#'
#' Takes an activity dataset as input and plot and save an actogram of the
#' specified activity column
#' @param df The dataframe containing the activity data
#' @param activity the name of activity
#' @param start The start day (in "%Y%m%d" format)
#' @param end The end day (in "%Y%m%d" format)
#' @param save TRUE if you want to save the image (if TRUE, subsequent arguments
#' should be provided)
#' @param outputdir the directory where you wish to save the image
#' @param outplotname the name of the output plot (only name, without device
#' extension nor path)
#' @param width width of the image in cm
#' @param height height of the image in cm
#' @param device one of 'tiff', 'png', 'pdf', 'jpg'
#'
#' @return None
#'
#' @importFrom magrittr %>%
#' @importFrom zoo index coredata
#' @importFrom xts xts
#' @importFrom stats time
#' @import ggplot2 extrafont
#'
#' @export
#'
#' @examples
#' data("df516b_2", package = "digiRhythm")
#' df <- df516b_2
#' df <- remove_activity_outliers(df)
#' df_act_info(df)
#' activity = names(df)[2]
#' start = "2020-30-04"
#' end = "2020-06-05"
#' save = TRUE
#' outputdir = 'testresults'
#' outplotname = 'myplot'
#' width = 10
#' device = 'tiff'
#' height =  5
#' actogram(df, activity, start, end, save = FALSE,
#'     outputdir = 'testresults', outplotname = 'actoplot', width = 10,
#'     height =  5, device = 'tiff')

actogram <- function(
  df,
  activity,
  start,
  end,
  save = FALSE,
  outputdir = 'testresults',
  outplotname = 'actoplot',
  width = 10,
  device = 'tiff',
  height =  5
){
  #function starts here

  print('start function')
  selection = paste0(start, '/', end)

  start_date <- as.POSIXct(start, format = "%Y%m%d", tz = "CET")
  end_date <- as.POSIXct(end, format = "%Y%m%d", tz = "CET")

  df_xts <- xts(
    x = df[[activity]],
    order.by = df[,1],
    tzone = "CET"
  )

  df_xts = df_xts[selection]

  df_filtered = data.frame(
    datetime = index(df_xts),
    value = coredata(df_xts)
  )

  names(df_filtered) <- names(df)[1:ncol(df_filtered)]


  print(head(df_filtered))
  df_filtered$date <- base::as.Date(df_filtered[[activity]], tz = "CET", origin = df_filtered[1,1])
  df_filtered$time <- format(df_filtered[,1], format = "%H:%M", tz = "CET")


  p <- ggplot(df_filtered,
              aes(x = time,
                  y = date,
                  color = activity)) +
    geom_tile() +
    ylab("Date") +
    xlab("Time") +
    theme(
      axis.text.x = element_text(color = "#000000"),
      axis.text.y = element_text(color = "#000000"),
      text = element_text(size = 12),
      panel.background = element_rect(fill = "white"),
      axis.line = element_line(size = 0.5),
    )  +
    scale_x_discrete(breaks = c("03:00", "09:00", "15:00", "21:00")) +
    theme(legend.position = "none")

  print('plot done')
  if (save == TRUE) {

    if (!file.exists(outputdir)) {
      dir.create(outputdir)
    }


    cat("Saving image in :", outplotname, "\n")
    ggsave(
      filename = file.path(outputdir, paste0(outplotname,'.',device)),
      plot = p,
      device = device,
      width = width,
      height = height,
      units = 'cm'
    )} else{
      print(p)
    }
}
