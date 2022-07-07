library(ggplot2)
library(magrittr)
library(lubridate)
library(dplyr)
library(lomb)
#Example
data("df516b_2")
df <- df516b_2

head(df)
str(df)

# Fourier transform for signals added together ----------------------------

par(mfrow=c(3,2), mar = c(2, 2, 2, 2))
plot(t_grid, signal0.5, type = 'l', xlab = "", ylab = "", main = "1/2 Hz")
t_grid = seq(0, 9.99, sampling)
ft <- Mod(fft(signal0.5))
f_grid <- seq(0, 1/(2*sampling), length.out = N/2+1)
plot(f_grid, ft[1:(N/2+1)], type = 'l')

plot(t_grid, signal4, type = 'l', xlab = "", ylab = "", main = "4 Hz")
ft <- Mod(fft(signal4))
f_grid <- seq(0, 1/(2*sampling), length.out = N/2+1)
plot(f_grid, ft[1:(N/2+1)], type = 'l')


combi1 = signal0.5 + signal4
plot(t_grid, combi1, type = 'l', xlab = "", ylab = "", main = "0.5 Hz + 4 Hz")
ft <- Mod(fft(combi1))
f_grid <- seq(0, 1/(2*sampling), length.out = N/2+1)
plot(f_grid, ft[1:(N/2+1)], type = 'l')
