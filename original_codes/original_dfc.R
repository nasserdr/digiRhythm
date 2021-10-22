library(digiRhythm)
library(lubridate) #data
library(lomb)
library(dplyr)
library(stringr) #str_replace
library(gdata) #write.fwf

data("df516b_2", package = "digiRhythm")
df <- df516b_2
df <- remove_activity_outliers(df)
activity = names(df)[2]
sampling = 15
sig <- 0.05
save = TRUE
tag = 'test'
outputdir = 'sample_results'
show_lsp_plot <- TRUE


if(!is_dgm_friendly(df)){
  stop('The data is not digiRhythm friendly. type ?is_dgm_friendly in your console for more information')
}


df$date <- date(df$datetime)
days <- unique(df$date)

if(length(days) < 7){
  stop('You need at least 7 days of data to run the Degree of Functional Coupling algorithm')
}



if(length(which(diff(days) != 1)) > 0){
  warning('There is an interruption in the days sequence, i.e., there are non consecutive
          days in the data')
  print('Interruption is at the following days:')
  cat(which(diff(days) != 1), '\n')
}

df$date <- lubridate::date(df$datetime)
days <- unique(df$date)


dfc <- data.frame(date = character(),
                  dfc = numeric(),
                  hp = numeric()) #The data frame for DFC

spec <- data.frame(fromtodate = character(),
                   sample = numeric(),
                   freq = numeric(),
                   power = numeric(),
                   pvalue = numeric()) #The data frame for SPEC

n_days_scanned <- length(days)-7

i <- 1
for (i in 1:n_days_scanned){# Loop over the days (7 by 7)
  cat("Processing dates ", as.character(days[i]), " until ", as.character(days[(i+6)]), "\n")
  samples_per_day = 24*60/sampling


  #Filterning by index. CHANGED beacuase it's dangerous in case of missing data
  # ds <- (i - 1) * samples_per_day + 1 #Index of the first data point in the series of 7 days
  # de <- (7 + i - 1) * samples_per_day #Index of the last data point in the series of 7 days
  # data_chunck <- data[ds:de, ] #The 7 days data set

  #Filtering by date
  data_week <- df %>% filter(date >= days[i]) %>%  filter(date <= days[i+6])

  cat("Dates filtered are: ", as.character(unique(data_week$date)), "\n")

  #Test with TS (to check the response with NA data)
  # data_week <- rbind(data_week[1:20,], data_week[30:nrow(data_week),])
  # df_xts <- xts::xts(
  #   x = data_week[activity],
  # order.by = data_week[,1]
  # )
  # ts <- as.ts(df_xts)
  # l_ts <- lsp(ts,
  #          alpha = 0.05,
  #          normalize = 'standard',
  #          plot = show_lsp_plot) #Computing the lomb-scargle periodogram
  #


  l <- lsp(data_week[c('datetime', activity)],
           alpha = sig,
           normalize = 'standard',
           plot = show_lsp_plot) #Computing the lomb-scargle periodigram

  harmonic_indices <- seq(7, samples_per_day, by = 7) #The harmonic frequencies

  harm_power <- l$power[harmonic_indices] #The harmonic powers

  #Computing the p-values for each frequency
  # From timbre: seems they did not take the case where p>0.01 into account
  # p = [1.0 - pow(1.0 - math.exp(-x), 2.0 * nout / ofac) for x in py]

  #Adjusting the length of the vectors in case of missing data.
  #In case of no missing data, I expect 96 samples (if sampling = 15 min),
  # Therefore, I expect all other vector having 96 cells

  if(length(l$power) < samples_per_day){
    len = length(l$power)
    expy <- exp(-l$power)
  } else{
    len = samples_per_day
    expy <- exp(-l$power[1:len])
  }

  #According to Scargle and Lomb (also as described in numerical recipes)
  effm <- 2*samples_per_day
  prob <- NULL
  for (j in 1:length(expy)){
    prob[j] <- expy[j]*effm
    if(prob[j] > 0.01){
      prob[j] <- 1-(1-expy[j])^effm
    }
  }

  prob_harmonic <- prob[harmonic_indices] # Storing the p-values of the harmonic frequencies

  sumallR <- sum(l$power[1:len]) #sum of all powers
  ssh <- sum(harm_power[which(harm_power > l$sig.level)]) #sum of harmonic significant frequencies
  sumsig <- sum(l$power[which(l$power > l$sig.level)])  #sum of all significant

  HP <- ssh / sumallR
  DFC<- ssh / sumsig

  spec <- rbind(spec, data.frame(
    rep(paste0(as.character(days[i]), "_to_", as.character(days[i+6])), len),
    1:len,
    (1:len)/7,
    l$power[1:len],
    prob))

  dfc[i,] <-  c(as.character(days[i]), DFC, HP)
}


if(save){
  if (!file.exists(outputdir)){
    dir.create(outputdir)
  }


  dfc_file_name <- file.path(outputdir, paste0("dfc_", tag, "_", activity,".txt"))
  spec_file_name <- file.path(outputdir, paste0("spec_", tag, "_", activity,".txt"))
  data_file_name <- file.path(outputdir, paste0("data_", tag, "_", activity,".txt"))

  gdata::write.fwf(df,
                   data_file_name,
                   sep = "\t",
                   colnames = TRUE,
                   rownames = FALSE,
                   quote = FALSE)
  cat("DFC data will be saved in ", dfc_file_name, "\n")
  cat("Spectrum data will be saved in ", spec_file_name, "\n")
  names(dfc) <- c("start_date", "DFC", "HP")
  gdata::write.fwf(dfc, dfc_file_name, sep = "\t", colnames = TRUE, rownames = FALSE, quote = FALSE)

  #Dumping the Spectrum Data in the spectrum file
  names(spec) <- c("fromtodate", "sample", "frequency", "power", "pvalue")
  gdata::write.fwf(spec, spec_file_name, sep = "\t", colnames = TRUE, rownames = FALSE, quote = FALSE)
}

result <- NULL
result$dfc <- dfc
result$spec <- spec
result$lomb <- l
return(result)
