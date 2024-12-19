library(readxl)
library(digiRhythm)
library(dplyr)
library(tidyverse)

# Read the names of all sheets in the excel
sheets <- excel_sheets("examples/data/data_sff_bachman.xlsx")
daily_list <- sheets[grepl("_daily", sheets)]
ten_min_list <- sheets[grepl("_10min", sheets)]

# Sample sheet with 10 min

df_10min <- read_excel("examples/data/data_sff_bachman.xlsx",
                               sheet = "57 - Ajlin_10min", col_types = c("date",
                                                                         "date", "numeric", "numeric", "numeric", "numeric",
                                                      "numeric", "numeric", "numeric"), skip = 10)

# Sample sheet with daily
df_daily <- read_excel("examples/data/data_sff_bachman.xlsx",
                               sheet = "57 - Ajlin_daily", col_types = c("date",
                                                                         "date", "numeric"), skip = 10)


df_10min <- df_10min %>% select(c(1,5)) %>% mutate(activity = as.numeric(activity))

df_10min <- as.data.frame(df_10min)

is_dgm_friendly(df_10min, verbose = TRUE)

diurnality(df_10min,
           activity = "activity",
           day_time = c("06:30:00", "16:30:00"),
           night_time = c("18:00:00", "T05:00:00"),
           save = NULL)

actogram(df_10min,
         activity = "activity",
         activity_alias = "Activity",
         start = "2024-01-01",
         end = "2024-02-01", save = NULL)

daily_average_activity(df_10min,
                       activity = "activity",
                       activity_alias = 'Activity',
                       start = "2024-01-01",
                       end = "2024-01-28",
                       save = NULL)

dfc(data_sff_bachman, activity = "activity")
