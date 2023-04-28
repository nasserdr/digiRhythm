#For runs
library(devtools)
library("tools")

#install_github('https://github.com/nasserdr/digiRhythm')

setwd("~/projects/digiRhythm/jstatsoft")
Sweave('article_comr.Rnw')
texi2pdf("article_comr.tex")

# To rerun the pictures:
# Check: ~/projects/digiRhythm/examples/code_snipets_statsoft_paper.R
