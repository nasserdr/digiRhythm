## code to prepare `df678_2` dataset goes here
library(dplyr)
library(tidyr)
library(readr)
library(xts)
library(usethis)
df678_2 <- improt_raw_icetag_data(file.path('data-raw', '678_2.csv'),
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
