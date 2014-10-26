---
title: "README.md"
author: "joop klusman"
date: "Sunday, October 26, 2014"
output: html_document
---
#Getting and Cleaning Data
#Course Project

-----------
###What is it all about?
It is a training excercise in data handling for the coursera course "Getting and Cleaning Data" given by Jeff Leek at Johns Hopkins.

###Where did the RAW-data come from?
The data was downloaded from URL:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

It should bee acknowledged by referencing the following publication [1] 

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.

Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.

###What is this data about?
The Accelerometer and the gyroscope in a smartphone measure the acceleration and angular velocity in the X,Y and Z direction. So there are six values denoted as Acc-X, Acc-Y, Acc-Z and Gyro-X, Gyro_Y,  Gyro_Z being emitted at a frequency of 50Hz.
To get a timeserie of 128 values for each signal we have to measure 2,56 seconds. We call it a (time) window. These 6 timeseries of a time-window are long enough to be the basis of 561 calculated statistical features.

There were 30 persons doing 6 predefined activities. The recordings where divided in windows of 2.56 seconds and labelled with the person's number and the activity number. The 6 time series of each window were transformed in 561 feature values.

The original data is divided in two parts "test" and "train" having exactly the same data structure. The reason is the group of 30 persons was divided in "test" and "train". I presume the data of the "train persons" was used to build a system to recognize "activities" by analyzing a given "window" of someone of the "test group".

(The original data has a more detailed description)

##Steps processing the RAW data
All steps are done by the script run_analysis.R Each step creates a directory under the R working  directory, for it's intermediate result. The script begins with the setting of the working directory and by assigning the directory names.
```
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

```
###1 Obtaining the RAW-data
There is first a zip-file downloaded from the internet.  
And that file is un-zipped using the normal program already installed on your local machine hopefully.
```
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

```
###2 Merging the data of the "test" and "train" persons
There is no more need for subdirectories "test" and "train"
We added to the table in subject_train.txt a second column containing "train" for all rows.
And Added to subject_test.txt a second column containing "test" for all rows.
(By doing so it is possible to split afterwards in test and train data.)
The "train" and "test" versions off the file can be appended.
subject_train.txt + subject_test.txt  -> subject_.txt
X_train.txt       + X_test.txt        -> X_.txt
y_train.txt       + y_test.txt        -> y_.txt
The other files like README.txt, features.txt etc. only needed copied.
```
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

```
###3 Joining tables, and less features in one big "flat-table"
We are only interested in mean and standard deviation info off the features.
In the header of the 561 column's they have "mean()" or "std()" in the string.
This gives a method to select the columns needed from X_.txt
y\_.txt gives the activity number-column to be placed before table X\_.txt
We have changed that number in the description (label) according activity_labels.txt
See the R-code for the details.
```

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

```
###4 Averaging over same person doing same activity
In the big flat table "total.txt" created in step 3 a row describes a specific window. We want now an average on same person doing same activity. In SQL "group by person, activity".
We added a column "count_person_activity" giving the amount of windows the average is based on.
In the script packages "data.table" and "plyr" are used.
If not installed run:  install.packages("data.table") ; install.packages("plyr")
first.
```
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
head(total,3);tail(total,3)
# write file
write.table(total,paste(MyTidyData, "/", "tidy_data.txt", sep=""), row.names=FALSE)

print("**************************************************************************")
print("***************** SCRIPT is READY ****************************************")
print("**************************************************************************")

```
