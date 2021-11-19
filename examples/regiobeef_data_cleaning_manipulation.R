#Waiting for Markus to extract the data with 1 minute sampling again
library(dplyr)

odir = '~/mnt/Data-Work-PO/23_Livestock-PO/232.1_ruminant_nutrition/Regiobeef/REGIO-02/Rumiwatch-Pédomètres/Donnees/donnes_brutes_non_converties/PM_4_semaines/étable 16d (ration B)_01.09-29.09/615/PM-RWU_00018D68_615.1'
filename = 'RWU_20200901065554_20191005180246_SN00018D68.csv'
df <- read.table(file.path(odir, filename), header = TRUE, sep = ";", dec = ".")
head(df)
#Convert xyz into a single acceleration
#select datetime and acceleration

data <- df %>% mutate(
  accel = sqrt(move_x*move_x + move_y*move_y + move_z*move_z)
) %>%
  select(time, accel)

data <- data %>% mutate(time = as.POSIXct(time, format = "%d.%m.%Y %H:%M:%OS", tz = 'CET'))

data1 <- data %>%
  group_by(time) %>%
  summarise(accel = sum(accel)) %>%
  select(distinct(time), accel)
