
#Did not include a default "timedata".
#next changes should be the implementation of the first "diurnality" function, so that one could use one function for DI except if he has several or one definition for day and nighttime.

#imports
library(xts) 
library(lubridate) 
library(ggplot2)
library(digiRhythm)

#arguments
activity <- 'Motion.Index'
timedata <- timedata

save <- 'sample_results/sliding_DI' #if NULL, don't save the image


start_date <- lubridate::date(data[, 1])[1]
end_date <- last(lubridate::date(data[, 1]))
  
dates <- unique(lubridate::date(data[, 1]))
X <- xts(x = data[[activity]], order.by = data[, 1])
sampling <- dgm_periodicity(data)[["frequency"]]

#Formatting time range of day and night
timedata <- subset(timedata, lubridate::date(timedata$night_end) >= start_date & lubridate::date(timedata$night_end) <= end_date)
day_range = paste0(timedata$day_start, "/", timedata$day_end)
night_range = paste0(timedata$night_start, "/", timedata$night_end[2:nrow(timedata)])
 
#Compute the range of samples for the day and the night (Td & Tn)
hms_day_start <- hms(substr(timedata$day_start, 12, 19))
hms_day_end <- hms(substr(timedata$day_end, 12, 19))
sample_size <- hms(paste0("00:", sampling, ":00"))
Td <- abs((hms_day_end - hms_day_start)/sample_size)

hms_night_start <- hms(substr(timedata$night_start[1:nrow(timedata)-1], 12, 19))
hms_midnight <- hms("00:00:00")
hms_24t <- hms("24:00:00")
hms_night_end <- hms(substr(timedata$night_end[2:nrow(timedata)], 12, 19))
Tn <- (hms_24t - hms_night_start + hms_night_end - hms_midnight)/sample_size

#Check conditions about the day and night time (overlapping, misplacement)
  #if (hms_day_end > hms_night_start) {
  #stop("The end of the day_time period should proceed the beginning of the night_time period")
  #}
  #if (hour(hms_night_end) < 1) {
  #stop("The of the nightly period should be after midnight")
  #}
  #if (hour(hms_night_end) > 11) {
  #stop("The end of the nightly period cannot be after mid-day! Come on!")
  #}

#Computing Cd
X_day <- X[day_range]
Cd <- period.apply(X_day, endpoints(X_day, "days"), sum)

#Computing day value
day_val <- Cd/Td

#Computing Cn
X_night <- X[night_range]
offset <- 3600 * hour(hms("12:00:00"))
zoo::index(X_night) <- zoo::index(X_night) - offset  
Cn <- period.apply(X_night, endpoints(X_night, "days"), 
                     sum)

#Computing night value
night_val <- Cn/Tn

#Putting indices in date format to account for missing dayszoo::index(day_val) = base::as.Date(zoo::index(day_val))
zoo::index(night_val) = base::as.Date(zoo::index(night_val))

common_dates_series <- xts::merge.xts(day_val, night_val, join = "inner")

dates_series = seq(from = zoo::index(common_dates_series)[1], 
                     to = last(zoo::index(common_dates_series)), by = 1)

all_dates_series = xts::merge.xts(common_dates_series, dates_series)
d <- all_dates_series

#Computing the diurnality index
df <- data.frame(
    date = zoo::index(d), 
    diurnality = (coredata(d[, "day_val"]) - coredata(d[, "night_val"]))/(coredata(d[, "day_val"]) + coredata(d[, "night_val"]))
)

names(df) = c("date", "diurnality")
df <- na.omit(df)

#Visualization
diurnality <- ggplot(data = df, aes(x = date, y = diurnality)) + 
    geom_line() + ylab("Diurnality Index") + xlab("Date") + ylim(-1,1) +
    theme(axis.text = element_text(color = "#000000"), text = element_text(size = 15), 
          panel.background = element_rect(fill = "white"), 
          axis.line = element_line(linewidth = 0.5), ) + 
    geom_hline(yintercept = 0, linetype = "dotted", col = "black")

if (!is.null(save)) {
    cat("Saving image in :", save, "\n")
    ggsave(paste0(save, ".tiff"), diurnality, device = "tiff", 
           width = 15, height = 6, units = "cm", dpi = 600)
}

print(diurnality)
