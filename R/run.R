library("devtools")
library("tools")

#tinytex::tlmgr_install("textcase")

setwd("~/projects/digiRhythm/sagepub/original/")
#install_github('https://github.com/nasserdr/digiRhythm')
texi2pdf("Sage_LaTeX_Guidelines.tex")
