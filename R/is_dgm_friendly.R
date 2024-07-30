#' Informs if a dataset is digiRhythm Friendly
#'
#' Takes an activity dataset as input and gives information about 1) If a
#' dataset is digiRhythm friendly, i.e., the functions used can work with this
#' dataset and 2) Tells what's wrong, if any.
#'
#' @param data The dataframe containing the activity data
#' @param verbose if TRUE, prints info about the dataset
#'
#' @return Boolean. If True, the dataframe is digirhythm friendly. If False, the
#' dataframe is not digirhythm friendly.
#'
#' @export
#'
#' @examples
#' data("df516b_2", package = "digiRhythm")
#' d <- df516b_2
#' is_dgm_friendly(data = d, verbose = TRUE)
is_dgm_friendly <- function(data, verbose = FALSE) {
  is_dgm <- TRUE

  if (is.null(data)) {
    message <- crayon::red("Data cannot be NULL")
    print_v(message, verbose)
    is_dgm <- FALSE
  } else {
    # Checking if the first column meets the requirements
    if ("POSIXct" %in% class(data[, 1]) | "POSIXt" %in% class(data[, 1])) {
      message <- paste0(crayon::green("v Correct time format: "), "First column has a POSIXct Format")
      print_v(message, verbose)
    } else {
      message <- paste0(crayon::red("x Inorrect time format: "), "First column does not a POSIXct Format")
      print_v(message, verbose)
      is_dgm <- FALSE
    }


    # Checking if data contains at least 2 days of data
    if (length(unique(as.Date(data[, 1]))) >= 2) {
      message <- paste0(crayon::green("v Number of days good for DFC: "), length(unique(as.Date(data[, 1]))), " days >= 2 days")
      print_v(message, verbose)
    } else {
      message <- paste0(crayon::red("x Number of days NOT good for DFC: "), length(unique(as.Date(data[, 1]))), " days < 2 days (minimum of 2 days is required to compute the DFC, but other functionalities will still work.)")
      print_v(message, verbose)
      is_dgm <- FALSE
    }

    # Checking if we have more than one column
    if (ncol(data) == 1) {
      message <- paste0(crayon::red("x Illogical number of columns: "), "The dataset has only one column. Minimum number of columns is 2")
      print_v(message, verbose)
      is_dgm <- FALSE
    } else {
      # Checking if data are numeric
      for (i in 2:ncol(data)) {
        if ("numeric" %in% class(data[, i]) | "integer" %in% class(data[, i])) {
          message <- crayon::green(paste(
            "v Correct numeric format - Column",
            i, "==>", colnames(data)[i]
          ))
          print_v(message, verbose)
        } else {
          message <- crayon::red(paste(
            "x Inorrect numeric format - Column", i,
            "==>", colnames(data)[i]
          ))
          print_v(message, verbose)
        }
      }
    }
  }


  if (is_dgm) {
    message <- crayon::green("The data is digiRhythm friendly")
    print_v(message, verbose)
  } else {
    message <- crayon::red("The data is NOT digiRhythm friendly")
    print_v(message, verbose)
  }

  return(is_dgm)
}
