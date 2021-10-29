#imports
library(xts) #xts #period.apply #endpoints
library(lubridate) #date
library(ggplot2)

activity <- 'Motion.Index'

#Configs
data("df516b_2", package = "digiRhythm")
data <- df516b_2


data <- remove_activity_outliers(data)
df_act_info(data)
activity = names(data)[2]
