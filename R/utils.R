#' Outputs some information about the activity dataframe
#'
#' @param df The dataframe containing the activity data
#' @importFrom utils head tail
#'
#' @export
#'

df_act_info <- function(df){

  print('First days of the data set: ')
  print(head(df))

  print('Last days of the data set: ')
  print(tail(df))

  print(paste('The dataset contains', length(unique(as.Date(df[,1]))), 'Days'))

  first <- as.Date(df[1,1])

  print(paste('Starting date is:', first))

  last <- as.Date(df[nrow(df),1])
  print(paste('Last date is:', last))

}

#' Remove outliers from the data
#'
#' @param df The dataframe containing the activity data
#'
#' @importFrom stats IQR quantile
#'
#' @export


remove_activity_outliers <- function(df){

  data <- df
  for (i in 2:ncol(df)) {
    Q <- quantile(data[,i], probs = c(.25, .75), na.rm = FALSE)
    iqr <- IQR(data[,i])
    up <-  Q[2] + 1.5*iqr # Upper Range
    low <- Q[1] - 1.5*iqr # Lower Range
    non_outliers <- which(data[,i] <= up | data[,i] >= low)
    outliers <- which(data[,i] > up | data[,i] < low)
    mean_without_outliers <- mean(data[non_outliers,i])
    data[outliers, i] <- mean_without_outliers
  }
  return(data)
}


#' Print if Verbose is true
#'
#' @param string The string to print
#' @param verbose if TRUE, print the string
#'
#' @importFrom crayon red green
#'
#' @export

print_v <- function(
  string,
  verbose){

  if(verbose) {
    cat(string, '\n')
  }

}

#' Returns the periodicity of a digiRhythm dataframe
#'
#' @param data a gigiRhythm friendly dataframe
#'
#' @importFrom xts periodicity as.xts
#'
#' @examples
#' data("df516b_2", package = "digiRhythm")
#' df <- df516b_2
#' dgm_periodicity(df)
#' @export

dgm_periodicity <- function(data){

  xts_data <- data
  rownames(xts_data) <- data[,1]
  xts_data[1] <- NULL
  xts_data <- as.xts(xts_data)

  xts::periodicity(xts_data)

}
