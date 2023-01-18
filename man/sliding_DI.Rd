\name{sliding_DI}
\alias{sliding_DI}
\title{Computes the diurnality index based on an activity dataframe, using different times 
to define day and night on a daily base}
\usage{
    sliding_DI(
        data,
        activity,
        timedata,
        save = NULL
    )
}
\arguments{
\item{data}{a digiRhythm-friendly dataset}

\item{activity}{The number of non-useful lines to skip (lines to header)}

\item{timedata}{a dataset containing 4 columns of str POSIXct, including date and the 
time ("day_start", "day_end", "night_start", "night_end")}

\item{save}{if NULL, the image is not saved. Otherwise, this parameter will
be the name of the saved image. it should contain the path and name without
the extension.}
}
\value{
    A dataframe with 2 col: date and diurnality index
}
\description{
    Computes the diurnality index based on an activity dataframe, using different times 
    to define day and night on a daily base
}
\examples{
data("df516b_2", package = "digiRhythm")
data <- df516b_2
data <- remove_activity_outliers(data)
activity = names(data)[2]
timedata("timedata", package = "digiRhythm")
d_index <- diurnality(data, activity, timedata)
}