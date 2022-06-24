#libraries import
library(ggplot2)
library(lubridate)
library(dplyr)


#Example
data("df516b_2")
df <- df516b_2
activity <- names(df)[2]
start <- "2020-05-01" #year-month-day
end <- "2020-08-13" #year-month-day
activity_alias <- 'Motion Index'
save <- 'sample_results/actogram' #if NULL, don't save the image

#Start of the function
start <- lubridate::date(start)
end <- lubridate::date(end)

names(df)[1] <- 'datetime'


df$date <- lubridate::date(df$datetime)
data_to_plot <- df %>%
  filter(lubridate::date(datetime) >= start) %>%
  filter(lubridate::date(datetime) <= end)
data_to_plot$time <- format(data_to_plot$datetime, format = "%H:%M", tz = "CET")

act_plot <- ggplot(data_to_plot,
                   aes(x = time,
                       y = date,
                       fill = .data[[activity]])) +
  geom_tile()+
  xlab("Time")+
  ylab("Date") +
  ggtitle("Single actogram") +
  scale_fill_gradient(name = activity_alias,
                      low = "#FFFFFF",
                      high = "#000000",
                      na.value = "yellow")+
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_x_discrete(breaks = c("03:00", "09:00", "15:00", "21:00")) +
  theme(
    axis.text.x = element_text(color="#000000"),
    axis.text.y = element_text(color="#000000"),
    text=element_text(family = 'Arial', size = 12),
    panel.background = element_rect(fill = "white"),
    axis.line = element_line(size = 0.5)
  )


if (!is.null(save)) {

  cat("Saving image in :", save, "\n")
  ggsave(
    paste0(save, '.tiff'),
    act_plot,
    device = 'tiff',
    width = 15,
    height = 6,
    units = "cm",
    dpi = 600
  )
}

print(act_plot)
