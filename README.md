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
-   [ ] Create a function to test if a dataset is digiRhythm friendly.
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
url <- 'https://github.com/nasserdr/digiRhythm_sample_datasets/raw/main/516b_2.csv'
download.file(url, destfile = '516b_2.csv')
filename <- file.path(getwd(), '516b_2.csv')

#The columns that we are interested in
colstoread <- c("Date", "Time", "Motion Index", 'Steps') 

#Reading the activity data from the csv file
data <- import_raw_icetag_data(filename = filename, skipLines = , act.cols.names = colstoread, sampling = 15)

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
data("df516b_2", package = "digiRhythm")
df <- remove_activity_outliers(df516b_2)
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
df <- remove_activity_outliers(df516b_2)
df_act_info(df)
activity = names(df)[2]
my_dfc <- dfc(df, activity , sampling = 15, show_lsp_plot = FALSE)

#You may want to explore the two list inside my_dfc.
#DFC and SPECTRUM are saved inside my_dfc, each as a list
```

This is an example on how to compute the diurnality index:

``` r
data("df516b_2", package = "digiRhythm")
df <- remove_activity_outliers(df516b_2)
df_act_info(df)
activity = names(df)[2]
d_index <- diurnality(data, activity, plot = TRUE)
```

![](README_files/figure-gfm/dindex_example-1.png)<!-- -->

This is an example on how you can resample your data:

``` r
data("df516b_2", package = "digiRhythm")
df <- df516b_2
df <- remove_activity_outliers(df)
new_sampling <- 30
new_dgm <- resample_dgm(df, new_sampling)
```
