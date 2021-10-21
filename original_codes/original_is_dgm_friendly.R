library(crayon)
data("df516b_2", package = "digiRhythm")
data <- df516b_2

verbose = TRUE
is_dgm <- TRUE

#Add isNull option
#Add minimum 2 days options
#Add warning that if less than 7 days we cant compute the DFC

if("POSIXct" %in%  class(data[,1])  | "POSIXt" %in%  class(data[,1])){
  message <- paste0(green('v Correct time format: '), 'First column has a Posixct Format')
  print_v(message, verbose)
}else {
  message <- paste0(red('x Inorrect time format: '), 'First column does not a Posixct Format')
  print_v(message, verbose)
  is_dgm <- FALSE
}


if(ncol(data) == 1){
  message <- paste0(red('x Illogical number of columns: '), 'The dataset has only one column. Minimum number of columns is 2')
  print_v(message, verbose)
  is_dgm <- FALSE
}else{
  for(i in 2:ncol(data)){
    if("numeric" %in% class(data[,i]) | "integer" %in%  class(data[,i])){
      message <- green(paste('v Correct numeric format - Column', i, '==>', colnames(data)[i]))
      print_v(message, verbose)
    } else {
      message <- red(paste('x Inorrect numeric format - Column', i, '==>', colnames(data)[i]))
      print_v(message, verbose)
    }
  }
}


if(is_dgm){
  message <- green('The data is digiRhythm friendly')
  print_v(message, verbose)
} else{
  message <- red('The data is NOT digiRhythm friendly')
  print_v(message, verbose)
}

return(is_dgm)

