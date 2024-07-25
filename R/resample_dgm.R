#' Change the sampling of a digiRhythm friendly dataset
#'
#' This function upsamples the data but does not downsample them. The new
#' sampling should be a multiple of the current sampling period, and should be
#' given in minutes.
#'
#' @param data The dataframe containing the activity data
#' @param new_sampling The new sampling (multiple of current sampling) in
#' minutes
#'
#' @return A digiRhythm friendly dataset with the new sampling
#'
#' @export
#'
#' @examples
#' data("df516b_2", package = "digiRhythm")
#' df <- df516b_2
#' df <- remove_activity_outliers(df)
#' new_sampling <- 30
#' new_dgm <- resample_dgm(df, new_sampling)
resample_dgm <- function(data, new_sampling) {
  xts_data <- xts::xts(
    x = data[, c(2:ncol(data))],
    order.by = data[, 1]
  )


  original_sampling <- xts::periodicity(xts_data)$frequency

  if ((new_sampling %% original_sampling) != 0) {
    stop("The new sampling should be a multiple of the current sampling in
         minutes")
  }

  if (new_sampling < original_sampling) {
    stop("The new sampling should be bigger than the current sampling")
  }

  if (is.null(new_sampling)) {
    stop("The new sampling cannot be NULL")
  }

  if (new_sampling <= 0) {
    stop("The new sampling cannot be non-positive")
  }

  sampled_xts <- NULL
  for (var in names(xts_data)) {
    xts_var <- xts::period.apply(
      xts_data[, var],
      xts::endpoints(xts_data, on = "minutes", k = new_sampling),
      FUN = sum
    )
    sampled_xts <- cbind(sampled_xts, xts_var)
  }

  new_data <- data.frame(
    datetime = zoo::index(sampled_xts),
    zoo::coredata(sampled_xts)
  )

  return(new_data)
}
