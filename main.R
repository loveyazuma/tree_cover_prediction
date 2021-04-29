# Check availability of libraries
list.of.packages <- c("randomForest", "rgdal", "raster", "sf", "sp")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)>0) {install.packages(new.packages)}


#Source external functions
source("./R/Correct_TC.R")
source("./R/calc_TreeCover_byLandCover.R")
# download data and upzip
library(randomForest)
library(raster)
library(rgdal)

# Download data and upzip
data_URL <- "https://www.dropbox.com/s/cv1de2fmy855wpy/data.zip?dl=1"
data_folder <- "./data"

if (!dir.exists(data_folder)){
  dir.create(data_folder)
}

if (!dir.exists('output')) {
  dir.create('output')
}

if (!file.exists('./data/data.zip')) {
  download.file(url = data_URL, destfile = './data/data.zip', method = 'auto')
  unzip('./data/data.zip', exdir = './data')
}

# Load the image files
gewata_images <- list.files(data_folder, pattern = glob2rx('*Band*'), full.names = TRUE)
for (i in 1:length(gewata_images)){
    load(gewata_images[[i]])
  }

# Stack layers and change the band names
GewataStack = stack(GewataBand1, GewataBand2, GewataBand3, GewataBand4, GewataBand5, GewataBand7)

# Rescale reflectance to 0-1
Gewata <- calc(GewataStack, fun = function(x) {x/1000})
names(GewataStack) = c("Band1", "Band2", "Band3", "Band4", "Band5", "Band7")

# Load training points and classes polygons
load("data/trainPnts")
load('./data/classPoly.rda')

# Extract values from bands
Gewata_vcf <- extract(GewataStack,trainingPnts)

# Convert to data frame
Gewata_vcf <- as.data.frame(Gewata_vcf)

# Attach VCF column to valuetable
valuetable <- cbind(Gewata_vcf, trainingPnts$VCF)
names(valuetable) <- c("Band1", "Band2", "Band3", "Band4", "Band5", "Band7", "VCF")

# Omit all NA values
valuetable <- na.omit(valuetable)

# Task 1: Predict tree cover using RandomForest() AND lm()  models
# Random forest model
modelRF <- randomForest(x=valuetable[,c(1:6)], y=valuetable$VCF,
                        importance = TRUE)

# Predict tree cover using the RF model
predTC_RF <- predict(GewataStack, model=modelRF, na.rm=TRUE)

# Correct tree cover values which smaller than 0 and larger than 100
predTC_RF_correct  <- Correct_TC(predTC_RF)

# Linear regression model
modelLM = lm("VCF~Band1 + Band2 + Band3 + Band4 + Band5 + Band7", data = valuetable)
# Predict tree cover using the lm model
predTC_lm <- predict(GewataStack, model = modelLM)
# Correct tree cover values which smaller than 0 and larger than 100
predTC_lm_correct  <- Correct_TC(predTC_lm)

# Visualize the two predictions as maps
png(filename="output/Gewata_RandomForest_prediction.png", width=800, height=500)
par(mfrow=c(1,2))
plot(predTC_RF_correct, legend=TRUE, main='Random Forest', font.main=2)
plot(predTC_lm_correct, legend=TRUE, main='Linear Regression', font.main=2)
mtext(text = 'Tree Cover Prediction of Gewata', side = 3, line=-2, outer=TRUE, cex=2, font = 1)
dev.off()

##  Tasks 2 & 3: Identify Landsat bands that have high influence in the tree cover prediction 
#             and compare the results of two models by creating a difference prediction raster ##

# Identify three most important explanatory variables (bands) for tree cover prediction using Random Forest regression
varModelRF <- varImpPlot(modelRF)
varModelRF_order <- rownames(varModelRF)[order(varModelRF[,'%IncMSE'], decreasing = TRUE)]
varModelRF_Imp <- varModelRF_order[1:3]
# Write results to csv file
write.csv(varModelRF_Imp, file = "output/important_bands.csv")

#compare and the results of the prediction models
# Substract prediction raster
predRasterDiff <- predTC_RF_correct - predTC_lm_correct

#Visualize
png(filename="output/Gewata_Prediction_Difference.png", width=800, height=500)
plot(predRasterDiff, legend=TRUE, main='Difference Between Random Forest Regression and Linear Regression Prediction', font.main=2)
dev.off()

#Task 4: Compare the results of the two models for different land cover classes
# Calculate average tree cover percent for each land cover class
LC_zonalpercentRF <- calc_TreeCover_byLandCover(classPoly, predTC_RF_correct)
LC_zonalpercentLM <- calc_TreeCover_byLandCover(classPoly, predTC_RF_correct)

#Visualize
png(filename="output/TreeCoverPercentage.png", width=800, height=500)
par(mfrow=c(1,2))
cols <- c('yellow', 'dark green', 'blue')
barplot(LC_zonalpercentRF, main='Random Forest Prediction', font.main=1, col = cols)
barplot(LC_zonalpercentLM, main='Linear Regression Prediction', font.main=1, col = cols)
mtext(text = 'Average Tree Cover Percent for Each Landcover Class ', side = 1, line=-2, outer=TRUE, cex=2, font = 2)
dev.off()
