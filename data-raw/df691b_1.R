## code to prepare `df691b_1` dataset goes here
library(dplyr)
library(tidyr)
library(readr)
library(xts)
library(usethis)
df691b_1 <- improt_raw_icetag_data(file.path('data-raw', '691b_1.csv'),
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
