#After finish working on the file in the current directory,
#one needs to move some files to the ../dgm folder in order
#to execute an R CMD check independently for a CRAN submission

#Moving the files
rm -rf ../dgm/*
rm -rf ../dgm.Rcheck/*
rm -rf ../digiRhythm*.tar.gz

#Data files
cp -R data ../dgm/data
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

/opt/local/R/4.2.3/bin/R CMD build dgm
/opt/local/R/4.2.3/bin/R CMD check digirhythm_2.3.tar.gz --as-cran dgm

rm -rf ../dgm/*
