library(readr) #read_csv
library(tidyr) #unite
#tidyr readr magrittr dplyr xts ggplot2


filename <- 'D:/Agroscope/digiRhythm/inst/extdata/sample_data.csv'
skipLines <- 7
act.cols.names <- c("Date", "Time", "Motion Index", 'Steps')
date_format <- "%d.%m.%Y"
time_format <- "%H:%M:%S"
sampling <- 15
trim_first_day <- TRUE
trim_middle_days <-  TRUE
trim_last_day <- TRUE
verbose <- FALSE




if (verbose) {
  print(paste('Reading the CSV file', filename))
}

#Loading data from the CSV (with specific columns and skipping lines)
data <- read_csv(filename, skip = skipLines, )[ ,act.cols.names]

data <- data %>% unite(datetime, c(act.cols.names[1], act.cols.names[2]), sep = '-')

data$datetime = as.POSIXct(data$datetime, format = paste0(date_format, "-", time_format), tz = 'CET')

if (verbose) {
  print('First data points ... ')
  print(data.frame(data[1:3,]))
  print('Last data point ... ')
  print(data.frame(data[nrow(data):(nrow(data) - 2),]))
}

data <- data[!is.na(data$datetime),]

#Transforming data to an XTS for easy management of sampling and date removal
data_xts = xts(
  data[,2:ncol(data)],
  order.by = data$datetime
)

#Sampling the data set according to the sampling argument
data_xts_sampled <- NULL
for (var in names(data_xts)) {
  var_xts <- xts::period.apply(
    data_xts[,var],
    endpoints(data_xts, "minutes", k = sampling),
    FUN = sum
  )
  data_xts_sampled <- cbind(data_xts_sampled, var_xts)
}


#Creating a dataframe from the sampled XTS (what we will return)
df <- data.frame(
  datetime = index(data_xts_sampled),
  coredata(data_xts_sampled))

#Skipping days. A day is skipped if it contains 80% less data that is
#supposed to contains (respecting the sampling value). For example, if the
#sampling value is 15 minutes, then a day should contains at least
#0.8*60*24/15 samples (76.8 samples)


smallest_mandatory_daily_samples = floor(0.8*60*24/sampling)

if (verbose) {
  print(paste('Minimum Required number of samples per day', smallest_mandatory_daily_samples))
}
df$date = as.Date(df$datetime, tz = 'CET')

if (trim_first_day) {
  n_samples_day1 <- df %>% filter(date == unique(df$date)[1]) %>% tally()
  if (n_samples_day1 < smallest_mandatory_daily_samples) {
    df <- df %>% filter(date != unique(df$date)[1])
  } else {
    if (verbose) {
      print('No data has been removed from the beginning')
    }
  }
}


if (trim_last_day) {
  n_samples_day_last <- df %>% filter(date == last(unique(df$date))) %>% tally()
  if (n_samples_day_last < smallest_mandatory_daily_samples) {
    df <- df %>% filter(date != last(unique(df$date)))
  } else {
    if (verbose) {
      print('No data has been removed from the end')
    }
  }
}

if (trim_middle_days) {
  for (day in unique(df$date)) {
    n_samples_middle_day <- df %>% filter(date == day) %>% tally()
    if (n_samples_middle_day < smallest_mandatory_daily_samples) {
      df <- df %>% filter(date != day)

      if (verbose) {
        print(paste('Data from the day', as.Date(day), 'has been removed (',
                    n_samples_middle_day, ') samples only - Too small'))
      }
    }
  }
}

df <- df %>% select(-date)

if (verbose) {
  print(paste(
    'Returning a data frame with datetime colum and',
    ncol(df) - 1, 'variable colums'
  ))

  print(paste(
    'Total number of samples is',
    nrow(df),
    '- Total number of days is',
    length(unique(as.Date(df$datetime)))
  ))
}
