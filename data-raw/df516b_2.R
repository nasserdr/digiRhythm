#' df516b_2 Activity Data Sets
#'
#' A dataset containing the Motion index and steps count of a cow.
#' The data set is sampled with 15 minutes samples. The data is as follows:
#'
#' \describe{
#'  \item{datetime}{a POSIX formatted datetime}
#'  \item{Motion Index}{The motion index of the cow during the time sample}
#'  \item{Steps}{The number of steps during the time sample}
#' }
#'
#' @docType data
#' @keywords datasets
#' @name df516b_2
#' @usage data(df516b_2)
#' @format A data frame 3 columns
#' @source Agroscope Tanikon
#' @export


library(dplyr)
library(tidyr)
library(readr)
library(xts)
library(usethis)
library(digiRhythm)

df516b_2 <- import_raw_icetag_data('data-raw/516b_2.csv',
                                   skipLines = 7,
                                   act.cols.names = c("Date", "Time", "Motion Index", 'Steps'),
                                   date_format = "%d.%m.%Y",
                                   time_format = "%H:%M:%S",
                                   sampling = 15,
                                   trim_first_day = TRUE,
                                   trim_middle_days = TRUE,
                                   trim_last_day = TRUE,
                                   verbose = FALSE)

df516b_2 %>% usethis::use_data(overwrite = TRUE)
