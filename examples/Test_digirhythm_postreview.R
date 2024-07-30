#Loading DigiRhythm
library(digiRhythm)
setwd("~/projects/digiRhythm/examples")

data73438 <- import_raw_activity_data(filename = "73438.csv",
                                      skipLines = 7,
                                      act.cols.names = c("Date", "Time", "Motion Index", "Steps"),
                                      date_format = "%d.%m.%Y",
                                      time_format = "%H:%M:%S",
                                      sep = ",",
                                      original_tz = "CET",
                                      target_tz = "GMT",
                                      sampling = 5,
                                      trim_first_day = TRUE,
                                      trim_middle_days = TRUE,
                                      trim_last_day = TRUE,
                                      verbose = FALSE)

is_dgm_friendly(data73438)

activity = names(data73438[2])
df <- data73438[1:5000, c(1, 2)]
sampling <- 5
harm_cutoff <- 100
test_sampl_5min <- dfc(df,
                  activity,
                  sampling = sampling,
                  alpha = 0.05,
                  harm_cutoff = harm_cutoff,
                  rolling_window = 7,
                  plot = TRUE,
                  plot_harmonic_part = TRUE,
                  verbose = TRUE,
                  plot_lsp = TRUE)

##### Importing Data 30 min sampling #####
data73438 <- import_raw_activity_data(filename = "73438.csv",
                                      skipLines = 7,
                                      act.cols.names = c("Date", "Time", "Motion Index", "Steps"),
                                      date_format = "%d.%m.%Y",
                                      time_format = "%H:%M:%S",
                                      sep = ",",
                                      original_tz = "CET",
                                      target_tz = "GMT",
                                      sampling = 30,
                                      trim_first_day = TRUE,
                                      trim_middle_days = TRUE,
                                      trim_last_day = TRUE,
                                      verbose = FALSE)

is_dgm_friendly(data73438)

test_sampl_5min <- dfc(data73438,
                       activity,
                       sampling = 30,
                       alpha = 0.05,
                       harm_cutoff = 29,
                       rolling_window = 7,
                       plot = TRUE,
                       plot_harmonic_part = TRUE,
                       verbose = TRUE,
                       plot_lsp = TRUE)
