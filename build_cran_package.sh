#After finish working on the file in the current directory,
#one needs to move some files to the ../dgm folder in order
#to execute an R CMD check independently for a CRAN submission

#Moving the files
rm -rf ../dgm/*

#Data files
cp -R data ../dgm
cp -R inst ../dgm

#Manuals
cp -R man ../dgm

cp -R Meta ../dgm
cp -R doc ../dgm/inst

#Code
cp -R R ../dgm

#Vignettes
cp -R vignettes ../dgm

#Desc, namespace and readme files
cp -R DESCRIPTION ../dgm
cp -R NAMESPACE ../dgm
cp -R README.md ../dgm

cd ..

/opt/local/R/4.1.3/bin/R CMD check --as-cran dgm
/opt/local/R/4.1.3/bin/R CMD build dgm
