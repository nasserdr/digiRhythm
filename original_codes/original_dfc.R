library(digiRhythm)
library(lubridate) #data
library(dplyr)
library(stringr) #str_replace
library(ggplot2)

#Arguments configuration

#Dataset without interruption
data("df516b_2", package = "digiRhythm")
df <- df516b_2
activity = names(df)[2]
sampling = 5
sig <- 0.05
plot <- TRUE
verbose = TRUE


##Dataset with interruption
# url <- 'https://raw.githubusercontent.com/nasserdr/digiRhythm_sample_datasets/main/625.csv'
# download.file(url, destfile = '603.csv')
#
# filename <- file.path(getwd(), '603.csv')
#
# df625 <- import_raw_activity_data(filename,
#                                   act.cols.names = c("Date", "Time", "move_x", 'move_y'),
#                                   skipLines = 0,
#                                   date_format = "%Y-%m-%d",
#                                   time_format = "%H:%M:%S",
#                                   sep = ';',
#                                   original_tz = 'CET',
#                                   target_tz = 'CET',
#                                   sampling = 15,
#                                   trim_first_day = TRUE,
#                                   trim_middle_days = TRUE,
#                                   trim_last_day = TRUE,
#                                   verbose = FALSE)
# df625 <- remove_activity_outliers(df625)
# activity = names(df625)[2]
# sampling = 15
# sig <- 0.05
# plot <- TRUE
# verbose = TRUE
# plot_harmonic_part = TRUE

#dataset df691b_1 (for testing the new LSP function)
# data("df691b_1", package = "digiRhythm")
# data <- df691b_1[1:1344, c(1,2)]
# sig = 0.05
# activity = names(data)[2]
# sampling = 15
# plot <- TRUE
# verbose = TRUE
plot_harmonic_part = TRUE
harm_cutoff <- 60
rolling_window <- 7
#Example from Marie's dataset

#Start of the function body
#We assume that the first column is a datetime column and the other columns are activity columns
#df should be a dataframe

# target_tz <- 'GMT'
# data <- import_raw_activity_data("team/marie/12112.csv",
#                                skipLines = 7,
#                                act.cols.names = c("Date", "Time", "Motion Index", "Steps"),
#                                date_format = "%d.%m.%Y",
#                                time_format = "%H:%M:%S",
#                                sep = ",",
#                                original_tz = "CET",
#                                target_tz = target_tz,
#                                sampling = 15,
#                                trim_first_day = TRUE,
#                                trim_middle_days = TRUE,
#                                trim_last_day = TRUE,
#                                verbose = FALSE)
#
# sig = 0.05
# activity = names(data)[2]
# sampling = 15
# plot <- TRUE
# verbose = TRUE
# rolling_window = 7
# harm_cutoff <- 60
# plot_harmonic_part = TRUE


#Example data SFF
df <- read_excel("examples/data/data_sff_bachman.xlsx",
                       sheet = "57 - Ajlin_10min", col_types = c("date",
                                                                 "date", "numeric", "numeric", "numeric", "numeric",
                                                                 "numeric", "numeric", "numeric"), skip = 10)
df <- df %>% select(c(1,5)) %>% mutate(activity = as.numeric(activity))
df <- as.data.frame(df, row.names = NULL)

if (!is_dgm_friendly(df)) {
  stop('The data is not digiRhythm friendly. type ?is_dgm_friendly in your console for more information')
}
index_col_date <- length(df) + 1
df[, index_col_date] <- as.Date(df[,1])

days <- seq(from = df[1,index_col_date],
            to = df[nrow(df), index_col_date],
            by = 1)

if (length(days) < 2) {
  warning('You need at least 2 days of data to run the Degree of Functional Coupling algorithm')
}

dfc <- NULL
spec <- NULL
dfc <- data.frame(from = character(),
                  to = character(),
                  dfc = numeric(),
                  hp = numeric()) #The data frame for DFC

spec <- data.frame(fromtodate = character(),
                   sample = numeric(),
                   freq = numeric(),
                   power = numeric(),
                   pvalue = numeric()) #The data frame for SPEC

n_days_scanned <- length(days) - rolling_window - 1

i = 1

theoretical_cutoff <- highest_possible_harm_cutoff(sampling)

# Check if the needed cutoff harmonic is bigger than the theoretical cutoff
if (harm_cutoff > theoretical_cutoff) {
  warning("The sought harmonic cutoff is bigger than what is possible given
    the sampling period. The cutoff harmonic should correspond to a period that
       is at least 2 times the sampling period. For example, with a sampling
       period of 15 min, the lowest possible period that can be treated is 30
       min, which corresponds to the 48th harmonic period.")
  print(paste0("changing the harmoinc cutoff to ", theoretical_cutoff))
  used_harmonic_cutoff <- theoretical_cutoff
} else {
  used_harmonic_cutoff <- harm_cutoff
}


for (i in 1:n_days_scanned) {# Loop over the days (7 by 7)

  if (verbose) {
    cat("Processing dates ", format(days[i]), " until ", format(days[(i + rolling_window - 1)]), "\n")

  }
  index_start_day <- i
  index_end_day <- i + rolling_window - 1

  samples_per_day = 24*60/sampling #The number of data points per day

  #Filtering the next seven days by date (not by index - in case of missing data, filtering by index would make errors)
  # with dplyr
  # data_week <- df %>% filter(date >= days[i]) %>%  filter(date <= days[i + rolling_window - 1])

  # with baseR
  data_week <- df[df[,1] >= days[index_start_day] & df[,1] <= days[index_end_day], ]

  #Selecting the first column (datetime) and the activity column
  df_var <- data_week %>% select(1, `activity`)

  lsp <- lomb_scargle_periodogram(df_var, alpha = sig, plot = TRUE)

  #Computing the p-values for each frequency
  # From timbre: seems they did not take the case where p>0.01 into account
  # p = [1.0 - pow(1.0 - math.exp(-x), 2.0 * nout / ofac) for x in py]

  #Adjusting the length of the vectors in case of missing data.
  #In case of no missing data, I expect 96 samples (if sampling = 15 min),
  # Therefore, I expect all other vector having 96 cells

  if (length(lsp$lsp_data$power) < samples_per_day) {
    len = length(lsp$lsp_data$power)
    expy <- exp(-lsp$lsp_data$power)
  } else {
    len = samples_per_day
    expy <- exp(-lsp$lsp_data$power[1:len])
  }


  lsp_data <- lsp$lsp_data[1:len,]
  harm_power <- lsp_data$power[lsp_data$status_harmonic == 'Harmonic'] #The harmonic powers


  sumall <- sum(lsp_data$power) #sum of all powers
  ssh <- sum(lsp_data$power[lsp_data$power >= lsp$sig.level
                            & lsp_data$status_harmonic == 'Harmonic'])
  sumsig <- sum(lsp_data$power[which(lsp_data$power >= lsp$sig.level)])  #sum of all significant

  # frequencies (each one has a power)
  # sumall: sum of powers for all frequencies (96) ==> 100: ALL
  # sumsig: 10 significant frequencies ==> 20             : subset of ALL
  # ssh: a subset of 10 ( 5 frequencies) ==> 10           : Subset of a subset of ALL
  # Because sumsig is always smaller than sumall and HP and DFC, then DFC is always
  # Bigger than HP

  HP <- ssh / sumall
  DFC <- ssh / sumsig



  spec <- rbind(spec, data.frame(
    rep(paste0(format(days[i]), "_to_", format(days[i + rolling_window - 1])), len),
    1:len,
    (1:len)/7,
    lsp_data$power,
    lsp_data$p_values))

  dfc[i,] <-  c(format(days[i]), format(days[i+rolling_window - 1]), DFC, HP)

  if (verbose) {
    print(dfc[i,])
  }
}

dfc$from <- as.Date(dfc$from, format("%Y-%m-%d"))
dfc$to <- as.Date(dfc$to, format("%Y-%m-%d"))
dfc$dfc <- as.numeric(dfc$dfc)
dfc$hp <- as.numeric(dfc$hp)


if(plot_harmonic_part){
  dfc_plot <- ggplot(dfc, aes(x = from)) +
    geom_line(aes(y = dfc, linetype = "Degree of functional coupling")) +
    geom_line(aes(y = hp, linetype = "Harmonic part")) +
    ylab("Percentage") +
    xlab("Date") +
    theme(
      axis.text.x = element_text(size=rel(1), color = 'black'),
      axis.text.y = element_text(size=rel(1), color = 'black'),
      panel.background = element_rect(fill = "white"),
      axis.line = element_line(size = 0.5),
      legend.key = element_rect(fill = "white"),
      legend.key.width = unit(0.5, "cm"),
      legend.justification = "left",
      legend.key.size = unit(10, "pt"),
      legend.title = element_blank(),
      legend.position = c(0.7,0.75),
      plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"))

} else{
  dfc_plot <- ggplot(dfc, aes(x = from)) +
    geom_line(aes(y = dfc, linetype = "Degree of functional coupling")) +
    ylab("Percentage") +
    xlab("Date") +
    theme(
      axis.text.x = element_text(size=rel(1), color = 'black'),
      axis.text.y = element_text(size=rel(1), color = 'black'),
      panel.background = element_rect(fill = "white"),
      axis.line = element_line(size = 0.5),
      legend.key = element_rect(fill = "white"),
      legend.key.width = unit(0.5, "cm"),
      legend.justification = "left",
      legend.key.size = unit(10, "pt"),
      legend.title = element_blank(),
      legend.position = c(0.7,0.75),
      plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"))

}

if(plot){
  print(dfc_plot)
}

dfc_plot$spec <- spec




