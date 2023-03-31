#For runs
library(devtools)
library("tools")

#install_github('https://github.com/nasserdr/digiRhythm')

setwd("~/projects/digiRhythm/jstatsoft")
Sweave('article.Rnw')
texi2pdf("article.tex")
