#Install digiRhythm for the first time
#install.packages("devtools")
devtools::install_github("nasserdr/digiRhythm", dependencies = TRUE)

#'Loading digiRhythm____________________________________________________________
library(digiRhythm)


#'Reading a sample file_________________________________________________________
url <- 'https://github.com/nasserdr/digiRhythm_sample_datasets/raw/main/516b_2.csv'
download.file(url, destfile = '516b_2.csv')
filename <- file.path(getwd(), '516b_2.csv')

#The columns that we are interested in
colstoread <- c("Date", "Time", "Motion Index", 'Steps')

#Reading the activity data from the csv file
data <- import_raw_activity_data(filename = filename, skipLines = 6, act.cols.names = colstoread, sampling = 15)

print(head(data))

#'Checking if the data are DGM Friendly_________________________________________
is_dgm_friendly(data, verbose = TRUE)

#'Removing Outliers_____________________________________________________________
df.no.outliers <- remove_activity_outliers(data)
max(data$Motion.Index)
max(df.no.outliers$Motion.Index)

#'Getting a snapshot info about the data________________________________________
df_act_info(data)

#'Visualizing and saving actogram_______________________________________________
actogram(data,
         activity = 'Motion.Index',
         activity_alias = 'Motion Index',
         start = '2020-04-30',
         end = '2020-06-14',
         save = NULL)

actogram(data,
         activity = 'Motion.Index',
         activity_alias = 'Motion Index',
         start = '2020-04-30',
         end = '2020-06-14',
         save = 'sample_results/myactogram123')

#'Visualizing and saving average activity_______________________________________
daily_average_activity(data,
         activity = 'Motion.Index',
         activity_alias = 'Motion Index',
         start = '2020-04-30',
         end = '2020-06-14',
         save = 'sample_results/activity')

#DGM is done in a way we can have control on output plots via the ggplot functionality
#All plotting functions return a GGPLOT object. This object contains the default
#plot and the data. This object can also be modified.
library(ggplot2)

var <- daily_average_activity(data,
                       activity = 'Motion.Index',
                       activity_alias = 'Motion Index',
                       start = '2020-04-30',
                       end = '2020-06-14',
                       save = NULL)
print(var)

var + theme_dark()

#Day to day activity___________________________________________________________
# Bug
daily_activity_wrap_plot(data,
                         activity,
                         activity_alias,
                         start,
                         end,
                         sampling_rate,
                         ncols)

#'Periodicity___________________________________________________________________
dgm_periodicity(data)
new_data <- resample_dgm(data, 30)
dgm_periodicity(new_data)

#'Computing the Diurnality______________________________________________________
diur <- diurnality(data, activity = 'Steps', plot = TRUE)

#'Computing the DFC_____________________________________________________________
#'Output to be modified to a ggplot object instead of a list for maximum control
data("df516b_2", package = "digiRhythm")
df <- df516b_2
df_act_info(df)
activity = names(df)[2]

a <- digiRhythm::dfc(
  data = df,
  activity = names(df)[2],
  sampling = 15,
  sig = 0.05,
  save = TRUE,
  tag = 'test',
  outputdir = 'sample_results',
  plot = TRUE,
  verbose = TRUE)
