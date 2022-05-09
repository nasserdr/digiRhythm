#Documentation
# This function plot the actogram, the average activity, the daily activity,
# the degree of functional coupling/harmonic power. The function has the possibility
# to plot one of these variables or a combination of them.
#
# All images are saved in TIFF format with a resolution of XX YY and size
#
# You can have the following choices to show/save plot:
# To show plots, use plot = TRUE
# To save plots, use Version = 1, 2, 3 or 4. Use NULL if you don't want to save plots
# Keep in mind that some plots could not be show in the Rstudio because they are big.
# Version 1: Actogram
# Version 2: Version 1 + Average activity
# Version 3: Version 2 + Degree of functional coupling / harmonic power
# Version 4: Version 3 + Daily activity

#Concept
#Decide which plot to produce according to the version
#Then prepare the data for the plot and create the plot
#At the end, show or save plots according to whether they would be saved or not

#Imports
library(ggplot2)
library(dplyr)
library(lubridate)
library(digiRhythm)


#Example
data("df516b_2")
df <- df516b_2
digiRhythm::df_act_info(df)


#Agruments
activity <- names(df)[2]
activity_alias <- 'Motion Index'
start <- "2020-05-01" #year-month-day
end <- "2020-08-13" #year-month-day
version <- 1
sampling_rate <- 15
filename <- 'image.tiff'

#Start of the function
start <- lubridate::date(start)
end <- lubridate::date(end)

`%nin%` = Negate(`%in%`)

################################################################################
#Taking care of the Actogram and if version == 1################################
################################################################################

df$date <- lubridate::date(df$datetime)
data_to_plot <- df %>%
  filter(lubridate::date(datetime) >= start) %>%
  filter(lubridate::date(datetime) <= end)
data_to_plot$time <- format(data_to_plot$datetime, format = "%H:%M", tz = "CET")

act_plot <- ggplot(data_to_plot,
             aes(x = time,
                 y = date,
                 fill = .data[[activity]])) +
  geom_tile()+
  xlab("Time")+
  ylab("Date") +
  ggtitle("Single actogram") +
  scale_fill_gradient(name = activity_alias,
                      low = "#FFFFFF",
                      high = "#000000",
                      na.value = "yellow")+
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_x_discrete(breaks = c("03:00", "09:00", "15:00", "21:00")) +
  theme(
    axis.text.x = element_text(color="#000000"),
    axis.text.y = element_text(color="#000000"),
    text=element_text(family = 'Arial', size = 12),
    panel.background = element_rect(fill = "white"),
    axis.line = element_line(size = 0.5)
  )


################################################################################
#Taking care of version 2 and the average activity##############################
################################################################################

sum_of_activity_over_all_days_per_sample = NULL
sum_of_activity_over_all_days_per_sample =  data.frame(
  time = as.character(),
  average = as.numeric()
)

for(t in unique(data_to_plot$time)){
  tdf <- data_to_plot %>% filter(time == t)
  mean = mean(tdf[[activity]])
  sum_of_activity_over_all_days_per_sample <- rbind(
    sum_of_activity_over_all_days_per_sample,
    data.frame(
      time = t,
      average = mean)
  )
}

s <- sum_of_activity_over_all_days_per_sample

s$datetime <- paste(data_to_plot$date[1], s$time)
s$datetime <- as.POSIXct(s$datetime, format("%Y-%m-%d %H:%M"))

avg_act_plot <- ggplot(s,
            aes(
              x = datetime,
              y = average
            )) +
  geom_line() +
  xlab("Time") +
  ylab(paste0("Average of ", activity_alias, " over all days")) +
  scale_x_datetime(date_labels = "%H:%M") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(
    axis.text.x = element_text(color="#000000"),
    axis.text.y = element_text(color="#000000"),
    text=element_text(family = 'Arial', size = 12),
    panel.background = element_rect(fill = "white"),
    axis.line = element_line(size = 0.5))




################################################################################
#Taking care of version 3 and the DFC/HP #######################################
################################################################################
dfc.analysis =  digiRhythm::dfc(
  data = data_to_plot,
  activity = activity,
  sampling = 15,
  show_lsp_plot = TRUE,
  verbose = FALSE)


dfc <- dfc.analysis$dfc
dfc$date <- as.Date(dfc$date, format("%Y-%m-%d"))
dfc$DFC <- as.numeric(dfc$dfc)
dfc$HP <- as.numeric(dfc$hp)

dfc_plot <- ggplot(dfc, aes(x = date)) +
  geom_line(aes(y = DFC, linetype="Degree of functional coupling (%)")) +
  geom_line(aes(y = HP, linetype="Harmonic power")) +
  xlab("") +
  ylab("") +
  xlim(data_to_plot$date[1], last(data_to_plot$date))+
  theme(
    axis.text.y = element_blank(),
    panel.background = element_rect(fill = "white"),
    axis.line = element_line(size = 0.5),
    legend.key = element_rect(fill = "white"),
    legend.key.width= unit(0.5, "cm"),
    legend.justification="left",
    legend.key.size = unit(7, "pt"),
    legend.title = element_blank(),
    legend.position=c(0.05,0.95)) +
  coord_flip()



################################################################################
#Taking care of version 4 and the day-to-day activity###########################
################################################################################

time2 = rep(1:(24*60/sampling_rate), length(unique(data_to_plot$date)))
data_to_plot$time2 <- time2[1:dim(data_to_plot)[1]]


days <- unique(data_to_plot$date)
l <- ceiling(length(days)/2)

batch1 <- data_to_plot %>% filter(data_to_plot$date <= days[l])
batch2 <- data_to_plot %>% filter(data_to_plot$date > days[l])

p4 <- ggplot(batch1, aes(
  x = time2,
  y = !!as.name(activity)))+
  geom_area() +
  facet_wrap(~date, ncol = 1) +
  ggtitle(paste(activity_alias, "(", days[1], "-", days[l],")")) +
  xlab("Time") +
  theme(
    panel.background = element_rect(fill = "white"),
    legend.key = element_rect(fill = "white"),
    legend.key.width= unit(0.5, "cm"),
    legend.justification="left",
    legend.key.size = unit(7, "pt"),
    strip.background = element_blank(),
    strip.text.x = element_blank(),
    axis.title.y=element_blank(),
    axis.text.y=element_blank(),
    axis.ticks.y=element_blank(),
    axis.line=element_blank(),
    plot.title = element_text(hjust = 0.5),
    legend.position=c(0.05,0.89)) +
  scale_x_continuous(
    breaks = seq(sampling_rate - 2, 24*60/sampling_rate - sampling_rate+4, length.out = 4),
    label = c("03:00", "09:00", "15:00", "21:00")
  )

p5 <- ggplot(batch2, aes(
  x = time2,
  y = !!as.name(activity)))+
  geom_area() +
  facet_wrap(~date, ncol = 1) +
  ggtitle(paste(activity_alias, "(", days[l+1], "-", days[length(days)], ")")) +
  xlab("Time") +
  theme(
    panel.background = element_rect(fill = "white"),
    legend.key = element_rect(fill = "white"),
    legend.key.width= unit(0.5, "cm"),
    legend.justification="left",
    legend.key.size = unit(7, "pt"),
    strip.background = element_blank(),
    strip.text.x = element_blank(),
    axis.title.y=element_blank(),
    axis.text.y=element_blank(),
    axis.ticks.y=element_blank(),
    axis.line=element_blank(),
    plot.title = element_text(hjust = 0.5),
    legend.position=c(0.05,0.89)) +
  scale_x_continuous(
    breaks = seq(sampling_rate - 2, 24*60/sampling_rate - sampling_rate+4, length.out = 4),
    label = c("03:00", "09:00", "15:00", "21:00")
  )

#Laying out things
if (version == 1){
  ggsave(
    filename,
    act_plot,
    device = 'tiff',
    width = 15,
    height = 6,
    units = "cm",
    dpi = 600
  )
} else {
  act_plot <- act_plot + theme(legend.position = "none")
}

layout <- c(
  area(1,1,1,2),
  area(1,3,1,3),
  area(2,1,2,2),
  area(1,4,2,4),
  area(1,5,2,5)
)


p1 + p2 + p3 + p4 + p5 + plot_layout(design = layout)

