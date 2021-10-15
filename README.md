readme
================

## digiRhythm

digiRhythm is an R library developed at Agroscope and provides a set of
tools to analyze and visualize the rhythmic behavior of animals.

**TO DO:**

-   [x] Define data inside the library
-   [x] Create a function that read Icetag data stored in a CSV file.
-   [x] Add and example about the improt_raw_icetag_data to the README.
-   [ ] Create a function that visualize the actogram.
-   [ ] Add the previous function as an example to the README file.
-   [ ] Create test functions.
-   [ ] Create a function that computes the degree of functional
    coupling.
-   [ ] Create a function that computes the diurnality index.
-   [ ] Shiny app?

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
#Uncomment the below two lines if you use the library for the first time of if
#you want to update the library
#install.packages("devtools")
#devtools::install_github("nasserdr/digiRhythm", dependencies = TRUE)
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(digiRhythm)
library(xts)

#The file name with the path
file <- file.path('data-raw', '516b_2.csv')

#The columns that we are interested in
colstoread <- c("Date", "Time", "Motion Index", 'Steps') 

#Reading the activity data from the csv file
data <- improt_raw_icetag_data(filename = file, skipLines = 7, act.cols.names = colstoread, sampling = 15, verbose = FALSE)

print(head(data))
```

    ##              datetime Motion.Index Steps
    ## 1 2020-05-01 00:14:00            7     0
    ## 2 2020-05-01 00:29:00            3     0
    ## 3 2020-05-01 00:44:00           39    13
    ## 4 2020-05-01 00:59:00           37    16
    ## 5 2020-05-01 01:14:00           33    14
    ## 6 2020-05-01 01:29:00           12     1
