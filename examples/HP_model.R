#HP model f?r Paper 1- Verfahrensvergleich

#ben?tigte Packages
library(lme4)
library(DHARMa)
library(data.table)
library(ggpubr)
library(emmeans)
library(flexplot)
library(MuMIn)
library(psych)

#####
#Daten einlesen --> Daten m?ssen alle Versuchstiere und Perioden enthalten
#####
data <- read.csv("/home/agsad.admin.ch/f80859433/projects/digiRhythm/examples/20230413_Gesamttabelle_Paper_1.csv")

table(data$cow)

#####
#Daten ansehen
#####

hist(data$hp)
#looks like an exponetial distribution but includes 0, that could be a problem

median(data$hp)

mean(data$hp)
var(data$hp)
#Mittelwert ist gr??er, als die Varianz, daher kein negative binomial model

#####
#Versuch verschiedener Datentransformationen
#####
hist(log(data$hp))

data$hp2 <- data$hp

#data$hp2[data$hp2 == 0] <- 0.0166123
data$hp2[data$hp2 == 0] <- 0.001

hist(log(data$hp2))

library(lme4)

# Check Heterosckedasticity
# Check the repeated measurement settings
# (1|row) Check if we need to add the id of each observation in case of repeated measurements

# Ve = varExp(form = ~ day)
# DFC.lme2e <- lme(
#   dfc ~ breed * treatment * day,
#   data = DataDFC.df,
#   random = ~ barn|name, #Random effects have to be mentionned
#   weights= Ve, control=ctrl)

model <- glmer(formula = hp ~ 1 + factor(treat) + heat + bedding +
                 ( 1 | herd/cow/lactnr) +
               data = data,
               family = poisson(link = 'log')
               )
residuals <- resid(model)
weights <- 1 / residuals ^ 2 #Other options

model <- glmer(formula = hp ~ 1 + factor(treat) + heat + bedding +
                 ( 1 | herd/cow/lactnr) +
                 data = data,
               weights = weights,
               family = poisson(link = 'log')
)

anova(model)
plot(predict(model), residuals)


resids_betamodel2 <- simulateResiduals(fittedModel = model)
plot(resids_betamodel2)
testDispersion(resids_betamodel2) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel2) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel2) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel2, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel2, catPred = data$cow)
testOutliers(resids_betamodel2) #Ausrei?er
testZeroInflation(resids_betamodel2)
testQuantiles(resids_betamodel2) #Levene Test f?r Varianzhomogenit?t



glmmbetamodel1 <- glmmTMB(hp? ~ , data = data, family = beta_family(link = "logit"))



#####
#Tweedie data???
#####

# Load required libraries
install.packages("tweedie")
library(tweedie)

# Fit Tweedie GLM model with MLE
tweedie_model <- tweedie.profile(hp ~ 1, data = data, method = "mle")

# Extract estimated power value
power_value <- tweedie_model$profile$log.p

# Print estimated power value
cat("Estimated Power Value:", power_value, "\n")

#####
#Gamma distribution??? alpha???
#####

install.packages("dampack")
library(dampack)

#####
# Alpha und p (Tweedie berechnen)
#####

alphaHP <- (mean(data$hp)^2) / var(data$hp)

pHP <- (alphaHP - 2) / (alphaHP - 1)

thetaHP <- var(data$hp) / mean(data$hp)

betaHP <- mean(data$hp) / var(data$hp)

alphaHP / betaHP #da dies dem Mittelwert entspricht

alphaHP / (betaHP^2) #und dies der VArianz handelt es sich bei meinen Daten scheinbar um eine Gammaverteilung

#####
#Modell mit Gammaverteilung
#####

HPmodelg <- glmer(hp ~ 1 + factor(treat) + heat +
                   ( 1 | herd/cow/lactnr), data = data, family = Gamma) #diese Family nutzt inverse als transformation

hist(1/data$hp) #diese Transformation passt nicht wirklich, da keine Normalverteilung entsteht

#####
#Modell mit Poissonverteilung --> Bullshit
#####

HPmodelp <- glmer(hp ~ 1 + factor(treat) + heat +
                   ( 1 | herd/cow/lactnr), data = data, family = poisson) #wie geht poissonverteilung mit + & - inf Werten um? Bei binomial sidn diese jaa cuh entstanden und waren kein Problem

summary(HPmodelp)

emmeans(HPmodelp, ~treat, type = "response")
emmeans(HPmodelp, ~heat, type = "response")

hist(log(data$hp))


logit(data$dfc_na_bin_arg)
log(data$hp)

#####
#Trying a beta model, cause it is better for proportion data
#####
#preparing data for beta model
data$hp? <- data$hp

data$hp?[data$hp? == 0] <- 0.0001


#calculating alpha and beta
alpha?HP <- ((1-mean(data$hp?))/var(data$hp?) - 1/mean(data$hp?))*mean(data$hp?)^2

beta?HP <- alpha?HP*(1/mean(data$hp?) - 1)

#first package to try = betareg
install.packages("betareg")
library(betareg)

betamodel <- betareg(hp? ~ 1 + factor(treat) + heat | herd/cow/lactnr, data = data, link = "logit")

plot(betamodel)

#second model to try = glmmTMB
library(glmmTMB)

glmmbetamodel1 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + bedding +
                            ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel2 <- simulateResiduals(fittedModel = glmmbetamodel1)
plot(resids_betamodel2)
testDispersion(resids_betamodel2) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel2) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel2) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel2, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel2, catPred = data$cow)
testOutliers(resids_betamodel2) #Ausrei?er
testZeroInflation(resids_betamodel2)
testQuantiles(resids_betamodel2) #Levene Test f?r Varianzhomogenit?t


glmmbetamodel2 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + bedding + factor(WIM) +
                            ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel2 <- simulateResiduals(fittedModel = glmmbetamodel2)
plot(resids_betamodel2)
testDispersion(resids_betamodel2) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel2) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel2) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel2, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel2, catPred = data$cow)
testOutliers(resids_betamodel2) #Ausrei?er
testZeroInflation(resids_betamodel2)
testQuantiles(resids_betamodel2) #Levene Test f?r Varianzhomogenit?t


glmmbetamodel3 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + bedding + factor(WIM) +
                            ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel3 <- simulateResiduals(fittedModel = glmmbetamodel3)
plot(resids_betamodel3)
testDispersion(resids_betamodel3) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel3) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel3) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel3, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel3, catPred = data$cow)
testOutliers(resids_betamodel3) #Ausrei?er
testZeroInflation(resids_betamodel3)
testQuantiles(resids_betamodel3) #Levene Test f?r Varianzhomogenit?t


glmmbetamodel4 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + milkingstart_mo +
                            ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel4 <- simulateResiduals(fittedModel = glmmbetamodel4)
plot(resids_betamodel4)
testDispersion(resids_betamodel4) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel4) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel4) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel4, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel4, catPred = data$cow)
testOutliers(resids_betamodel4) #Ausrei?er
testZeroInflation(resids_betamodel4)
testQuantiles(resids_betamodel4) #Levene Test f?r Varianzhomogenit?t


glmmbetamodel5 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + milkingstart_ev +
                            ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel5 <- simulateResiduals(fittedModel = glmmbetamodel5)
plot(resids_betamodel5)
testDispersion(resids_betamodel5) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel5) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel5) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel5, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel5, catPred = data$cow)
testOutliers(resids_betamodel5) #Ausrei?er
testZeroInflation(resids_betamodel5)
testQuantiles(resids_betamodel5) #Levene Test f?r Varianzhomogenit?t


glmmbetamodel6 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + milkingduration_mo +
                            ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel6 <- simulateResiduals(fittedModel = glmmbetamodel6)
plot(resids_betamodel6)
testDispersion(resids_betamodel6) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel6) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel6) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel6, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel6, catPred = data$cow)
testOutliers(resids_betamodel6) #Ausrei?er
testZeroInflation(resids_betamodel6)
testQuantiles(resids_betamodel6) #Levene Test f?r Varianzhomogenit?t


glmmbetamodel7 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + milkingduration_ev +
                            ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel7 <- simulateResiduals(fittedModel = glmmbetamodel7)
plot(resids_betamodel7)
testDispersion(resids_betamodel7) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel7) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel7) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel7, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel7, catPred = data$cow)
testOutliers(resids_betamodel7) #Ausrei?er
testZeroInflation(resids_betamodel7)
testQuantiles(resids_betamodel7) #Levene Test f?r Varianzhomogenit?t


glmmbetamodel8 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + milkingstart_mo + milkingstart_ev +
                            ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel8 <- simulateResiduals(fittedModel = glmmbetamodel8)
plot(resids_betamodel8)
testDispersion(resids_betamodel8) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel8) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel8) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel8, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel8, catPred = data$cow)
testOutliers(resids_betamodel8) #Ausrei?er
testZeroInflation(resids_betamodel8)
testQuantiles(resids_betamodel8) #Levene Test f?r Varianzhomogenit?t


glmmbetamodel9 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + milkingduration_ev + milkingstart_mo +
                            ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel9 <- simulateResiduals(fittedModel = glmmbetamodel9)
plot(resids_betamodel9)
testDispersion(resids_betamodel9) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel9) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel9) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel9, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel9, catPred = data$cow)
testOutliers(resids_betamodel9) #Ausrei?er
testZeroInflation(resids_betamodel9)
testQuantiles(resids_betamodel9) #Levene Test f?r Varianzhomogenit?t


glmmbetamodel10 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + milkingduration_mo + milkingstart_ev +
                            ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel10 <- simulateResiduals(fittedModel = glmmbetamodel10)
plot(resids_betamodel10)
testDispersion(resids_betamodel10) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel10) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel10) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel10, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel10, catPred = data$cow)
testOutliers(resids_betamodel10) #Ausrei?er
testZeroInflation(resids_betamodel10)
testQuantiles(resids_betamodel10) #Levene Test f?r Varianzhomogenit?t


glmmbetamodel11 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + factor(WIM) + milkingstart_mo +
                             ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel11 <- simulateResiduals(fittedModel = glmmbetamodel11)
plot(resids_betamodel11)
testDispersion(resids_betamodel11) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel11) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel11) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel11, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel11, catPred = data$cow)
testOutliers(resids_betamodel11) #Ausrei?er
testZeroInflation(resids_betamodel11)
testQuantiles(resids_betamodel11) #Levene Test f?r Varianzhomogenit?t


glmmbetamodel12 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + factor(WIM) + milkingduration_mo +
                             ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel12 <- simulateResiduals(fittedModel = glmmbetamodel12)
plot(resids_betamodel12)
testDispersion(resids_betamodel12) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel12) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel12) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel12, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel12, catPred = data$cow)
testOutliers(resids_betamodel12) #Ausrei?er
testZeroInflation(resids_betamodel12)
testQuantiles(resids_betamodel12) #Levene Test f?r Varianzhomogenit?t


glmmbetamodel13 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + factor(WIM) + milkingduration_ev +
                             ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel13 <- simulateResiduals(fittedModel = glmmbetamodel13)
plot(resids_betamodel13)
testDispersion(resids_betamodel13) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel13) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel13) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel13, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel13, catPred = data$cow)
testOutliers(resids_betamodel13) #Ausrei?er
testZeroInflation(resids_betamodel13)
testQuantiles(resids_betamodel13) #Levene Test f?r Varianzhomogenit?t


glmmbetamodel14 <- glmmTMB(hp? ~ 1 + factor(treat) + heat + factor(WIM) + milkingduration_ev + milkingstart_mo +
                             ( 1 | herd/cow/lactnr), data = data, family = beta_family(link = "logit"))

resids_betamodel14 <- simulateResiduals(fittedModel = glmmbetamodel14)
plot(resids_betamodel14)
testDispersion(resids_betamodel14) #Homoskedastizit?t = gleichm??ige Streuung der Fehler beim Sch?tzen der Residuen
testResiduals(resids_betamodel14) #gleichzeitige Erfassung von Normalverteilung, Homoskedastizit?t und Ausrei?er
testUniformity(resids_betamodel14) #KS genereller Test der Normalverteilung
testCategorical(resids_betamodel14, catPred = data$herd) #Test auf gleichheit der Gruppen
testCategorical(resids_betamodel14, catPred = data$cow)
testOutliers(resids_betamodel14) #Ausrei?er
testZeroInflation(resids_betamodel14)
testQuantiles(resids_betamodel14) #Levene Test f?r Varianzhomogenit?t

#Modellvoraussetzungen in keinem einzigen Modell erf?llt!!!

