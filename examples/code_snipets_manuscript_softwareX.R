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
install.packages('digiRhythm')
library(digiRhythm)

###############################################################################
################################## FIGURE: 1 ##################################
###############################################################################

#' In this example, we generate three time series with different periods and
#' composition and we show their Lomb-Scargle Periodogram. The first signal has
#' a period of 24 hours, the second signal has a period of 12 hours and the
#' third signal is the addition of the first two signals.

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
legend <- c('a', 'b', 'c', 'd', 'e', 'f')
all_plots <- list()
i <- 1
position_legend <- 1
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
    ggtitle(paste0('(', legend [position_legend], ')')) +
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

  position_legend <- position_legend + 1
  ggplot(data = lsp_df, aes(x = frequency_hz, y = power)) +
    geom_line() +
    xlab('Frequency (cycles/day)')+
    ylab('Power') +
    xlim(0, 10) +
    ggtitle(paste0('(', legend [position_legend], ')')) +
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
      plot.title = element_text(hjust = 0.95))

  position_legend <- position_legend + 1

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

position_legend <- 5
ggplot(data = df, aes(x = num, y = activity)) +
  geom_line() +
  xlab('Day') +
  ylab('Signal Intensity') +
  ggtitle(paste0('(', legend [position_legend], ')')) +
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

position_legend <- 6
ggplot(data = lsp_df, aes(x = frequency_hz, y = power)) +
  geom_line() +
  xlab('Frequency (cycles/day)')+
  ylab('Power') +
  xlim(0, 10) +
  ylim(0,1)+
  ggtitle(paste0('(', legend [position_legend], ')')) +
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
    plot.title = element_text(hjust = 0.95))

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
################################## FIGURE: 2 ##################################
###############################################################################

#' In this code snippet, we show a real activity dataset and its Lomb-Scargle
#' Periodogram. The dataset is a 7-day long dataset with a 15-minute sampling
#' rate. The dataset is a subset of the data from the digiRhythm package.

library(digiRhythm)
data("df516b_2", package = 'digiRhythm')
df <- df516b_2

df <- df[1:672,c(1,2)]

ggplot(data = df, aes(x = datetime, y = Motion.Index)) +
  geom_line() +
  xlab('Date') +
  ylab('Activity') +
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

name <- paste0('figures/Figure2a.png')
ggsave(
  name,
  plot = lsp <- last_plot(),
  device = 'png',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)


my_lsp <- lomb_scargle_periodogram(df, alpha = 0.01, sampling = 15, plot = TRUE, extra_info_plot = TRUE)
name <- paste0('figures/Figure2b.png')
ggsave(
  name,
  plot = lsp <- last_plot(),
  device = 'png',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

library(cowplot)
library(magick)

img1 <- image_read("figures/Figure2a.png")
img2 <- image_read("figures/Figure2b.png")
img1 <- image_trim(img1)
img2 <- image_trim(img2)
w1 <- image_info(img1)$width
h1 <- image_info(img1)$height
w2 <- image_info(img2)$width
h2 <- image_info(img2)$height



# Create labels
img1_labeled <- image_annotate(img1, "(a)", size = 30, gravity = "northeast", color = "black", location = "+10+10")
spacer <- image_blank(width = max(image_info(img1)$width, image_info(img2)$width), height = 50, color = "white")
img2_labeled <- image_annotate(img2, "(b)", size = 30, gravity = "northeast", color = "black", location = "+10+10")
final_img <- image_append(c(img1_labeled, spacer, img2_labeled), stack = TRUE)

# Save or display the image
image_write(final_img, "figures/Figure 2.png")

###############################################################################
################################## FIGURE: 3.a ################################
###############################################################################

#' The below code snippet appears in Figure 3.a. The code was screenshot
#' but the reader is invited to look at the code outcome.
library(digiRhythm)
data("df516b_2", package = 'digiRhythm')
df <- df516b_2
head(df)


###############################################################################
################################## FIGURE: 3.b ################################
###############################################################################
#' The below code snippet appears in Figure 3.b. The code was screenshot
#' but the reader is invited to look at the code outcome.

is_dgm_friendly(df, verbose = TRUE)


###############################################################################
################################## FIGURE: 4 ##################################
###############################################################################

#' This code snippet shows how to load a dataset, resample it and compute its
#' DFC. The output is a graph showing the DFC/HP as well as a dataframe containing
#' all the output data in a tabular format.

data("df516b_2", package = 'digiRhythm')
df <- df516b_2
df <- resample_dgm(df, 15)
activity = names(df)[2]

my_dfc <- dfc(df, activity = activity,  alpha = 0.05, plot = FALSE, verbose = FALSE)
name <- paste0('figures/Figure 4.png')
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
################################# Section 2.3 #################################
###############################################################################

#' In the previous code snippet, the variable my_dfc is a ggplot2 object
#' (Wickham, 2010), including both the data (my_dfc$data) and the plot (my_dfc).
#' Because the returned object is a ggplot2, the plot can directly be modified,
#' by adding a layer to the aesthetics of the my_dfc object and plotting it again.
#' This serves as a simple, yet illustrative example of how the graphical outputs
#' of the library can be repurposed. Such a feature becomes especially beneficial
#' when researchers want to change their Figures to specific format required by
#' a target journal. Importantly, this option is possible because the functions
#' in the digiRhythm library are designed to return ggplot2 objects instead of
#' standard R objects. As a dummy example, we show how to change the font size
#' and color of the x-axis of the DFC plot + reducing the size of the font in the
#' legend.

my_dfc +
  theme(
    text=element_text(family="Times", size=8),
    axis.text.y=element_text(size=25, colour="red"))


red###############################################################################
################################## FIGURE: 5 ##################################
###############################################################################

#' We revisit the dataset df512b_2, we show its actogram and show its daily
#' average activity.

df <- df516b_2 # considering the whole dataset
df <- resample_dgm(df, 15)
activity = names(df)[2] # considering the first activity variable (second column usually)
start = "2020-05-01"
end = "2020-06-15"
my_actogram <- actogram(df, activity, activity_alias = 'Motion Index' , start, end, save = NULL)

name <- paste0('figures/Figure5a.png')
ggsave(
  name,
  plot = lsp <- last_plot(),
  device = 'png',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)


my_daa <- daily_average_activity(df,
                                 activity,
                                 activity_alias = 'Motion Index' ,
                                 start,
                                 end,
                                 save = NULL)
name <- paste0('figures/Figure5b.png')
ggsave(
  name,
  plot = lsp <- last_plot(),
  device = 'png',
  width = w,
  height = h,
  scale = 1,
  dpi = dp,
  limitsize = TRUE)

img1 <- image_read("figures/Figure5a.png")
img2 <- image_read("figures/Figure5b.png")
img1 <- image_trim(img1)
img2 <- image_trim(img2)
w1 <- image_info(img1)$width
h1 <- image_info(img1)$height
w2 <- image_info(img2)$width
h2 <- image_info(img2)$height



# Create labels
img1_labeled <- image_annotate(img1, "(a)", size = 30, gravity = "northeast", color = "black", location = "+10+10")
spacer <- image_blank(width = max(image_info(img1)$width, image_info(img2)$width), height = 50, color = "white")
img2_labeled <- image_annotate(img2, "(b)", size = 30, gravity = "northeast", color = "black", location = "+10+10")
final_img <- image_append(c(img1_labeled, spacer, img2_labeled), stack = TRUE)

# Save or display the image
image_write(final_img, "figures/Figure 5.png")


###############################################################################
################################## FIGURE: 6 ##################################8
###############################################################################

#' Here, we show the computation and plot of the diurnality index.

day_time = c("06:30:00", "16:30:00")
night_time = c("18:00:00", "T05:00:00")
my_di <- diurnality(df, activity, day_time, night_time, save = NULL)
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

