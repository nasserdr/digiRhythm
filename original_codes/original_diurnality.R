#imports
library(xts) #xts period.apply endpoints merge.xts index
library(lubridate) #date
library(ggplot2)

#arguments
#data
activity <- 'Motion.Index'
save <- 'sample_results/diurnality' #if NULL, don't save the image

#Configs
data("df", package = "digiRhythm")
data <- df603
data <- remove_activity_outliers(data)
df_act_info(data)
activity = names(data)[2]

#Computing Cd
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

#Putting indices in date format to account for missing days
zoo::index(day_val) = base::as.Date(zoo::index(day_val))
zoo::index(night_val) = base::as.Date(zoo::index(night_val))

common_dates_series <- xts::merge.xts(day_val, night_val, join ='inner')

dates_series = seq(from = zoo::index(common_dates_series)[1],
                   to = last(zoo::index(common_dates_series)),
                             by = 1)

all_dates_series = xts::merge.xts(common_dates_series, dates_series)
d <- all_dates_series

#computing the dirunality index
df <- data.frame(
  date = zoo::index(d),
  diurnality = (coredata(d[,'day_val']) - coredata(d[,'night_val']))/(coredata(d[,'day_val']) + coredata(d[,'night_val']))
)
names(df) = c('date', 'diurnality')
df <- na.omit(df)

diurnality <- ggplot(data = df, aes(x = date, y = diurnality)) +
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

if (!is.null(save)) {

  cat("Saving image in :", save, "\n")
  ggsave(
    paste0(save, '.tiff'),
    diurnality,
    device = 'tiff',
    width = 15,
    height = 6,
    units = "cm",
    dpi = 600
  )
}

print(diurnality)
