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
sampling = 15
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
# plot_harmonic_part = TRUE

df <- as.data.frame(df, row.names = NULL)

if (!is_dgm_friendly(df)) {
  stop('The data is not digiRhythm friendly. type ?is_dgm_friendly in your console for more information')
}


df$date <- as.Date(df$datetime)
days <- seq(from = df$date[1],
            to = last(df$date),
            by = 1)
tz(df$date) <- target_tz
tz(days) <- target_tz
print(days)

if (length(days) < 7) {
  stop('You need at least 7 days of data to run the Degree of Functional Coupling algorithm')
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

n_days_scanned <- length(days) - 6

i = 1

for (i in 1:n_days_scanned) {# Loop over the days (7 by 7)

  if (verbose) {
    cat("Processing dates ", format(days[i]), " until ", format(days[(i + 6)]), "\n")

  }

  samples_per_day = 24*60/sampling #The number of data points per day

  #Filtering the next seven days by date (not by index - in case of missing data, filtering by index would make errors)
  data_week <- df %>% filter(date >= days[i]) %>%  filter(date <= days[i + 6])


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
    rep(paste0(format(days[i]), "_to_", format(days[i + 6])), len),
    1:len,
    (1:len)/7,
    lsp_data$power,
    lsp_data$p_values))

  dfc[i+6,] <-  c(format(days[i]), format(days[i+6]), DFC, HP)

  if (verbose) {
    print(dfc[i+6,])
  }
}

dfc$from <- as.Date(dfc$from, format("%Y-%m-%d"))
dfc$to <- as.Date(dfc$to, format("%Y-%m-%d"))
dfc$dfc <- as.numeric(dfc$dfc)
dfc$hp <- as.numeric(dfc$hp)


if(plot_harmonic_part){
  dfc_plot <- ggplot(dfc, aes(x = to)) +
    geom_line(aes(y = dfc, linetype = "Degree of functional coupling (%)")) +
    geom_line(aes(y = hp, linetype = "Harmonic part")) +
    xlab("") +
    ylab("") +
    # xlim(df$date[1], last(df$date)) +
    theme(
      axis.text.x = element_text(size=rel(1.5), color = 'black'),
      axis.text.y = element_text(size=rel(1.5), color = 'black'),
      panel.background = element_rect(fill = "white"),
      axis.line = element_line(size = 0.5),
      legend.key = element_rect(fill = "white"),
      legend.key.width = unit(0.5, "cm"),
      legend.justification = "left",
      legend.key.size = unit(7, "pt"),
      legend.title = element_blank(),
      legend.position = c(0.7,0.75),
      plot.margin = margin(0, 0.5, 0, 0, "cm"))

} else{
  dfc_plot <- ggplot(dfc, aes(x = to)) +
    geom_line(aes(y = dfc, linetype = "Degree of functional coupling (%)")) +
    xlab("") +
    ylab("") +
    # xlim(df$date[1], last(df$date)) +
    theme(
      axis.text.x = element_text(size=rel(1.5), color = 'black'),
      axis.text.y = element_text(size=rel(1.5), color = 'black'),
      axis.line = element_line(size = 0.5),
      legend.key = element_rect(fill = "white"),
      legend.key.width = unit(0.5, "cm"),
      legend.justification = "left",
      legend.key.size = unit(7, "pt"),
      legend.title = element_blank(),
      legend.position = c(0.7,0.75),
      plot.margin = margin(0, 0.5, 0, 0, "cm"))

}

if(plot){
  print(dfc_plot)
}

dfc_plot$spec <- spec




