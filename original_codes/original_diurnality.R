#' Changes
#' Added two more arguments day_time night_time sampling
#' New import: hms from lubridate
#' Changes in code
#imports
library(xts) #xts period.apply endpoints merge.xts index
library(lubridate) #date hms
library(ggplot2)
library(digiRhythm)
#arguments
#data


activity <- 'Motion.Index'
day_time <- c("06:30:00", "16:30:00")
night_time <- c("18:00:00", "T05:00:00")

save <- 'sample_results/diurnality' #if NULL, don't save the image

#Configs
# data(df603, package = "digiRhythm")
data <- digiRhythm::df603
data <- remove_activity_outliers(data)
data <- resample_dgm(data, 15)
df_act_info(data)
activity = names(data)[2]

#Computing Cd
dates <- unique(lubridate::date(data[,1]))
X <- xts(
  x = data[[activity]],
  order.by = data[,1]
)

sampling <- dgm_periodicity(data)[["frequency"]]

#Code Addition 1
#Formatting the time range of the day
start_day <- paste0(
  'T',
  sprintf("%02d",attr(hms(day_time[1]),'hour')),
  ':',
  sprintf("%02d",attr(hms(day_time[1]),'minute')),
  ':00')

end_day <- paste0(
  'T',
  sprintf("%02d",attr(hms(day_time[2]),'hour')),
  ':',
  sprintf("%02d",attr(hms(day_time[2]),'minute')),
  ':00')

day_range = paste0(start_day, '/', end_day)

#Formatting the time range of the night
start_night <- paste0(
  'T',
  sprintf("%02d",attr(hms(night_time[1]),'hour')),
  ':',
  sprintf("%02d",attr(hms(night_time[1]),'minute')),
  ':00')

end_night <- paste0(
  'T',
  sprintf("%02d",attr(hms(night_time[2]),'hour')),
  ':',
  sprintf("%02d",attr(hms(night_time[2]),'minute')),
  ':00')

night_range = paste0(start_night, '/', end_night)

#Compute the range of samples for the day and the night
hms_day_start <- hms(day_time[1])
hms_day_end <- hms(day_time[2])
sample_size <- hms(paste0('00:', sampling, ':00'))
Td <- abs((hms_day_end - hms_day_start)/sample_size)

hms_night_start <- hms(night_time[1])
hms_midnight <- hms('00:00:00')
hms_24t <- hms('24:00:00')
hms_night_end <- hms(night_time[2])
Tn <- (hms_24t - hms_night_start +  hms_night_end - hms_midnight)/sample_size

#Check conditions about the day and night time (overlapping, misplacement)
if(hms_day_end > hms_night_start){
  stop('The end of the day_time period should proceed the beginning of the night_time period')
}

if(hour(hms_night_end) < 1){
  stop('The of the nightly period should be after midnight')
}

if(hour(hms_night_end) > 11){
  stop('The end of the nightly period cannot be after mid-day! Come on!')
}

X_day <- X[day_range]
Cd <- period.apply(X_day, endpoints(X_day, "days"), sum)

#Computing Td for the motion index
# Td <- 40 # 40 samples * 15 minutes = 10 hours
day_val <- Cd/Td

#Computing Cn for the motion index
X_night <- X[paste0(dates[1], "T12:00:00", "/", last(dates))]
X_night <- X_night[night_range]
X_night <- X[night_range]

offset <- 3600*hour(hms_night_start)
zoo::index(X_night) <- zoo::index(X_night) - offset
shift <-  hour(hms_24t - hms_night_start +  hms_night_end - hms_midnight)
shifted_night_range <- paste0("T00:00:00/T", shift ,":00:00")
X_night <- X_night[shifted_night_range]
Cn <- period.apply(X_night, endpoints(X_night, "days"), sum)

#Computing Tn for the motion index
# Tn <- 44 #44 samples * 15 minutes = 11 hours
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
  ylab("Diurnality Index") +
  xlab("Date") +
  ylim(-1,1) +
  theme(
    axis.text = element_text(color = "#000000"),
    text = element_text(size = 15),
    panel.background = element_rect(fill = "white"),
    axis.line = element_line(size = 0.5),
  ) + geom_hline(yintercept= 0, linetype='dotted', col = 'black')


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
