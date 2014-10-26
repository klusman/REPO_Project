---
title: "CodeBook.md"
output: html_document
---
###For background information about the data
Read the informationfiles in this zip archive:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

It should bee acknowledged by referencing the following publication [1] 

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

###File tidy_data.txt
It is a space delimited file, including a header.
It can be easily read in R using the read.table-function.

###Columns
* **person**  
  A number in the range of 1 to 30 indicating the person who wore the smartphone
* **test_OR_train**  
  Was the person's dat used for testing or for training during the experiment.
* **activity**  
  One of the following labels:WALKING WALKING_UPSTAIRS WALKING_DOWNSTAIRS SITTING STANDING LAYING
  
  then there is a list of 66 features. (see original data discription)
  
* **tBodyAcc.mean...X**  
* **tBodyAcc.mean...Y**  

     ...  **This 66 features are averaged over**  
          
     ...     **all windows dealing with the same person and activity.**  
     
* **fBodyBodyGyroJerkMag.mean..**  
* **fBodyBodyGyroJerkMag.std..**  

* **count_person_activity**  
    How many windows were there with this person, activity combination.