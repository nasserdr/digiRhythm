library(readxl)
library(digiRhythm)
library(dplyr)
library(tidyverse)
library(stringr)
library(reshape2)
library(dplyr)


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
  data$cow <- cow
  all_DFCs <- rbind(all_DFCs, data)

  name <- str_extract(cow, "\\w+(?=_)")
  name <- paste0('/home/agsad.admin.ch/f80859433/projects/digiRhythm/examples/data/', name, '_DFC.tiff')

  ggsave(
    name,
    cow_dfc,
    device = "tiff",
    width = 45,
    height = 18,
    units = "cm",
    dpi = 600
  )

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

csv_output <- '/home/agsad.admin.ch/f80859433/projects/digiRhythm/examples/data/all_cows_DFCs.csv'
write.csv(all_DFCs, csv_output, row.names = FALSE)


# Next idea
# Read all other parameters (Water intake + other data that can be summarized daily as an average)
# Create a new DF and csv for these data
# Merge them witht the DFC dataset
# Explore correlations with the DFC.

all_Params <- NULL
# DFC for all cows
for (cow in ten_min_list){
  df_10min <- read_excel("examples/data/data_sff_bachman.xlsx",
                         sheet = cow, col_types = c("date",
                                                    "date", "numeric", "numeric", "numeric", "numeric",
                                                    "numeric", "numeric", "numeric"), skip = 10)

  df_10min$to <- as.Date(df_10min$date)
  df_10min <- df_10min %>% mutate(to <- as.Date(df_10min$date)) %>%
    select(c(3:10))

  df_summary <- df_10min %>% group_by(to) %>% summarise_all(mean)
  df_summary$cow <- cow

  all_Params <- rbind(all_Params, df_summary)

}

# Merge all_Params and all_DFCs based on two keys: cow and to

all_data <- merge(all_Params, all_DFCs, by = c("cow", "to"))
numeric_cols <- all_data %>% select(-to, -from) %>% select_if(is.numeric)

# remove columns with only NA
numeric_cols <- numeric_cols[, colSums(is.na(numeric_cols)) != nrow(numeric_cols)]
pairs(numeric_cols)

# Assuming your data frame is named df
# Calculate the correlation matrix for each cow

# Next Next idea
# Check signigicant notes about the cows ...
