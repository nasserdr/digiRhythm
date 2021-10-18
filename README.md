readme
================

## digiRhythm

digiRhythm is an R library developed at Agroscope and provides a set of
tools to analyze and visualize the rhythmic behavior of animals.

**TO DO CORE FUNCTIONALITIES:**

-   [x] Create a function that read Icetag data stored in a CSV file.
-   [x] Add the import_raw_icetage_data as an example to the README
    file.
-   [x] Create a function that computes the degree of functional
    coupling.
-   [x] Add the the dfc as an example to the README file.
-   [ ] Create a function that computes the diurnality index.
-   [ ] Add the the dfc as an example to the README file.

**TO DO - VISUALIZATION FUNCTIONS:**

-   [x] Create a function that visualize the actogram.
-   [ ] Create a function that visualize the actogram + average
    activity.
-   [ ] Create a function that visualize the actogram + average
    activity + DFC.

**TO DO - UTILITIES AND DOCUMENTATIONS:**

-   [x] Define data inside the library
-   [x] Add and example about the improt_raw_icetag_data to the README.
-   [ ] Create a proper documentation for the data set.
-   [ ] configure data sets with lazy loading
-   [ ] Create test functions.

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

#The file name with the path
file <- file.path('data-raw', '516b_2.csv')

#The columns that we are interested in
colstoread <- c("Date", "Time", "Motion Index", 'Steps') 

#Reading the activity data from the csv file
data <- import_raw_icetag_data(filename = file, skipLines = 6, act.cols.names = colstoread, sampling = 15)

print(head(data))
```

    ##              datetime Motion.Index Steps
    ## 1 2020-05-01 00:14:00            7     0
    ## 2 2020-05-01 00:29:00            3     0
    ## 3 2020-05-01 00:44:00           39    13
    ## 4 2020-05-01 00:59:00           37    16
    ## 5 2020-05-01 01:14:00           33    14
    ## 6 2020-05-01 01:29:00           12     1

This is an example on how to visualize the actogram

``` r
activity <- names(data)[2]
start <- "2020-30-04"
end <- "2020-06-05"
save <- TRUE
outputdir <- 'testresults'
outplotname <- 'myplot'
width <- 10
device <- 'tiff'
height <-  5
actogram(data, activity, start, end, save = FALSE,
     outputdir = 'testresults', outplotname = 'actoplot', width = 10,
     height =  5, device = 'tiff')
```

    ## [1] "start function"
    ##              datetime Motion.Index
    ## 1 2020-05-01 00:14:00            7
    ## 2 2020-05-01 00:29:00            3
    ## 3 2020-05-01 00:44:00           39
    ## 4 2020-05-01 00:59:00           37
    ## 5 2020-05-01 01:14:00           33
    ## 6 2020-05-01 01:29:00           12
    ## [1] "plot done"

![](README_files/figure-gfm/visualize-1.png)<!-- -->

This is an example on how to compute the degree of functional coupling.

``` r
data("df516b_2", package = "digiRhythm")
df <- df516b_2
df <- remove_activity_outliers(df)
df_act_info(df)
activity = names(df)[2]
my_dfc <- dfc(df, activity , sampling = 15)
```

![](README_files/figure-gfm/dfc_example-1.png)<!-- -->![](README_files/figure-gfm/dfc_example-2.png)<!-- -->![](README_files/figure-gfm/dfc_example-3.png)<!-- -->![](README_files/figure-gfm/dfc_example-4.png)<!-- -->![](README_files/figure-gfm/dfc_example-5.png)<!-- -->![](README_files/figure-gfm/dfc_example-6.png)<!-- -->![](README_files/figure-gfm/dfc_example-7.png)<!-- -->![](README_files/figure-gfm/dfc_example-8.png)<!-- -->![](README_files/figure-gfm/dfc_example-9.png)<!-- -->![](README_files/figure-gfm/dfc_example-10.png)<!-- -->![](README_files/figure-gfm/dfc_example-11.png)<!-- -->![](README_files/figure-gfm/dfc_example-12.png)<!-- -->![](README_files/figure-gfm/dfc_example-13.png)<!-- -->![](README_files/figure-gfm/dfc_example-14.png)<!-- -->![](README_files/figure-gfm/dfc_example-15.png)<!-- -->![](README_files/figure-gfm/dfc_example-16.png)<!-- -->![](README_files/figure-gfm/dfc_example-17.png)<!-- -->![](README_files/figure-gfm/dfc_example-18.png)<!-- -->![](README_files/figure-gfm/dfc_example-19.png)<!-- -->![](README_files/figure-gfm/dfc_example-20.png)<!-- -->![](README_files/figure-gfm/dfc_example-21.png)<!-- -->![](README_files/figure-gfm/dfc_example-22.png)<!-- -->![](README_files/figure-gfm/dfc_example-23.png)<!-- -->![](README_files/figure-gfm/dfc_example-24.png)<!-- -->![](README_files/figure-gfm/dfc_example-25.png)<!-- -->![](README_files/figure-gfm/dfc_example-26.png)<!-- -->![](README_files/figure-gfm/dfc_example-27.png)<!-- -->![](README_files/figure-gfm/dfc_example-28.png)<!-- -->![](README_files/figure-gfm/dfc_example-29.png)<!-- -->![](README_files/figure-gfm/dfc_example-30.png)<!-- -->![](README_files/figure-gfm/dfc_example-31.png)<!-- -->![](README_files/figure-gfm/dfc_example-32.png)<!-- -->![](README_files/figure-gfm/dfc_example-33.png)<!-- -->![](README_files/figure-gfm/dfc_example-34.png)<!-- -->![](README_files/figure-gfm/dfc_example-35.png)<!-- -->![](README_files/figure-gfm/dfc_example-36.png)<!-- -->![](README_files/figure-gfm/dfc_example-37.png)<!-- -->![](README_files/figure-gfm/dfc_example-38.png)<!-- -->

``` r
#You may want to explore the two list inside my_dfc.
#DFC and SPECTRUM are saved inside my_dfc, each as a list
```
