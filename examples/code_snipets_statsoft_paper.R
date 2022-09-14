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

w <- 10
h <- 7
dp <- 140

all_plots <- list()
i <- 1

for (period in c(24, 6)){
  #Creating a signal with a period = 24 and computing its lsp
  p <- period*3600 #period in seconds (24h * 3600 s)
  freq <- 1/p #freq in hertz
  sig <- sin(2*pi*freq*as.numeric(time))

  df <- data.frame(
    datetime = time,
    activity = sig
  )

  ggplot(data = df, aes(x = datetime, y = activity)) +
    geom_line() +
    xlab('') +
    ylab('') +
    ggtitle('') +
    theme(
      panel.background = element_rect(fill = "white"),
      axis.line = element_line(size = 0.5),
      legend.key = element_rect(fill = "white"),
      legend.key.width = unit(0.5, "cm"),
      legend.justification ="right",
      legend.key.size = unit(7, "pt"),
      legend.position = c(1,0.89),
      plot.margin = margin(t = 50),
      axis.text  = element_blank(),
      axis.ticks  = element_blank())

  name <- paste0('../jstatsoft/figures/sig', period, '.pdf')
  ggsave(
    name,
    plot = signal <- last_plot(),
    device = 'pdf',
    width = w,
    height = h,
    scale = 1,
    dpi = dp,
    limitsize = TRUE)

  lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE)

  name <- paste0('../jstatsoft/figures/lsp', period, '.pdf')
  ggsave(
    name,
    plot = lsp <- last_plot(),
    device = 'pdf',
    width = w,
    height = h,
    scale = 1,
    dpi = dp,
    limitsize = TRUE)

  all_plots[[i]] <- signal
  i <- i + 1
  all_plots[[i]] <- lsp
  i <- i + 1
}


wrap_plots(all_plots, ncol = 2)
#Creating a signal with a period = 12 and computing its lsp



#adding all signals together and computing the LSP

all_signals = sin(2*pi*(1/24/3600)*as.numeric(time)) +
  sin(2*pi*(1/12/3600)*as.numeric(time)) +
  sin(2*pi*(1/6/3600)*as.numeric(time)) +
  sin(2*pi*(1/4/3600)*as.numeric(time))


df <- data.frame(
  datetime = time,
  activity = all_signals
)

ggplot(data = df, aes(x = datetime, y = activity)) +
  geom_line() +
  xlab('Signal') +
  ylab('Date') +
  ggtitle(period)

name <- paste0('../jstatsoft/figures/all_sig.pdf')
ggsave(
  name,
  plot = signal <- last_plot(),
  device = 'pdf',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE)

name <- paste0('../jstatsoft/figures/all_lsp.pdf')
ggsave(
  name,
  plot = lsp <- last_plot(),
  device = 'pdf',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

all_plots[[9]] <- signal
all_plots[[10]] <- lsp

wrap_plots(all_plots, ncol = 2)

#Real data
#Example
data("df516b_2")
df <- df516b_2
df <- df[1:672,c(1,2)]

pdf("../jstatsoft/figures/sig_real.pdf",   # The directory you want to save the file in
    width = w, # The width of the plot in inches
    height = h) # The height of the plot in inches

plot(df$datetime, df$Motion.Index, type = 'l', ylab = 'Motion Index', xlab = 'Date')
dev.off()

lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE)
ggsave(
  '../jstatsoft/figures/lsp_real.pdf',
  plot = p,
  device = 'pdf',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)


