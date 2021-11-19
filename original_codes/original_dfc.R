library(digiRhythm)
library(lubridate) #data
library(lomb)
library(dplyr)
library(stringr) #str_replace
library(gdata) #write.fwf

#Arguments configuration
data("df516b_2", package = "digiRhythm")
df <- df516b_2
activity = names(df)[2]
sampling = 15
sig <- 0.05
plot <- TRUE
verbose = TRUE

#Start of the function body
#We assume that the first column is a datetime column and the other columns are activity columns
#df should be a dataframe

df <- as.data.frame(df, row.names = NULL)

if (!is_dgm_friendly(df)) {
  stop('The data is not digiRhythm friendly. type ?is_dgm_friendly in your console for more information')
}


df$date <- date(df$datetime)
days <- unique(df$date)

if (length(days) < 7) {
  stop('You need at least 7 days of data to run the Degree of Functional Coupling algorithm')
}

if (length(which(diff(days) != 1)) > 0) {
  warning('There is an interruption in the days sequence, i.e., there are non consecutive
          days in the data')
  print('Interruption is at the following days:')
  cat(which(diff(days) != 1), '\n')
}

df$date <- lubridate::date(df$datetime)
days <- unique(df$date)

dfc <- NULL
spec <- NULL
dfc <- data.frame(date = character(),
                  dfc = numeric(),
                  hp = numeric()) #The data frame for DFC

spec <- data.frame(fromtodate = character(),
                   sample = numeric(),
                   freq = numeric(),
                   power = numeric(),
                   pvalue = numeric()) #The data frame for SPEC

n_days_scanned <- length(days) - 7

for (i in 1:n_days_scanned) {# Loop over the days (7 by 7)

  if (verbose) {
    cat("Processing dates ", as.character(days[i]), " until ", as.character(days[(i + 6)]), "\n")

  }

  samples_per_day = 24*60/sampling #The number of data points per day

  #Filtering the next seven days by date (not by index - in case of missing data, filtering by index would make errors)
  data_week <- df %>% filter(date >= days[i]) %>%  filter(date <= days[i + 6])

  #Selecting the first column (datetime) and the activity column
  df_var <- data_week %>% select(1, `activity`)

  l <- lsp(df_var,
           alpha = sig,
           plot = FALSE) #Computing the lomb-scargle periodigram

  harmonic_indices <- seq(7, 96, by = 7) #The harmonic frequencies

  harm_power <- l$power[harmonic_indices] #The harmonic powers

  #Computing the p-values for each frequency
  # From timbre: seems they did not take the case where p>0.01 into account
  # p = [1.0 - pow(1.0 - math.exp(-x), 2.0 * nout / ofac) for x in py]

  #Adjusting the length of the vectors in case of missing data.
  #In case of no missing data, I expect 96 samples (if sampling = 15 min),
  # Therefore, I expect all other vector having 96 cells

  if (length(l$power) < samples_per_day) {
    len = length(l$power)
    expy <- exp(-l$power)
  } else {
    len = samples_per_day
    expy <- exp(-l$power[1:len])
  }

  #According to Scargle and Lomb (also as described in numerical recipes)
  effm <- 2*samples_per_day
  prob <- NULL
  for (j in 1:length(expy)) {
    prob[j] <- expy[j]*effm
    if (prob[j] > 0.01) {
      prob[j] <- 1 - ( 1 - expy[j])^effm
    }
  }

  sumall <- sum(l$power[1:len]) #sum of all powers
  ssh <- sum(harm_power[which(harm_power > l$sig.level)]) #sum of harmonic significant frequencies
  sumsig <- sum(l$power[which(l$power > l$sig.level)])  #sum of all significant

  HP <- ssh / sumall
  DFC <- ssh / sumsig

  spec <- rbind(spec, data.frame(
    rep(paste0(as.character(days[i]), "_to_", as.character(days[i + 6])), len),
    1:len,
    (1:len)/7,
    l$power[1:len],
    prob))

  dfc[i,] <-  c(as.character(days[i]), DFC, HP)

  if (verbose) {
    print(dfc[i,])
  }
}


dfc$date <- as.Date(dfc$date, format("%Y-%m-%d"))
dfc$dfc <- as.numeric(dfc$dfc)
dfc$hp <- as.numeric(dfc$hp)

dfc_plot <- ggplot(dfc, aes(x = date)) +
  geom_line(aes(y = dfc, linetype = "Degree of functional coupling (%)")) +
  geom_line(aes(y = hp, linetype = "Harmonic power")) +
  xlab("") +
  ylab("") +
  xlim(df$date[1], last(df$date)) +
  theme(
    # axis.text.y = element_blank(),
    panel.background = element_rect(fill = "white"),
    axis.line = element_line(size = 0.5),
    legend.key = element_rect(fill = "white"),
    legend.key.width = unit(0.5, "cm"),
    legend.justification = "left",
    legend.key.size = unit(7, "pt"),
    legend.title = element_blank(),
    legend.position = c(0.7,0.75))

if(plot){
  print(dfc_plot)
}

dfc_plot$spec <- spec
