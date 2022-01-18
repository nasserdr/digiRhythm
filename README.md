readme
================

## digiRhythm

digiRhythm is an R library developed at Agroscope and provides a set of
tools to analyze and visualize the rhythmic behavior of animals.

**MOST URGENT TO DO:**
-   [ ] Revamp and reorganize this To-Do list.
-   [ ] Create a function that visualize the boxplot of activity per hour from
    day to day.
-   [ ] Create duo, trio and quadro plots functionalities.
-   [ ] Add a dataset that has missing days then update the is_dgm_friendly
    to detect these missing days.
-   [ ] Come up with another name for the function daily_average_activity and 
    create another function for daily and hourly computed activities averaged.
-   [ ] Create a file that conducts a Meta Analysis (like the one of regio_beef)
    code that takes an input file with data configuration, compute everything
    and then save all results in an output file. That would hit.
-   [ ] Add out-of-the-shelf graphical control (width, height, device, line thickness ...)

**TO DO CORE FUNCTIONALITIES:**

-   [x] Create a function that read Icetag data stored in a CSV file.
-   [x] Add the import\_raw\_icetage\_data as an example to the README
    file.
-   [x] Create a function that computes the degree of functional
    coupling.
-   [x] Add the the dfc as an example to the README file.
-   [x] Create a function that computes the diurnality index.
-   [x] Add the the dfc as an example to the README file.
-   [x] Add plotting funtionality to the diurnality index.
-   [ ] Create a function that makes resampling aligned with several function
    like (sum, mean, max, median ... ).
-   [ ] Make the code un-sensible to column names in original data frame (call
    them by index rather than by name). For example, no need to call the datetime
    by its name because it's always the first column (by dgm definition) in the 
    dataset.
-   [ ] Add a function that fills NA values in the activity data set.
-   [ ] Add a function that creates a histogram for the significant and
    harmonic frequencies within the DFC.


**TO DO - VISUALIZATION FUNCTIONS:**

-   [x] Create a function that visualize the actogram.
-   [x] Create a function that visualize the average activity.
-   [x] Create a function that visualize the DFC/HP.
-   [x] Create a function that visualizes all daily activities with
    control over the number of columns.

**TO DO - UTILITIES AND DOCUMENTATIONS:**

-   [x] Define data inside the library
-   [x] Add and example about the import\_raw\_icetag\_data to the
    README.
-   [x] Create a function to test if a data set is digiRhythm friendly.
-   [x] Create a proper documentation for the data set.
-   [x] configure data sets with lazy loading
-   [ ] Create test functions for all the functions.
-   [ ] Add a note about the fact that visualizations were created in a
    way they are aligned with the standards of common journals and give
    details about these settings + Add a note where the code can be
    customized to change these settings.
-   [ ] Make a series of videos about the digiRhythm library.

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
data <- import_raw_activity_data(filename = filename, skipLines = , act.cols.names = colstoread, sampling = 15)

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
df <- remove_activity_outliers(df691b_1)
df_act_info(df)
```

    ## [1] "First days of the data set: "
    ##              datetime Motion.Index Steps
    ## 1 2020-08-25 00:14:00           52    46
    ## 2 2020-08-25 00:29:00           61    39
    ## 3 2020-08-25 00:44:00           29    18
    ## 4 2020-08-25 00:59:00           83    26
    ## 5 2020-08-25 01:14:00           50    23
    ## 6 2020-08-25 01:29:00           43    15
    ## [1] "Last days of the data set: "
    ##                 datetime Motion.Index Steps
    ## 4603 2020-10-11 22:44:00           69    32
    ## 4604 2020-10-11 22:59:00           91    25
    ## 4605 2020-10-11 23:14:00           32    15
    ## 4606 2020-10-11 23:29:00           23    10
    ## 4607 2020-10-11 23:44:00          150    27
    ## 4608 2020-10-11 23:59:00            0     0
    ## [1] "The dataset contains 49 Days"
    ## [1] "Starting date is: 2020-08-24"
    ## [1] "Last date is: 2020-10-11"

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
