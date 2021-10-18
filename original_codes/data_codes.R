library(dplyr)
library(tidyr)
library(readr)
library(xts)
library(usethis)
library(digiRhythm)

filename <- system.file("extdata", "516b_2.csv", package = "digiRhythm")

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


library(dplyr)
library(tidyr)
library(readr)
library(xts)
library(usethis)

filename <- system.file("extdata", "df678_2.csv", package = "digiRhythm")

df678_2 <- improt_raw_icetag_data(filename,
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


library(dplyr)
library(tidyr)
library(readr)
library(xts)
library(usethis)

filename <- system.file("extdata", "df689b_3.csv", package = "digiRhythm")

df689b_3 <- improt_raw_icetag_data(filename,
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


library(dplyr)
library(tidyr)
library(readr)
library(xts)
library(usethis)

filename <- system.file("extdata", "df691b_1.csv", package = "digiRhythm")

df691b_1 <- improt_raw_icetag_data(filename,
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


library(dplyr)
library(tidyr)
library(readr)
library(xts)
library(usethis)

filename <- system.file("extdata", "df759a_3.csv", package = "digiRhythm")


df759a_3 <- improt_raw_icetag_data(filename,
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
