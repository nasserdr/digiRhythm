library(ggplot2)
library(magrittr)
library(lubridate)
library(dplyr)
library(digiRhythm)
library(lomb)
library(patchwork)


###############################################################################
####################### Installing DigiRhythm ##################################

# Install the devtools package if you haven't already
#install.packages("devtools")
devtools::install_github("nasserdr/digiRhythm", dependencies = TRUE)

###############################################################################
####################### FIGURE: 2 ###################################
# LSP on purely synthetic data ----------------------------
#Creating time grid
sampling = 15*60 #15 minutes
time = seq(
  c(ISOdate(2022,3,1, 0,0,0)),
  c(ISOdate(2022,3,7, 23, 59, 0)),
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


  df$num <- as.numeric(df$datetime)
  df$num <- df$num - min(df$num)
  df$num <- df$num/24/3600

    ggplot(data = df, aes(x = num , y = activity)) +
    geom_line() +
    xlab('Day') +
    ylab('Signal Intensity') +
    ggtitle('') +
    theme(
      axis.text = element_text(color = "#000000"),
      text = element_text(size = 15),
      panel.background = element_rect(fill = "white"),
      axis.line = element_line(size = 0.5),
      legend.key = element_rect(fill = "white"),
      legend.key.width = unit(0.5, "cm"),
      legend.justification ="right",
      legend.key.size = unit(7, "pt"),
      legend.position = c(1,0.89),
      plot.margin = margin(t = 50)) +
      scale_x_continuous(n.breaks = 8)

      # axis.text  = element_blank(),
      # axis.ticks  = element_blank())

  name <- paste0('figures/sig', period, '.pdf')
  ggsave(
    name,
    plot = signal <- last_plot(),
    device = 'pdf',
    width = w,
    height = h,
    scale = 1,
    dpi = dp,
    limitsize = TRUE)

  df$num <- NULL
  lsp_plot <- lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE, extra_info_plot = FALSE )

  lsp_df <- lsp_plot$lsp_data
  ggplot(data = lsp_df, aes(x = frequency_hz, y = power)) +
    geom_line() +
    xlab('Frequency') +
    ylab('Power') +
    ggtitle('') +
    theme(
      panel.background = element_rect(fill = "white"),
      axis.text = element_text(color = "#000000"),
      text = element_text(size = 15),
      axis.line = element_line(size = 0.5),
      legend.key = element_rect(fill = "white"),
      legend.key.width = unit(0.5, "cm"),
      legend.justification ="right",
      legend.key.size = unit(7, "pt"),
      legend.position = c(1,0.89),
      plot.margin = margin(t = 50)) +
    scale_x_continuous(n.breaks = 8)



  name <- paste0('figures/lsp', period, '.pdf')
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
  # sin(2*pi*(1/12/3600)*as.numeric(time)) +
  sin(2*pi*(1/6/3600)*as.numeric(time))
  # sin(2*pi*(1/4/3600)*as.numeric(time))


df <- data.frame(
  datetime = time,
  activity = all_signals
)

df$num <- as.numeric(df$datetime)
df$num <- df$num - min(df$num)
df$num <- df$num/24/3600

ggplot(data = df, aes(x = num, y = activity)) +
  geom_line() +
  xlab('Day') +
  ylab('Signal Intensity') +
  ggtitle('') +
  theme(
    axis.text = element_text(color = "#000000"),
    text = element_text(size = 15),
    panel.background = element_rect(fill = "white"),
    axis.line = element_line(size = 0.5),
    legend.key = element_rect(fill = "white"),
    legend.key.width = unit(0.5, "cm"),
    legend.justification ="right",
    legend.key.size = unit(7, "pt"),
    legend.position = c(1,0.89),
    plot.margin = margin(t = 50)) +
  scale_x_continuous(n.breaks = 8)

name <- paste0('figures/all_sig.pdf')
ggsave(
  name,
  plot = signal <- last_plot(),
  device = 'pdf',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)
df$num <- NULL
lsp_plot <- lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE, extra_info_plot = FALSE)

lsp_df <- lsp_plot$lsp_data
ggplot(data = lsp_df, aes(x = frequency_hz, y = power)) +
  geom_line() +
  xlab('Frequency') +
  ylab('Power') +
  ggtitle('') +
  theme(
    panel.background = element_rect(fill = "white"),
    axis.text = element_text(color = "#000000"),
    text = element_text(size = 15),
    axis.line = element_line(size = 0.5),
    legend.key = element_rect(fill = "white"),
    legend.key.width = unit(0.5, "cm"),
    legend.justification ="right",
    legend.key.size = unit(7, "pt"),
    legend.position = c(1,0.89),
    plot.margin = margin(t = 50)) +
  scale_x_continuous(n.breaks = 8)

name <- paste0('figures/all_lsp.pdf')
ggsave(
  name,
  plot = lsp <- last_plot(),
  device = 'pdf',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

all_plots[[5]] <- signal
all_plots[[6]] <- lsp

wrap_plots(all_plots, ncol = 2)

name <- paste0('figures/Figure 1.png')

ggsave(
  name,
  plot = last_plot(),
  device = 'png',
  width = 10,
  height = 6,
  scale = 1.5,
  dpi = 500,
  limitsize = TRUE)

###############################################################################
####################### FIGURE: alternative for real_lsp#######################

#Real data

data("df691b_1", package = 'digiRhythm')
df <- df691b_1
df <- df[1:672,c(1,2)]

ggplot(data = df, aes(x = datetime, y = Motion.Index)) +
  geom_line() +
  xlab('Date') +
  ylab('Motion Index') +
  ggtitle('') +
  theme(
    axis.text = element_text(color = "#000000"),
    text = element_text(size = 15),
    panel.background = element_rect(fill = "white"),
    axis.line = element_line(size = 0.5),
    legend.key = element_rect(fill = "white"),
    legend.key.width = unit(1, "cm"),
    legend.justification ="right",
    legend.key.size = unit(7, "pt"),
    legend.position = c(1,0.89),
    plot.margin = margin(t = 50))

name <- paste0('figures/real_sig.pdf')

ggsave(
  name,
  plot = signal <- last_plot(),
  device = 'pdf',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE, extra_info_plot = FALSE)

name <- paste0('figures/real_lsp.pdf')
ggsave(
  name,
  plot = lsp <- last_plot(),
  device = 'pdf',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

signal | lsp
name <- paste0('figures/real_lsp_signal.pdf')
ggsave(
  name,
  plot = last_plot(),
  device = 'pdf',
  width = 10,
  height = 3,
  scale = 1.5,
  dpi = 500,
  limitsize = TRUE)

#Verifying the datasets
data("df516b_2", package = 'digiRhythm')
df <- df516b_2
df <- resample_dgm(df, 15)
activity = names(df)[3]

my_dfc <- dfc(df, activity = activity,  sig = 0.05, plot = TRUE, verbose = FALSE)

my_dfc +
  theme(
    text=element_text(family="Times", size=8),
    axis.text.y=element_text(size=15, colour="red"))


data <- df[1:672,c(1,2)]

ggplot(data = data, aes(x = datetime, y = Motion.Index)) +
  geom_line() +
  xlab('Date') +
  ylab('Motion Index') +
  ggtitle('') +
  theme(
    panel.background = element_rect(fill = "white"),
    axis.line = element_line(size = 0.5),
    legend.key = element_rect(fill = "white"),
    legend.key.width = unit(1, "cm"),
    legend.justification ="right",
    legend.key.size = unit(7, "pt"),
    legend.position = c(1,0.89),
    plot.margin = margin(t = 50))

