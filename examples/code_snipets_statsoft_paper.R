library(ggplot2)
library(magrittr)
library(lubridate)
library(dplyr)
library(digiRhythm)
library(lomb)
library(patchwork)

# LSP on purely synthetic data ----------------------------
#Creating time grid
sampling = 15*60 #15 minutes
time = seq(
  c(ISOdate(2022,3,20, 0,0,0)),
  c(ISOdate(2022,3,26, 23, 59, 0)),
  by = 15*60) #a timedate sequence over 1 week

#Creating a signal with a period = 24 and computing its lsp
period <- 24*3600 #period in seconds (24h * 3600 s)
freq <- 1/period #freq in hertz
sign24h <- sin(2*pi*freq*as.numeric(time))

df <- data.frame(
  datetime = time,
  activity = sign24h
)

plot(df$datetime, df$activity, type = 'l', xlab = 'Signal', ylab = 'Date', main = 'Sine wave with a period of 24h')
lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE)

#Creating a signal with a period = 12 and computing its lsp

period <- 12*3600 #period in seconds (12h * 3600 s)
freq <- 1/period #freq in hertz
sign12h <- sin(2*pi*freq*as.numeric(time))

df <- data.frame(
  datetime = time,
  activity = sign12h
)

lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE)
plot(df$datetime, df$activity, type = 'l', xlab = 'Signal', ylab = 'Date', main = 'Sine wave with a period of 12h')

#Creating a signal with a period = 6 and computing its lsp

period <- 6*3600 #period in seconds (6h * 3600 s)
freq <- 1/period #freq in hertz
sign06h <- sin(2*pi*freq*as.numeric(time))

df <- data.frame(
  datetime = time,
  activity = sign06h
)
lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE)
plot(df$datetime, df$activity, type = 'l', xlab = 'Signal', ylab = 'Date', main = 'Sine wave with a period of 06h')

#Creating a signal with a period = 4 and computing its lsp
period <- 4*3600 #period in seconds (4h * 3600 s)
freq <- 1/period #freq in hertz
sign04h <- sin(2*pi*freq*as.numeric(time))
df <- data.frame(
  datetime = time,
  activity = sign04h
)

lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE)
plot(df$datetime, df$activity, type = 'l', xlab = 'Signal', ylab = 'Date', main = 'Sine wave with a period of 04h')

#adding all signals together and computing the LSP

all_signals = sign24h + sign12h + sign06h + sign04h
  df <- data.frame(
    datetime = time,
    activity = all_signals
  )

lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE)
plot(df$datetime, df$activity, type = 'l', xlab = 'Signal', ylab = 'Date', main = 'sine(24h) + sine(12h) + sine(06h) + sine(04h)')

#Example
data("df516b_2")
df <- df516b_2
df <- df[1:672,c(1,2)]

plot(df$datetime, df$Motion.Index, type = 'l', ylab = 'Motion Index', xlab = 'Date')

lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE)


