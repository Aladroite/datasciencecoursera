---
title: "CodeBook"
author: "A Lewis"
date: "September 14, 2018"
output: 
  html_document: 
    keep_md: yes
---


This code book describes the variables, the data, and any transformations or work performed to clean up the data. 

###Original Data
The original data is the Human Activity Recognition Using Smartphones Dataset, Version 1.0, that was published by Smartlab - Non Linear Complex Systems Laboratory. 

The data was collected from experiments conducted with a group of 30 volunteers (subjects) within an age bracket of 19-48 years. 

Per the Smartlab documentation, each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Various "features" were measured while each subject performed each activity. 

To create a tidy data subset, the data were processed as follows:

####Data Download

The data was downloaded from: "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
and read into R. 

```r
testdata<- read.table("./samsungdata/UCI HAR Dataset/test/X_test.txt", header=FALSE)
testactivity<- read.table("./samsungdata/UCI HAR Dataset/test/y_test.txt", header=FALSE)
testsubjects<- read.table("./samsungdata/UCI HAR Dataset/test/subject_test.txt", header=FALSE)

trainsubjects<- read.table("./samsungdata/UCI HAR Dataset/train/subject_train.txt", header=FALSE)
trainactivity<- read.table("./samsungdata/UCI HAR Dataset/train/y_train.txt", header=FALSE)
traindata<- read.table("./samsungdata/UCI HAR Dataset/train/X_train.txt", header=FALSE)
featureslist<- read.table("./samsungdata/UCI HAR Dataset/features.txt", header=FALSE)
activitylabels<- read.table("./samsungdata/UCI HAR Dataset/activity_labels.txt", header=FALSE)
```
#### Merged the training and the test sets to create one data set
The dplyr package was used to merge the data. The resulting datasets were:

1. alldata: the merged test and train datasets

2. allactivity: the merged test and train activity datasets

3. allsubjects: the merged test and train subject datasets

```r
library(dplyr)
alldata<-bind_rows(testdata, traindata)
allactivity<- bind_rows(testactivity, trainactivity)
allsubjects<- bind_rows(testsubjects, trainsubjects)
```
#### Extracts only the measurements on the mean and standard deviation for each measurement
The orignal data contained 561 features that were measured for each observation. These 561 features were subset to the 79 features that reported mean and standard deviation values. 
The resulting dataset was stored in the variable: alldataextract.
A full list of the measured features can be downloaded in the zip file linked above. 


```r
featuresextract<-subset(featureslist, grepl("mean()|std()", featureslist$V2))
nrow(featuresextract)
featuresextractnums<- featuresextract$V1
alldataextract<- select(alldata, featuresextractnums)
```
#### Uses descriptive activity names to name the activities in the data set
 In the original dataset, activities were described by coded numbers rather than by descriptive names. Thus, these numbers were translated to their corresponding activity names. 
 

```r
  allactivity<- mutate(allactivity, activityname=
ifelse(allactivity$V1==1, "walking",
ifelse(allactivity$V1==2, "walking upstairs",
ifelse(allactivity$V1==3, "walking downstairs",
ifelse(allactivity$V1==4, "sitting", 
ifelse(allactivity$V1==5, "standing","laying"
))))))
```
#### Appropriately labels the data set with descriptive variable names
The orignal datasets had no column names. Thus the columns were named "subject", "activitynumber" and "activityname" to more clearly describe those variables. The feature variable names from the original datasets were left unchanged. 

```r
colnames(alldataextract)<- featuresextract$V2
colnames(allsubjects)<- "subject"
colnames (allactivity)<- c("activitynumber", "activityname")
```
#### From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
Lastly, a final tidy data subset was created to show the average feature measurement for each activity for each subject. This data subset was stored in the variable "tidymeans".

```r
combineddf<- bind_cols(allsubjects, allactivity, alldataextract)
combineddf<- select(combineddf, -activitynumber)
tidymeans<- aggregate(combineddf[3:81], list(subject=combineddf$subject, activityname=combineddf$activityname), mean)
```
