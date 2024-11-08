#' General info
#' This code is to reproduce the results in the digiRhythm paper.
#' The code was test with R 4.3.3
#' For the below imported libraries, if you get an error, please install the library using the command install.packages("library_name")
#' Before you start, click on session ->  set working directory -> to source file location
library(ggplot2)
library(magrittr)
library(lubridate)
library(dplyr)
library(lomb)
library(patchwork)
library(latex2exp)
library(glue)
setwd("~/projects/digiRhythm/examples")
###############################################################################
####################### Installing DigiRhythm ##################################

# Install the devtools package if you haven't already

# To install the development version from GitHub
#install.packages("devtools")
#devtools::install_github("nasserdr/digiRhythm", dependencies = TRUE)

# To install the stable version from CRAN
#install.packages('digiRhythm')
library(digiRhythm)

###############################################################################
################################## FIGURE: 1 ##################################
###############################################################################

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
legend <- 1
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
    ggtitle(paste0('(', legend, ')')) +
    theme(
      axis.text = element_text(color = "#000000"),
      text = element_text(size = 15),
      panel.background = element_rect(fill = "white"),
      axis.line = element_line(linewidth = 0.5),
      legend.key = element_rect(fill = "white"),
      legend.key.width = unit(0.5, "cm"),
      legend.justification ="right",
      legend.key.size = unit(7, "pt"),
      legend.position = c(1,0.89),
      plot.margin = margin(t = 50),
      plot.title = element_text(hjust = 0.95)) +
      scale_x_continuous(n.breaks = 8)

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
  lsp_plot <- lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = FALSE, extra_info_plot = FALSE )

  lsp_df <- lsp_plot$lsp_data
  lsp_df$frequency_hz <- lsp_df$frequency_hz*3600*24

  legend <- legend + 1
  ggplot(data = lsp_df, aes(x = frequency_hz, y = power)) +
    geom_line() +
    xlab('Frequency (cycles/hour)')+
    ylab('Power') +
    ggtitle(paste0('(', legend, ')')) +
    theme(
      panel.background = element_rect(fill = "white"),
      axis.text = element_text(color = "#000000"),
      text = element_text(size = 15),
      axis.line = element_line(linewidth = 0.5),
      legend.key = element_rect(fill = "white"),
      legend.key.width = unit(0.5, "cm"),
      legend.justification ="right",
      legend.key.size = unit(7, "pt"),
      legend.position = c(1,0.89),
      plot.margin = margin(t = 50),
      plot.title = element_text(hjust = 0.95)) +
    scale_x_continuous(n.breaks = 7)


  legend <- legend + 1

  name <- paste0('./figures/lsp', period, '.pdf')
  ggsave(
    name,
    plot = lsp <- last_plot() ,
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
# Creating a signal with a period = 12 and computing its lsp



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

legend <- legend + 1
ggplot(data = df, aes(x = num, y = activity)) +
  geom_line() +
  xlab('Day') +
  ylab('Signal Intensity') +
  ggtitle(paste0('(', legend, ')')) +
  theme(
    axis.text = element_text(color = "#000000"),
    text = element_text(size = 15),
    panel.background = element_rect(fill = "white"),
    axis.line = element_line(linewidth = 0.5),
    legend.key = element_rect(fill = "white"),
    legend.key.width = unit(0.5, "cm"),
    legend.justification ="right",
    legend.key.size = unit(7, "pt"),
    legend.position = c(1,0.89),
    plot.margin = margin(t = 50),
    plot.title = element_text(hjust = 0.95)) +
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
lsp_plot <- lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = FALSE, extra_info_plot = FALSE)

lsp_df <- lsp_plot$lsp_data
lsp_df$frequency_hz <- lsp_df$frequency_hz*3600*24

legend <- legend + 1
ggplot(data = lsp_df, aes(x = frequency_hz, y = power)) +
  geom_line() +
  xlab('Frequency (cycles/hour)')+
  ylab('Power') +
  ggtitle(paste0('(', legend, ')')) +
  theme(
    panel.background = element_rect(fill = "white"),
    axis.text = element_text(color = "#000000"),
    text = element_text(size = 15),
    axis.line = element_line(linewidth = 0.5),
    legend.key = element_rect(fill = "white"),
    legend.key.width = unit(0.5, "cm"),
    legend.justification ="right",
    legend.key.size = unit(7, "pt"),
    legend.position = c(1,0.89),
    plot.margin = margin(t = 50),
    plot.title = element_text(hjust = 0.95)) +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 7))


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


name <- paste0('figures/Figure 2.png')

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
################################## FIGURE: 3 ##################################
###############################################################################

#Real data
library(digiRhythm)
data("df516b_2", package = 'digiRhythm')
df <- df516b_2
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
    axis.line = element_line(linewidth = 0.5),
    legend.key = element_rect(fill = "white"),
    legend.key.width = unit(1, "cm"),
    legend.justification ="right",
    legend.key.size = unit(7, "pt"),
    legend.position = c(1,0.89),
    plot.margin = margin(t = 50))

name <- paste0('figures/Figure 3.png')

ggsave(
  name,
  plot = signal <- last_plot(),
  device = 'png',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

###############################################################################
################################## FIGURE: 4 ##################################
###############################################################################

my_lsp <- lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE, extra_info_plot = TRUE)

name <- paste0('figures/Figure 4.png')
ggsave(
  name,
  plot = lsp <- last_plot(),
  device = 'png',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

###############################################################################
################################## FIGURE: 5 ##################################
###############################################################################
df <- df516b_2 # considering the whole dataset
df <- resample_dgm(df, 15)
activity = names(df)[2] # considering the first activity variable (second column usually)
start = "2020-05-01"
end = "2020-06-15"
my_actogram <- actogram(df, activity, activity_alias = 'Motion Index' , start, end, save = NULL)

name <- paste0('figures/Figure 5.png')
ggsave(
  name,
  plot = lsp <- last_plot(),
  device = 'png',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)


###############################################################################
################################## FIGURE: 6 ##################################
###############################################################################
my_daa <- daily_average_activity(df,
                                 activity,
                                 activity_alias = 'Motion Index' ,
                                 start,
                                 end,
                                 save = NULL)
name <- paste0('figures/Figure 6.png')
ggsave(
  name,
  plot = lsp <- last_plot(),
  device = 'png',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

###############################################################################
################################## FIGURE: 7 ##################################
###############################################################################
day_time = c("06:30:00", "16:30:00")
night_time = c("18:00:00", "T05:00:00")
my_di <- diurnality(df, activity, day_time, night_time, save = NULL)
name <- paste0('figures/Figure 7.png')
ggsave(
  name,
  plot = lsp <- last_plot(),
  device = 'png',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

###############################################################################
################################## FIGURE: 8 ##################################
###############################################################################
data("timedata", package = 'digiRhythm') # Loading another dataset where there is a daylight shift
td <- as.data.frame(timedata)
my_sliding_di <- sliding_DI(df,
                            activity,
                            td)

print(str(td))
print(head(td))
name <- paste0('./figures/Figure 8.png')
ggsave(
  name,
  plot = lsp <- last_plot(),
  device = 'png',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

###############################################################################
################################## FIGURE: 9 ##################################
###############################################################################

#Verifying the datasets
data("df516b_2", package = 'digiRhythm')
df <- df516b_2
df <- resample_dgm(df, 15)
activity = names(df)[2]

my_dfc <- dfc(df, activity = activity,  alpha = 0.05, plot = FALSE, verbose = FALSE)
name <- paste0('figures/Figure 9.png')
ggsave(
  name,
  plot = last_plot(),
  device = 'png',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

###############################################################################
################################## FIGURE: 10 ##################################
###############################################################################

my_dfc +
  theme(
    text=element_text(family="Times", size=20),
    axis.text.y=element_text(size=15, colour="red"))

name <- paste0('figures/Figure 10.png')
ggsave(
  name,
  plot = last_plot(),
  device = 'png',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

