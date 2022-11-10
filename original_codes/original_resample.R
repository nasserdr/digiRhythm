#imports
library(xts)
#inputs
data("df516b_2", package = "digiRhythm")
df <- df516b_2
df <- digiRhythm::remove_activity_outliers(df)
new_sampling <- 30


#Ensuring that the dataframe has a dataframe class instead of tibble
df <- as.data.frame(df)
xts_data <- df
xts_data <- xts(
  x = df[,c(2:ncol(df))],
  order.by = df[,1]
)

original_sampling <- xts::periodicity(xts_data)$frequency

if((new_sampling %% original_sampling) != 0){
  stop("The new sampling should be a multiple of the current sampling in minutes")
}

if(new_sampling < original_sampling){
  stop("The new sampling should be bigger than the current sampling")
}

sampled_xts <- NULL
for(var in names(xts_data)){
  xts_var <- period.apply(
    xts_data[,var],
    endpoints(xts_data, on = 'minutes', k = new_sampling),
    FUN = sum)
  sampled_xts <- cbind(sampled_xts, xts_var)
}

new_data <- data.frame(
  datetime = index(sampled_xts),
  coredata(sampled_xts)
)

