#libraries
library(ggplot2)
library(magrittr)
library(lubridate)
library(dplyr)

#Example
data("df516b_2")
df <- df516b_2
activity <- names(df)[2]
start <- "2020-05-01" #year-month-day
end <- "2020-08-13" #year-month-day
activity_alias <- 'Motion Index'
save <- 'image' #if NULL, don't save the image

#Start of the function

df$date <- lubridate::date(df$datetime)
data_to_plot <- df %>%
  filter(lubridate::date(datetime) >= start) %>%
  filter(lubridate::date(datetime) <= end)
data_to_plot$time <- format(data_to_plot$datetime, format = "%H:%M", tz = "CET")

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

s$datetime <- paste(data_to_plot$date[1], s$time)
s$datetime <- as.POSIXct(s$datetime, format("%Y-%m-%d %H:%M"))

avg_act_plot <- ggplot(s,
                       aes(
                         x = datetime,
                         y = average
                       )) +
  geom_line() +
  xlab("Time") +
  ylab(paste0("Daily Average of ", activity_alias)) +
  scale_x_datetime(date_labels = "%H:%M") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(
    axis.text.x = element_text(color="#000000"),
    axis.text.y = element_text(color="#000000"),
    text=element_text(size = 12),
    panel.background = element_rect(fill = "white"),
    axis.line = element_line(size = 0.5))


if (!is.null(save)) {

  cat("Saving image in :", save, "\n")
  ggsave(
    paste0(save, '.tiff'),
    avg_act_plot,
    device = 'tiff',
    width = 15,
    height = 6,
    units = "cm",
    dpi = 600
  )
}

print(avg_act_plot)
