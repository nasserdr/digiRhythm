#' Reads Raw Activity Data from csv files
#'
#' Reads Activity Data (data, time, activity(ies)) from a CSV file where we can skip
#' some lines (usually representing the metadata) and select specific activities.
#'
#' This function prepare the data stored in a csv to be compatible with the
#' digiRhythm package. You have the possibility to skip the first lines and
#' choose which columns to read. You also have the possibility to sample the data.
#' You can also choose whether to remove partial days (where no data over a
#' full day is present) by trimming last, middle or last days.
#' This function expects that the first and second columns are respectively
#' date and time where the format should be mentioned.
#'
#' file <- file.path('data', 'sample_data')
#' colstoread <- c("Date", "Time", "Motion Index", 'Steps') #The colums that we are interested in
#' data <- improt_raw_icetag_data(filename = file,
#'                                skipLines = 7,
#'                                act.cols.names = colstoread,
#'                                sampling = 15,
#'                                verbose = TRUE)
#'
#' @param filename The file name (full or relative path with extension)
#' @param skipLines The number of non-useful lines to skip (lines to header)
#' @param act.cols.names A vector containing the names of columns to read
#' (specific to the activity columns)
#' @param sep The delimiter/separator between the columns
#' @param original_tz The time zone with which the datetime are encoded
#' @param target_tz The time zone with which you want to process the data.
#' Setting this argument to 'GMT' will help you coping with daylight saving time
#' where changes occur two time a year.
#' @param date_format The POSIX format of the Date column (or first column)
#' @param time_format The POSIX format of the Time column (or second column)
#' @param sampling The sampling frequency in minutes (default 15 min)
#' @param trim_first_day if True, removes the data from the first day if it
#' contains less than 80% of the expected data points.
#' @param trim_middle_days if True, removes the data from the MIDDLE days if
#' they contain less than 80% of the expected data points.
#' @param trim_last_day if True, removes the data from the last day if it
#' contains less than 80% of the expected data points.
#' @param verbose print out some useful information during the execution
#' of the function
#'
#' @return A dataframe with datetime column and other activity columns, ready to
#' be used with other functions in digirhythm
#'
#' @importFrom tidyr unite
#' @importFrom magrittr %>%
#' @importFrom readr read_delim
#' @importFrom xts endpoints period.apply xts
#' @importFrom zoo coredata index
#' @importFrom dplyr filter select last tally
#' @importFrom utils read.table
#' @importFrom stringr str_trim
#' @importFrom lubridate date round_date
#'
#' @examples
#'
#' filename <- system.file("extdata", "sample_data.csv", package = "digiRhythm")
#' data <- import_raw_activity_data(
#'     filename,
#'     skipLines = 7,
#'     act.cols.names = c("Date", "Time", "Motion Index", 'Steps'),
#'     sep = ',',
#'     original_tz = 'CET',
#'     target_tz = 'CET',
#'     date_format = "%d.%m.%Y",
#'     time_format = "%H:%M:%S",
#'     sampling = 15,
#'     trim_first_day = TRUE,
#'     trim_middle_days = TRUE,
#'     trim_last_day = TRUE,
#'     verbose = TRUE)
#' print(head(data))
#'
#' @export


import_raw_activity_data <- function(filename,
                              skipLines = 0,
                              act.cols.names = c("Date", "Time", "Motion Index", 'Steps'),
                              date_format = "%d.%m.%Y",
                              time_format = "%H:%M:%S",
                              sep = ',',
                              original_tz = 'CET',
                              target_tz = 'CET',
                              sampling = 15,
                              trim_first_day = TRUE,
                              trim_middle_days = TRUE,
                              trim_last_day = TRUE,
                              verbose = FALSE){


  if (verbose) {
    print(paste('Reading the CSV file', filename))
  }

  #Loading data from the CSV (with specific columns and skipping lines)


  data <- read_delim(filename,
                     skip = skipLines,
                     delim = sep,
                     show_col_types = FALSE)[, act.cols.names]

  data <- na.omit(data)

  data <- data %>%
    mutate(across(where(is.character), str_trim))

  data <- data %>% unite(datetime, c(act.cols.names[1], act.cols.names[2]), sep = '-')

  data$datetime = as.POSIXct(data$datetime, format = paste0(date_format, " -", time_format), tz = original_tz)

  data$datetime = format(data$datetime, tz = target_tz)
  data$datetime = as.POSIXct(data$datetime, tz = target_tz)

  #Keep the datetime column + all other numeric-only columns // Remove non numeric cols
  if (verbose){
    cat('Removing the following columns because they are not numeric')
    cat('\n')
    cat(names(data[2:ncol(data)])[!sapply(data[,2:ncol(data)], is.numeric)])
  }
  data <- data[,c(TRUE, sapply(data[,2:ncol(data)], is.numeric))]



  #Remove rows where date is not defined
  data <- data[!is.na(data$datetime),]


  if (verbose) {
    print('First data points ... ')
    print(data.frame(data[1:3,]))
    print('Last data point ... ')
    print(data.frame(data[nrow(data):(nrow(data) - 2),]))
  }


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

  df$datetime <- lubridate::round_date(df$datetime, paste0(sampling, " mins"))

  #Skipping days. A day is skipped if it contains 80% less data that is
  #supposed to contains (respecting the sampling value). For example, if the
  #sampling value is 15 minutes, then a day should contains at least
  #0.8*60*24/15 samples (76.8 samples)


  smallest_mandatory_daily_samples = floor(0.8*60*24/sampling)

  if (verbose) {
    print(paste('Minimum Required number of samples per day', smallest_mandatory_daily_samples))
  }
  df$date = lubridate::date(df$datetime)

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
          print(paste('Data from the day', lubridate::date(day), 'has been removed (',
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
      length(unique(lubridate::date(df$datetime)))
    ))
  }

  df = df[!duplicated(df$datetime),]


 gc()
 return(df)
}
