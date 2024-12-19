#After finish working on the file in the current directory,
#one needs to move some files to the ../dgm folder in order
#to execute an R CMD check independently for a CRAN submission


#Moving the files
cd /home/agsad.admin.ch/f80859433/projects/digiRhythm

# Getting the current version
version=$(awk '/Version: / {print $2}' DESCRIPTION)
echo $version

#Removing existing
rm -rf ../dgm/*
rm -rf ../dgm.Rcheck/*
rm -rf ../digiRhythm*.tar.gz

#Data files
cp -R data ../dgm
cp -R inst ../dgm
cp -R vignettes/* ../dgm/inst/

#Manuals
cp -R man ../dgm

#cp -R Meta ../dgm
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

/opt/local/R/4.3.3/bin/R CMD build dgm
/opt/local/R/4.3.3/bin/R CMD check digirhythm_$version.tar.gz --as-cran dgm

rm -rf ../dgm/*
