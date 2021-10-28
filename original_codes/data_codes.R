library(dplyr)
library(tidyr)
library(readr)
library(xts)
library(usethis)
library(digiRhythm)


#Data set 1

url <- 'https://github.com/nasserdr/digiRhythm_sample_datasets/raw/main/516b_2.csv'
download.file(url, destfile = '516b_2.csv')

filename <- file.path(getwd(), '516b_2.csv')

df516b_2 <- import_raw_icetag_data(filename,
                                   skipLines = 7,
                                   act.cols.names = c("Date", "Time", "Motion Index", 'Steps'),
                                   date_format = "%d.%m.%Y",
                                   time_format = "%H:%M:%S",
                                   sampling = 15,
                                   trim_first_day = TRUE,
                                   trim_middle_days = TRUE,
                                   trim_last_day = TRUE,
                                   verbose = FALSE)

df516b_2 %>% usethis::use_data(overwrite = TRUE)



#Data set 2
url <- 'https://github.com/nasserdr/digiRhythm_sample_datasets/raw/main/678_2.csv'
download.file(url, destfile = '678_2.csv')

filename <- file.path(getwd(), '678_2.csv')

df678_2 <- import_raw_icetag_data(filename,
                                  skipLines = 7,
                                  act.cols.names = c("Date", "Time", "Motion Index", 'Steps'),
                                  date_format = "%d.%m.%Y",
                                  time_format = "%H:%M:%S",
                                  sampling = 15,
                                  trim_first_day = TRUE,
                                  trim_middle_days = TRUE,
                                  trim_last_day = TRUE,
                                  verbose = TRUE)

df678_2  %>% usethis::use_data(overwrite = TRUE)

#Data set 3
url <- 'https://github.com/nasserdr/digiRhythm_sample_datasets/raw/main/689b_3.csv'
download.file(url, destfile = '689b_3.csv')

filename <- file.path(getwd(), '689b_3.csv')

df689b_3 <- import_raw_icetag_data(filename,
                                   skipLines = 7,
                                   act.cols.names = c("Date", "Time", "Motion Index", 'Steps'),
                                   date_format = "%d.%m.%Y",
                                   time_format = "%H:%M:%S",
                                   sampling = 15,
                                   trim_first_day = TRUE,
                                   trim_middle_days = TRUE,
                                   trim_last_day = TRUE,
                                   verbose = TRUE)
df689b_3 %>% usethis::use_data(overwrite = TRUE)


#Data set 4
url <- 'https://github.com/nasserdr/digiRhythm_sample_datasets/raw/main/691b_1.csv'
download.file(url, destfile = '691b_1.csv')

filename <- file.path(getwd(), '691b_1.csv')

df691b_1 <- import_raw_icetag_data(filename,
                                   skipLines = 7,
                                   act.cols.names = c("Date", "Time", "Motion Index", 'Steps'),
                                   date_format = "%d.%m.%Y",
                                   time_format = "%H:%M:%S",
                                   sampling = 15,
                                   trim_first_day = TRUE,
                                   trim_middle_days = TRUE,
                                   trim_last_day = TRUE,
                                   verbose = TRUE)

df691b_1 %>%usethis::use_data(overwrite = TRUE)

#Dataset 5
url <- 'https://github.com/nasserdr/digiRhythm_sample_datasets/raw/main/759a_3.csv'
download.file(url, destfile = '759a_3.csv')

filename <- file.path(getwd(), '759a_3.csv')


df759a_3 <- import_raw_icetag_data(filename,
                                   skipLines = 7,
                                   act.cols.names = c("Date", "Time", "Motion Index", 'Steps'),
                                   date_format = "%d.%m.%Y",
                                   time_format = "%H:%M:%S",
                                   sampling = 15,
                                   trim_first_day = TRUE,
                                   trim_middle_days = TRUE,
                                   trim_last_day = TRUE,
                                   verbose = TRUE)

df759a_3 %>% usethis::use_data(overwrite = TRUE)

file.remove(file.path(getwd(), '516b_2.csv'))
file.remove(file.path(getwd(), '678_2.csv'))
file.remove(file.path(getwd(), '689b_3.csv'))
file.remove(file.path(getwd(), '691b_1.csv'))
file.remove(file.path(getwd(), '759a_3.csv'))

