% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/import_raw_activity_data.R
\name{import_raw_activity_data}
\alias{import_raw_activity_data}
\title{Reads Raw Activity Data from csv files}
\usage{
import_raw_activity_data(
  filename,
  skipLines = 0,
  act.cols.names = c("Date", "Time", "Motion Index", "Steps"),
  date_format = "\%d.\%m.\%Y",
  time_format = "\%H:\%M:\%S",
  sep = ",",
  original_tz = "CET",
  target_tz = "CET",
  sampling = 15,
  trim_first_day = TRUE,
  trim_middle_days = TRUE,
  trim_last_day = TRUE,
  verbose = FALSE
)
}
\arguments{
\item{filename}{The file name (full or relative path with extension)}

\item{skipLines}{The number of non-useful lines to skip (lines to header)}

\item{act.cols.names}{A vector containing the names of columns to read
(specific to the activity columns)}

\item{date_format}{The POSIX format of the Date column (or first column)}

\item{time_format}{The POSIX format of the Time column (or second column)}

\item{sep}{The delimiter/separator between the columns}

\item{original_tz}{The time zone with which the datetime are encoded}

\item{target_tz}{The time zone with which you want to process the data.
Setting this argument to 'GMT' will help you coping with daylight saving time
where changes occur two time a year.}

\item{sampling}{The sampling frequency in minutes (default 15 min)}

\item{trim_first_day}{if True, removes the data from the first day if it
contains less than 80\% of the expected data points.}

\item{trim_middle_days}{if True, removes the data from the MIDDLE days if
they contain less than 80\% of the expected data points.}

\item{trim_last_day}{if True, removes the data from the last day if it
contains less than 80\% of the expected data points.}

\item{verbose}{print out some useful information during the execution
of the function}
}
\value{
A dataframe with datetime column and other activity columns, ready to
be used with other functions in digirhythm
}
\description{
Reads Activity Data (data, time, activity(ies)) from a CSV file where we can
skip some lines (usually representing the metadata) and select specific
activities.
}
\details{
This function prepare the data stored in a csv to be compatible with the
digiRhythm package. You have the possibility to skip the first lines and
choose which columns to read. You also have the possibility to sample the
data.
You can also choose whether to remove partial days (where no data over a
full day is present) by trimming last, middle or last days.
This function expects that the first and second columns are respectively
date and time where the format should be mentioned.

file <- file.path('data', 'sample_data')
colstoread <- c("Date", "Time", "Motion Index", 'Steps') #The colums that we
are interested in
data <- improt_raw_icetag_data(filename = file,
skipLines = 7,
act.cols.names = colstoread,
sampling = 15,
verbose = TRUE)
}
\examples{

filename <- system.file("extdata", "sample_data.csv", package = "digiRhythm")
data <- import_raw_activity_data(
  filename,
  skipLines = 7,
  act.cols.names = c("Date", "Time", "Motion Index", "Steps"),
  sep = ",",
  original_tz = "CET",
  target_tz = "CET",
  date_format = "\%d.\%m.\%Y",
  time_format = "\%H:\%M:\%S",
  sampling = 15,
  trim_first_day = TRUE,
  trim_middle_days = TRUE,
  trim_last_day = TRUE,
  verbose = TRUE
)
print(head(data))

}
