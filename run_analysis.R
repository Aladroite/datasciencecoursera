## Reads data into R
testdata<- read.table("./samsungdata/UCI HAR Dataset/test/X_test.txt", header=FALSE)
testactivity<- read.table("./samsungdata/UCI HAR Dataset/test/y_test.txt", header=FALSE)
testsubjects<- read.table("./samsungdata/UCI HAR Dataset/test/subject_test.txt", header=FALSE)

trainsubjects<- read.table("./samsungdata/UCI HAR Dataset/train/subject_train.txt", header=FALSE)
trainactivity<- read.table("./samsungdata/UCI HAR Dataset/train/y_train.txt", header=FALSE)
traindata<- read.table("./samsungdata/UCI HAR Dataset/train/X_train.txt", header=FALSE)
featureslist<- read.table("./samsungdata/UCI HAR Dataset/features.txt", header=FALSE)
activitylabels<- read.table("./samsungdata/UCI HAR Dataset/activity_labels.txt", header=FALSE)

## Merges the training and the test sets to create one data set.
library(dplyr)
alldata<-bind_rows(testdata, traindata)
allactivity<- bind_rows(testactivity, trainactivity)
allsubjects<- bind_rows(testsubjects, trainsubjects)

## Extracts only the measurements on the mean and standard deviation
## for each measurement.
 featuresextract<-subset(featureslist, grepl("mean()|std()", featureslist$V2))
 nrow(featuresextract)
 featuresextractnums<- featuresextract$V1
 alldataextract<- select(alldata, featuresextractnums)

## Uses descriptive activity names to name the activities in the data set
  allactivity<- mutate(allactivity, activityname=
ifelse(allactivity$V1==1, "walking",
ifelse(allactivity$V1==2, "walking upstairs",
ifelse(allactivity$V1==3, "walking downstairs",
ifelse(allactivity$V1==4, "sitting", 
ifelse(allactivity$V1==5, "standing","laying"
))))))

## Appropriately labels the data set with descriptive variable names.
colnames(alldataextract)<- featuresextract$V2
colnames(allsubjects)<- "subject"
colnames (allactivity)<- c("activitynumber", "activityname")

## From the data set in step 4, creates a second, independent tidy data set 
## with the average of each variable for each activity and each subject.
combineddf<- bind_cols(allsubjects, allactivity, alldataextract)
combineddf<- select(combineddf, -activitynumber)
tidymeans<- aggregate(combineddf[3:81], list(subject=combineddf$subject, activityname=combineddf$activityname), mean)

