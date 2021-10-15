#' df689b_3 Activity Data Sets
#'
#' A dataset containing the Motion index and steps count of a cow.
#' The data set is sampled with 15 minutes samples.
#'
#' @format A data frame of 3 columns
#' \describe{
#'  \item{datetime}{a POSIX formatted datetime}
#'  \item{Motion Index}{The motion index of the cow during the time sample}
#'  \item{Steps}{The number of steps during the time sample}
#' }
#' @source Agroscope Tanikon
#' @docType data
#' @keywords datasets activity
#' @name df689b_3
#' @usage data(df689b_3)

library(dplyr)
library(tidyr)
library(readr)
library(xts)
library(usethis)

df689b_3 <- improt_raw_icetag_data('data-raw/689b_3.csv',
                                skipLines = 7,
                                act.cols.names = c("Date", "Time", "Motion Index", 'Steps'),
                                date_format = "%d.%m.%Y",
                                time_format = "%H:%M:%S",
                                sampling = 15,
                                trim_first_day = TRUE,
                                trim_middle_days = TRUE,
                                trim_last_day = TRUE,
                                verbose = TRUE)
df689b_3 %>% usethis::use_data(overwrite = TRUE)
