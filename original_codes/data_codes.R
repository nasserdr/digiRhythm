library(dplyr)
library(tidyr)
library(readr)
library(xts)
library(usethis)
library(digiRhythm)


#Data set 1

url <- 'https://raw.githubusercontent.com/nasserdr/digiRhythm_sample_datasets/main/516b_2.csv'
download.file(url, destfile = '516b_2.csv')

filename <- file.path(getwd(), '516b_2.csv')

df516b_2 <- import_raw_activity_data(filename,
                                   skipLines = 7,
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
                                   verbose = TRUE)

usethis::use_data(df516b_2, overwrite = TRUE)



#Data set 2
url <- 'https://raw.githubusercontent.com/nasserdr/digiRhythm_sample_datasets/main/678_2.csv'
download.file(url, destfile = '678_2.csv')

filename <- file.path(getwd(), '678_2.csv')

df678_2 <- import_raw_activity_data(filename,
                                  skipLines = 7,
                                  act.cols.names = c("Date", "Time", "Motion Index", 'Steps'),
                                  date_format = "%d.%m.%Y",
                                  time_format = "%H:%M:%S",
                                  sampling = 15,
                                  trim_first_day = TRUE,
                                  trim_middle_days = TRUE,
                                  trim_last_day = TRUE,
                                  verbose = TRUE)

usethis::use_data(df678_2, overwrite = TRUE)

#Data set 3
url <- 'https://raw.githubusercontent.com/nasserdr/digiRhythm_sample_datasets/main/689b_3.csv'
download.file(url, destfile = '689b_3.csv')

filename <- file.path(getwd(), '689b_3.csv')

df689b_3 <- import_raw_activity_data(filename,
                                   skipLines = 7,
                                   act.cols.names = c("Date", "Time", "Motion Index", 'Steps'),
                                   date_format = "%d.%m.%Y",
                                   time_format = "%H:%M:%S",
                                   sampling = 15,
                                   trim_first_day = TRUE,
                                   trim_middle_days = TRUE,
                                   trim_last_day = TRUE,
                                   verbose = TRUE)
usethis::use_data(df689b_3, overwrite = TRUE)


#Data set 4
url <- 'https://raw.githubusercontent.com/nasserdr/digiRhythm_sample_datasets/main/691b_1.csv'
download.file(url, destfile = '691b_1.csv')

filename <- file.path(getwd(), '691b_1.csv')

df691b_1 <- import_raw_activity_data(filename,
                                   skipLines = 7,
                                   act.cols.names = c("Date", "Time", "Motion Index", 'Steps'),
                                   date_format = "%d.%m.%Y",
                                   time_format = "%H:%M:%S",
                                   sampling = 15,
                                   trim_first_day = TRUE,
                                   trim_middle_days = TRUE,
                                   trim_last_day = TRUE,
                                   verbose = TRUE)

usethis::use_data(df691b_1, overwrite = TRUE)

#Dataset 5
url <- 'https://raw.githubusercontent.com/nasserdr/digiRhythm_sample_datasets/main/759a_3.csv'
download.file(url, destfile = '759a_3.csv')

filename <- file.path(getwd(), '759a_3.csv')


df759a_3 <- import_raw_activity_data(filename,
                                   skipLines = 7,
                                   act.cols.names = c("Date", "Time", "Motion Index", 'Steps'),
                                   date_format = "%d.%m.%Y",
                                   time_format = "%H:%M:%S",
                                   sampling = 15,
                                   trim_first_day = TRUE,
                                   trim_middle_days = TRUE,
                                   trim_last_day = TRUE,
                                   verbose = TRUE)

usethis::use_data(df759a_3, overwrite = TRUE)


#Dataset 6 (contains 1 missing day)
url <- 'https://raw.githubusercontent.com/nasserdr/digiRhythm_sample_datasets/main/603.csv'
download.file(url, destfile = '603.csv')

filename <- file.path(getwd(), '603.csv')

df603 <- import_raw_activity_data(filename,
                                   act.cols.names = c("Date", "Time", "move_x", 'move_y'),
                                   skipLines = 0,
                                   date_format = "%Y-%m-%d",
                                   time_format = "%H:%M:%S",
                                   sep = ';',
                                   original_tz = 'CET',
                                   target_tz = 'CET',
                                   sampling = 1,
                                   trim_first_day = TRUE,
                                   trim_middle_days = TRUE,
                                   trim_last_day = TRUE,
                                   verbose = FALSE)

# a %>% usethis::use_data(overwrite = TRUE)
usethis::use_data(df603, overwrite = TRUE)

#Dataset 7 (contains 2 missing days)
url <- 'https://raw.githubusercontent.com/nasserdr/digiRhythm_sample_datasets/main/625.csv'
download.file(url, destfile = '625.csv')

filename <- file.path(getwd(), '625.csv')

df625 <- import_raw_activity_data(filename,
                                  act.cols.names = c("Date", "Time", "move_x", 'move_y'),
                                  skipLines = 0,
                                  date_format = "%Y-%m-%d",
                                  time_format = "%H:%M:%S",
                                  sep = ';',
                                  original_tz = 'CET',
                                  target_tz = 'CET',
                                  sampling = 1,
                                  trim_first_day = TRUE,
                                  trim_middle_days = TRUE,
                                  trim_last_day = TRUE,
                                  verbose = FALSE)

 usethis::use_data(df625, overwrite = TRUE)


file.remove(file.path(getwd(), '516b_2.csv'))
file.remove(file.path(getwd(), '678_2.csv'))
file.remove(file.path(getwd(), '689b_3.csv'))
file.remove(file.path(getwd(), '691b_1.csv'))
file.remove(file.path(getwd(), '759a_3.csv'))
file.remove(file.path(getwd(), '603.csv'))
file.remove(file.path(getwd(), '625.csv'))
