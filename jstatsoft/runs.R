#For runs
library("devtools")
library("tools")

setwd("~/projects/digiRhythm/jstatsoft")
#install_github('https://github.com/nasserdr/digiRhythm')
Sweave('article.Rnw')
texi2pdf("article.tex")

# To rerun the pictures:
# Check: ~/projects/digiRhythm/examples/code_snipets_statsoft_paper.R
