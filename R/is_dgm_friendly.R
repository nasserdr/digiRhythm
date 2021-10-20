#' Informs if a dataset is digiRhythm Friendly
#'
#' Takes an activity dataset as input and gives information about:
#' \itemize{
#'   \itemize If a dataset is digiRhythm friendly, i.e., the functions used
#'   can work with this dataset
#'   \itemize Tells what's wrong, if any.
#' }
#'
#' @return None
#' @param data The dataframe containing the activity data
#' @param verbose if TRUE, prints info about the dataset
#'
#' @import crayon
#' @export
#'
#' @examples
#' data("df516b_2", package = "digiRhythm")
#' data <- df516b_2
#' is_dgm_friendly(data)


is_dgm_friendly <- function(data, verbose = FALSE){

  is_dgm <- TRUE

  #Add isNull option
  #Add minimum 2 days options
  #Add warning that if less than 7 days we cant compute the DFC

  if(class(data[,1]) %in% c("POSIXct", "POSIXt")){
    if(verbose){
      cat(paste0(green('v Correct time format: '), 'First column has a Posixct Format'))
    }
    is_dgm <- FALSE
  }else {
    if(verbose){
      cat(paste0(red('x Inorrect time format: '), 'First column does not a Posixct Format'))
    }
  }

  if(ncol(data) == 1){
    if(verbose){
      cat(paste0(red('x Illogical number of columns: '), 'The dataset has only one column. Minimum number of columns is 2'))
    }
    is_dgm <- FALSE
  }
  else{
    for(i in 2:ncol(data)){
      if(class(data[,1]) %in% c("num", "int", "int3")){
        if(verbose){
          cat(green(paste('v Correct numeric format - Column', i, '==>', colnames(data)[i])))
        }
        is_dgm <- FALSE
      }else {
        if(verbose){
          cat(red(paste('x Inorrect numeric format - Column', i, '==>', colnames(data)[i])))
          }
      }
    }
  }

  if(is_dgm){
    cat(green('The data is digiRhythm friendly'))
  } else{
    cat(red('The data is NOT digiRhythm friendly'))
  }

}
