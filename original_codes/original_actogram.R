library(ggplot2)
library(xts)
data("df516b_2")
df <- df516b_2
df <- remove_activity_outliers(df)
df_act_info(df)
activity <- names(df)[2]
start <- "2020-30-04"
end <- "2020-06-05"
save <- FALSE
outputdir <- 'testresults'
outplotname <- 'actoplot'
width <- 10
device <- 'tiff'
height <-  5

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


df_filtered$date <- as.Date(df_filtered[[activity]], tz = "CET", origin = df_filtered[1,1])
df_filtered$time <- format(df_filtered[,1], format = "%H:%M", tz = "CET")


ggplot(df_filtered,
            aes(x = time,
                y = date,
                color = Motion.Index)) +
  geom_tile() +
  ylab("Date") +
  xlab("Time") +
  theme(
    axis.text.x = element_text(color = "#000000"),
    axis.text.y = element_text(color = "#000000"),
    text = element_text(family = 'Arial', size = 12),
    panel.background = element_rect(fill = "white"),
    axis.line = element_line(size = 0.5),
  ) +
  scale_colour_gradient(
    low = "#000000",
    high = "#FFFFFF",
    space = "Lab",
    na.value = "grey50",
    guide = "colourbar",
    aesthetics = "colour"
  ) +
  scale_x_discrete(breaks = c("03:00", "09:00", "15:00", "21:00"))
#  theme(legend.position = "none")

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
