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
```

    ## [1] "First days of the data set: "
    ##              datetime Motion.Index Steps
    ## 1 2020-05-01 00:14:00            7     0
    ## 2 2020-05-01 00:29:00            3     0
    ## 3 2020-05-01 00:44:00           39    13
    ## 4 2020-05-01 00:59:00           37    16
    ## 5 2020-05-01 01:14:00           33    14
    ## 6 2020-05-01 01:29:00           12     1
    ## [1] "Last days of the data set: "
    ##                 datetime Motion.Index Steps
    ## 4315 2020-06-14 22:44:00            8     5
    ## 4316 2020-06-14 22:59:00            6     4
    ## 4317 2020-06-14 23:14:00           86    29
    ## 4318 2020-06-14 23:29:00            4     0
    ## 4319 2020-06-14 23:44:00            0     0
    ## 4320 2020-06-14 23:59:00            4     0
    ## [1] "The dataset contains 46 Days"
    ## [1] "Starting date is: 2020-04-30"
    ## [1] "Last date is: 2020-06-14"

``` r
activity = names(df)[2]
my_dfc <- dfc(df, activity , sampling = 15)
```

    ## Processing dates  2020-05-01  until  2020-05-07 
    ## Dates filtered are:  2020-05-01 2020-05-02 2020-05-03 2020-05-04 2020-05-05 2020-05-06 2020-05-07

![](README_files/figure-gfm/asdasfasf-1.png)<!-- -->

    ## Processing dates  2020-05-02  until  2020-05-08 
    ## Dates filtered are:  2020-05-02 2020-05-03 2020-05-04 2020-05-05 2020-05-06 2020-05-07 2020-05-08

![](README_files/figure-gfm/asdasfasf-2.png)<!-- -->

    ## Processing dates  2020-05-03  until  2020-05-09 
    ## Dates filtered are:  2020-05-03 2020-05-04 2020-05-05 2020-05-06 2020-05-07 2020-05-08 2020-05-09

![](README_files/figure-gfm/asdasfasf-3.png)<!-- -->

    ## Processing dates  2020-05-04  until  2020-05-10 
    ## Dates filtered are:  2020-05-04 2020-05-05 2020-05-06 2020-05-07 2020-05-08 2020-05-09 2020-05-10

![](README_files/figure-gfm/asdasfasf-4.png)<!-- -->

    ## Processing dates  2020-05-05  until  2020-05-11 
    ## Dates filtered are:  2020-05-05 2020-05-06 2020-05-07 2020-05-08 2020-05-09 2020-05-10 2020-05-11

![](README_files/figure-gfm/asdasfasf-5.png)<!-- -->

    ## Processing dates  2020-05-06  until  2020-05-12 
    ## Dates filtered are:  2020-05-06 2020-05-07 2020-05-08 2020-05-09 2020-05-10 2020-05-11 2020-05-12

![](README_files/figure-gfm/asdasfasf-6.png)<!-- -->

    ## Processing dates  2020-05-07  until  2020-05-13 
    ## Dates filtered are:  2020-05-07 2020-05-08 2020-05-09 2020-05-10 2020-05-11 2020-05-12 2020-05-13

![](README_files/figure-gfm/asdasfasf-7.png)<!-- -->

    ## Processing dates  2020-05-08  until  2020-05-14 
    ## Dates filtered are:  2020-05-08 2020-05-09 2020-05-10 2020-05-11 2020-05-12 2020-05-13 2020-05-14

![](README_files/figure-gfm/asdasfasf-8.png)<!-- -->

    ## Processing dates  2020-05-09  until  2020-05-15 
    ## Dates filtered are:  2020-05-09 2020-05-10 2020-05-11 2020-05-12 2020-05-13 2020-05-14 2020-05-15

![](README_files/figure-gfm/asdasfasf-9.png)<!-- -->

    ## Processing dates  2020-05-10  until  2020-05-16 
    ## Dates filtered are:  2020-05-10 2020-05-11 2020-05-12 2020-05-13 2020-05-14 2020-05-15 2020-05-16

![](README_files/figure-gfm/asdasfasf-10.png)<!-- -->

    ## Processing dates  2020-05-11  until  2020-05-17 
    ## Dates filtered are:  2020-05-11 2020-05-12 2020-05-13 2020-05-14 2020-05-15 2020-05-16 2020-05-17

![](README_files/figure-gfm/asdasfasf-11.png)<!-- -->

    ## Processing dates  2020-05-12  until  2020-05-18 
    ## Dates filtered are:  2020-05-12 2020-05-13 2020-05-14 2020-05-15 2020-05-16 2020-05-17 2020-05-18

![](README_files/figure-gfm/asdasfasf-12.png)<!-- -->

    ## Processing dates  2020-05-13  until  2020-05-19 
    ## Dates filtered are:  2020-05-13 2020-05-14 2020-05-15 2020-05-16 2020-05-17 2020-05-18 2020-05-19

![](README_files/figure-gfm/asdasfasf-13.png)<!-- -->

    ## Processing dates  2020-05-14  until  2020-05-20 
    ## Dates filtered are:  2020-05-14 2020-05-15 2020-05-16 2020-05-17 2020-05-18 2020-05-19 2020-05-20

![](README_files/figure-gfm/asdasfasf-14.png)<!-- -->

    ## Processing dates  2020-05-15  until  2020-05-21 
    ## Dates filtered are:  2020-05-15 2020-05-16 2020-05-17 2020-05-18 2020-05-19 2020-05-20 2020-05-21

![](README_files/figure-gfm/asdasfasf-15.png)<!-- -->

    ## Processing dates  2020-05-16  until  2020-05-22 
    ## Dates filtered are:  2020-05-16 2020-05-17 2020-05-18 2020-05-19 2020-05-20 2020-05-21 2020-05-22

![](README_files/figure-gfm/asdasfasf-16.png)<!-- -->

    ## Processing dates  2020-05-17  until  2020-05-23 
    ## Dates filtered are:  2020-05-17 2020-05-18 2020-05-19 2020-05-20 2020-05-21 2020-05-22 2020-05-23

![](README_files/figure-gfm/asdasfasf-17.png)<!-- -->

    ## Processing dates  2020-05-18  until  2020-05-24 
    ## Dates filtered are:  2020-05-18 2020-05-19 2020-05-20 2020-05-21 2020-05-22 2020-05-23 2020-05-24

![](README_files/figure-gfm/asdasfasf-18.png)<!-- -->

    ## Processing dates  2020-05-19  until  2020-05-25 
    ## Dates filtered are:  2020-05-19 2020-05-20 2020-05-21 2020-05-22 2020-05-23 2020-05-24 2020-05-25

![](README_files/figure-gfm/asdasfasf-19.png)<!-- -->

    ## Processing dates  2020-05-20  until  2020-05-26 
    ## Dates filtered are:  2020-05-20 2020-05-21 2020-05-22 2020-05-23 2020-05-24 2020-05-25 2020-05-26

![](README_files/figure-gfm/asdasfasf-20.png)<!-- -->

    ## Processing dates  2020-05-21  until  2020-05-27 
    ## Dates filtered are:  2020-05-21 2020-05-22 2020-05-23 2020-05-24 2020-05-25 2020-05-26 2020-05-27

![](README_files/figure-gfm/asdasfasf-21.png)<!-- -->

    ## Processing dates  2020-05-22  until  2020-05-28 
    ## Dates filtered are:  2020-05-22 2020-05-23 2020-05-24 2020-05-25 2020-05-26 2020-05-27 2020-05-28

![](README_files/figure-gfm/asdasfasf-22.png)<!-- -->

    ## Processing dates  2020-05-23  until  2020-05-29 
    ## Dates filtered are:  2020-05-23 2020-05-24 2020-05-25 2020-05-26 2020-05-27 2020-05-28 2020-05-29

![](README_files/figure-gfm/asdasfasf-23.png)<!-- -->

    ## Processing dates  2020-05-24  until  2020-05-30 
    ## Dates filtered are:  2020-05-24 2020-05-25 2020-05-26 2020-05-27 2020-05-28 2020-05-29 2020-05-30

![](README_files/figure-gfm/asdasfasf-24.png)<!-- -->

    ## Processing dates  2020-05-25  until  2020-05-31 
    ## Dates filtered are:  2020-05-25 2020-05-26 2020-05-27 2020-05-28 2020-05-29 2020-05-30 2020-05-31

![](README_files/figure-gfm/asdasfasf-25.png)<!-- -->

    ## Processing dates  2020-05-26  until  2020-06-01 
    ## Dates filtered are:  2020-05-26 2020-05-27 2020-05-28 2020-05-29 2020-05-30 2020-05-31 2020-06-01

![](README_files/figure-gfm/asdasfasf-26.png)<!-- -->

    ## Processing dates  2020-05-27  until  2020-06-02 
    ## Dates filtered are:  2020-05-27 2020-05-28 2020-05-29 2020-05-30 2020-05-31 2020-06-01 2020-06-02

![](README_files/figure-gfm/asdasfasf-27.png)<!-- -->

    ## Processing dates  2020-05-28  until  2020-06-03 
    ## Dates filtered are:  2020-05-28 2020-05-29 2020-05-30 2020-05-31 2020-06-01 2020-06-02 2020-06-03

![](README_files/figure-gfm/asdasfasf-28.png)<!-- -->

    ## Processing dates  2020-05-29  until  2020-06-04 
    ## Dates filtered are:  2020-05-29 2020-05-30 2020-05-31 2020-06-01 2020-06-02 2020-06-03 2020-06-04

![](README_files/figure-gfm/asdasfasf-29.png)<!-- -->

    ## Processing dates  2020-05-30  until  2020-06-05 
    ## Dates filtered are:  2020-05-30 2020-05-31 2020-06-01 2020-06-02 2020-06-03 2020-06-04 2020-06-05

![](README_files/figure-gfm/asdasfasf-30.png)<!-- -->

    ## Processing dates  2020-05-31  until  2020-06-06 
    ## Dates filtered are:  2020-05-31 2020-06-01 2020-06-02 2020-06-03 2020-06-04 2020-06-05 2020-06-06

![](README_files/figure-gfm/asdasfasf-31.png)<!-- -->

    ## Processing dates  2020-06-01  until  2020-06-07 
    ## Dates filtered are:  2020-06-01 2020-06-02 2020-06-03 2020-06-04 2020-06-05 2020-06-06 2020-06-07

![](README_files/figure-gfm/asdasfasf-32.png)<!-- -->

    ## Processing dates  2020-06-02  until  2020-06-08 
    ## Dates filtered are:  2020-06-02 2020-06-03 2020-06-04 2020-06-05 2020-06-06 2020-06-07 2020-06-08

![](README_files/figure-gfm/asdasfasf-33.png)<!-- -->

    ## Processing dates  2020-06-03  until  2020-06-09 
    ## Dates filtered are:  2020-06-03 2020-06-04 2020-06-05 2020-06-06 2020-06-07 2020-06-08 2020-06-09

![](README_files/figure-gfm/asdasfasf-34.png)<!-- -->

    ## Processing dates  2020-06-04  until  2020-06-10 
    ## Dates filtered are:  2020-06-04 2020-06-05 2020-06-06 2020-06-07 2020-06-08 2020-06-09 2020-06-10

![](README_files/figure-gfm/asdasfasf-35.png)<!-- -->

    ## Processing dates  2020-06-05  until  2020-06-11 
    ## Dates filtered are:  2020-06-05 2020-06-06 2020-06-07 2020-06-08 2020-06-09 2020-06-10 2020-06-11

![](README_files/figure-gfm/asdasfasf-36.png)<!-- -->

    ## Processing dates  2020-06-06  until  2020-06-12 
    ## Dates filtered are:  2020-06-06 2020-06-07 2020-06-08 2020-06-09 2020-06-10 2020-06-11 2020-06-12

![](README_files/figure-gfm/asdasfasf-37.png)<!-- -->

    ## Processing dates  2020-06-07  until  2020-06-13 
    ## Dates filtered are:  2020-06-07 2020-06-08 2020-06-09 2020-06-10 2020-06-11 2020-06-12 2020-06-13

![](README_files/figure-gfm/asdasfasf-38.png)<!-- -->

``` r
#You may want to explore the two list inside my_dfc.
#DFC and SPECTRUM are saved inside my_dfc, each as a list
```
