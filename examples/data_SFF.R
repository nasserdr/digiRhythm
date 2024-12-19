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

cow_dfc <- dfc(df_10min, activity = "activity")
all_DFCs <- NULL
# DFC for all cows
for (cow in ten_min_list){
  df_10min <- read_excel("examples/data/data_sff_bachman.xlsx",
                         sheet = cow, col_types = c("date",
                                                    "date", "numeric", "numeric", "numeric", "numeric",
                                                    "numeric", "numeric", "numeric"), skip = 10)
  cow_dfc <- dfc(df_10min,
                 activity = "activity",
                 sampling = 10,
                 harm_cutoff = 12,
                 rolling_window = 7,
                 plot = TRUE,
                 plot_harmonic_part = TRUE,
                 verbose = TRUE,
                 plot_lsp = FALSE
                 )

  data <- cow_dfc$data
  data$cow <- "57 - Ajlin"
  all_DFCs <- rbind(all_DFCs, data)
}

# Plot DFCs for all cows, line by line, one color per cow
ggplot(all_DFCs, aes(x = to, y = dfc, color = cow)) +
  geom_line() +
  geom_point() +
  theme_minimal() +
  labs(title = "Degree of Functional Coupling",
       x = "Date",
       y = "DFC") +
  theme(legend.position = "none")
