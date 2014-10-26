################## run_analysis.R ##############################################################
### script for                                            ######################################
### Course Project Coursera "Getting and Cleaning Data    ######################################
################################################################################################

# create a directory on your system for the project.
# Let MyPath direct to that directory
MyPath = "~/03_Getting_and_Cleaning_DATA/Course_Project/REPO_Project"  ## <<< NEED TO CHANGE LOCAL

# set working directory of R to that directory
setwd(MyPath)

# directory names for versions of the data (directories will bee created by the script)
RawDataDir = "1_Data_RAW"
MergeDataDir = "2_Data_MERGE"
FlatDataDir = "3_Data_FLAT"
TidyDataDir = "4_Data_TIDY"

###############################################################################################
# RawDataDir = "1_Data_RAW"     ###############################################################
###############################################################################################
# Downloading zip file from internet.
# Unzip it in that directory
##############################################################################################

## make directory for Raw data (if nessessary)
ifelse(file.exists(RawDataDir), "is er al",dir.create(RawDataDir))
MyRaw = paste(MyPath, "/", RawDataDir, sep="")

## get datafile from internet put it in directory RawDataDir name it "RAW_Dataset.zip"
setwd(MyRaw)
download.file(
   "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
   "RAW_Dataset.zip")

## extracting zip file in directory RawDataDir
unzip("RAW_Dataset.zip", unzip = "internal" )
setwd(MyPath)

#####################################################################################################
# MergeDataDir = "2_Data_MERGE"     #################################################################
#####################################################################################################
# Merging the test and train data from the RAW data in one directory without subdir's           
# In merged file subject_.txt added a second column test_OR_train with values "test" or "train"
#####################################################################################################

## Unzipping did create an extra directory level, incorporate it in MyRaw
MyRaw = paste(MyPath, "/", RawDataDir, sep="")
MyRaw =  paste(MyRaw, "/UCI HAR Dataset",sep="")
## two other shorthands
MyTest = paste(MyRaw, "/test", sep="")
MyTrain = paste(MyRaw, "/train", sep="")

## create a directory for the merging of test and train RAW data
setwd(MyPath)
ifelse(file.exists(MergeDataDir),"is er al",dir.create(MergeDataDir))
MyMergeData = paste(MyPath, "/", MergeDataDir, sep="")

## copy .txt files from MyRaw to MyMergeData dir
setwd(MyRaw)
for(item in dir(MyRaw) ) {
   if( substring( item, nchar(item)-3, nchar(item) ) == ".txt"  ) {
      readLines(item) -> DV
      writeLines(DV,paste(MyMergeData, "/", item, sep=""))
   }
}


## Combine "subject_test.txt" with "subject_train.txt" to "subject_.txt"
## NO HEADER IN THESE FILES
## but first add a column test_OR_train indicating if the person is used for tests of training
file_1= paste(MyTest, "/", "subject_test.txt", sep="")
readLines(file_1)    -> DV1
paste(DV1, "test")   -> DV1  # Gets test with a space before it at the end
# paste(DV1[1], "test_OR_train") -> DV1[1]   NO HEADER IN THIS FILE
#
file_2= paste(MyTrain, "/", "subject_train.txt", sep="")
readLines(file_2)    -> DV2
paste(DV2, "train")  -> DV2
# paste(DV2[1], "test_OR_train") -> DV1[1]
#
c(DV1, DV2) -> DV1
file_out= paste(MyMergeData, "/","subject_.txt", sep="")
writeLines(DV1, file_out)

## Combine "X_test.txt" with "X_train.txt" to "X.txt"
file_1= paste(MyTest, "/", "X_test.txt", sep="")
file_2= paste(MyTrain, "/", "X_train.txt", sep="")
file_out= paste(MyMergeData, "/","X_.txt", sep="")
readLines(file_1) -> DV1
readLines(file_2) -> DV2
c(DV1, DV2) -> DV1
writeLines(DV1, file_out)

## Combine "y_test.txt" with "y_train.txt" to "y.txt"
file_1= paste(MyTest, "/", "y_test.txt", sep="")
file_2= paste(MyTrain, "/", "y_train.txt", sep="")
file_out= paste(MyMergeData, "/","y_.txt", sep="")
readLines(file_1) -> DV1
readLines(file_2) -> DV2
c(DV1, DV2) -> DV1
writeLines(DV1, file_out)

## same way one should create a dir "Inertial Signals" 
## and combine files from "test/Inertial Signals" with those in "train/Inertial Signals"

#####################################################################################################
# FlatDataDir = "3_Data_FLAT"     ###################################################################
#####################################################################################################
# Of the measurements and calculations in X_.txt only the columns with:
#    "mean()" or "std() in the name are preserved.
# the activity numbers 1 to 6 are replaced with labels indicating the activity.
# The data is combined in one big table file called total
#####################################################################################################

# Let MyPath direct to that directory
setwd(MyPath)
ifelse(file.exists(FlatDataDir), "already there", dir.create(FlatDataDir))
MyFlatData=paste(MyPath, "/", FlatDataDir, sep="")          # the output directory
MyMergeData = paste(MyPath, "/", MergeDataDir, sep="")      # the input directory


## Put measure/calculation data in a data.frame to allow manipulation
read.table(paste(MyMergeData, "/", "X_.txt", sep=""))           -> dataBlock
read.table(paste(MyMergeData, "/", "features.txt", sep=""))    -> headerBlock
## put colnames above
as.character(headerBlock$V2)  ->    headerBlock$V2
headerBlock$V2                ->    names(dataBlock)

## only interested in columnnames with "mean()" or "std()" in it
(gsub("(mean[/(][/)]|std[/(][/)])", "", headerBlock$V2) != headerBlock$V2)  -> logVector
logVector * 1:length(headerBlock$V2)               -> NR_and_ZERO
na.omit(ifelse(NR_and_ZERO==0,NA,NR_and_ZERO))    -> ColumnNR
## Only columns of interest
dataBlock[, ColumnNR] -> dataBlock
#ncol(dataBlock)
#head(dataBlock,3)

## make a nice activity column, with selfexplaining labels instead of numbers 1 to 6
read.table(paste(MyMergeData, "/", "y_.txt", sep=""))           -> activity
"activity" -> names(activity)[1]
# head(activity)
##  change numbers to labels "1" etc
as.factor(activity$activity) ->  activity$activity
## next step change label "1" to "WALKING" according to activitky_labels.txt
read.table(paste(MyMergeData, "/", "activity_labels.txt", sep="")) -> Activity_NR_Words
# head(Activity_NR_Words)
Activity_NR_Words[,"V2"] -> levels(activity$activity)

## make a nice person column with person numbers and "test_OR_train" column
read.table(paste(MyMergeData, "/", "subject_.txt",sep=""))     -> person
c("person", "test_OR_train")       ->    names(person)

### Take three parts together
cbind(person, activity, dataBlock)     -> Total
#head(Total,3)

### write the data.frame back to disk file "total.txt"
paste(MyFlatData, "/", "total.txt", sep="") -> fileOut
write.table(Total, fileOut, row.names = FALSE)
#read.table(fileOut,header=TRUE) -> test ; tail(test,3)


#####################################################################################################
# TidyDataDir = "4_Data_TIDY"     ###################################################################
#####################################################################################################
# In the flat table we create an extra column "Count_Person_Activity" 
#  indicating how many rows with that person and activity combination are there in the table
# We perform a group by on columns person, Count_Person_Activity, activity of the big flattable
# On the other columns there is a group average performed

# to make group by easier
#install.packages("data.table")
#install.packages("plyr")
library(data.table)
library(plyr)

## make in MyPath a subdirectory "DataDir_TIDY"
# Let MyPath direct to that directory
setwd(MyPath)
ifelse(file.exists(TidyDataDir),"already there",dir.create(TidyDataDir))
MyTidyData=paste(MyPath, "/", TidyDataDir, sep="")       # output directory
MyFlatData = paste(MyPath, "/", FlatDataDir, sep="")      # the input directory

## start with file "Total_txt" in directory FlatDataDir
inFile = paste(MyFlatData, "/", "total.txt", sep="") 
read.table(inFile, header=TRUE) -> total
data.table(total) -> total
# class(total)
# head(total,3)

## add a column with count of group on person, activity
total[, count_person_activity:=1 ]
total[, count_person_activity:=sum(count_person_activity),by=list(person,activity)]
#head(total,3);tail(total,3)
#total$count_person_activity

## reduce to 1 row for each person activity combination
data.frame(total) -> total
#class(total)
ddply(total, .(person, test_OR_train, activity ), function (ddf) colMeans(ddf[,4:ncol(ddf)])) -> total
#head(total,3);tail(total,3)
# write file
write.table(total,paste(MyTidyData, "/", "tidy_data.txt", sep=""), row.names=FALSE)

print("**************************************************************************")
print("***************** SCRIPT is READY ****************************************")
print("**************************************************************************")


