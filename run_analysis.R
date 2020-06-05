#setwd("~/r_scripts/getting_and_cleaning")

##read in all data files from the working directory 
trainingdata <- read.table("./UCI HAR Dataset/train/X_train.txt")
labelstraining<- read.table("./UCI HAR Dataset/train/y_train.txt")
varnames<- read.table("./UCI HAR Dataset/features.txt")
testdata<-read.table("./UCI HAR Dataset/test/X_test.txt")
labelstest<-read.table("./UCI HAR Dataset/test/y_test.txt")
activitylabels<-read.table("./UCI HAR Dataset/activity_labels.txt")

subjecttrain<- read.table("./UCI HAR Dataset/train/Subject_train.txt")
subjecttest<- read.table("./UCI HAR Dataset/test/Subject_test.txt")



##merge the training and test data in one file
mergedData<-merge(trainingdata, testdata, all=TRUE)

##add names to the variables
summary(varnames)
##since there are some repeating variable names, we paste unique id to the name to make the names unique
varnamesp<-paste(varnames[,1], varnames[,2])
colnames(mergedData)<- varnamesp


##merge activity labels training to test 
labelsall<-rbind(labelstraining, labelstest)
##add id
labelsall<-cbind(c(1:10299),labelsall)
#merge the labels
labelsall<-merge(labelsall, activitylabels, by.x = "V1", by.y = "V1")
#rename columns
colnames(labelsall)<-c("activity","id","activitylabel")
labelsall<-arrange(labelsall, id)

#merge the activities to the result data
mergedData<-cbind(labelsall, mergedData)

#merge the subject ids together
subjectall<-rbind(subjecttrain, subjecttest)
colnames(subjectall)<-"subjectID"
##merge the subject ID to the results data
mergedData<-cbind(subjectall, mergedData)



#Extracting only the measurements on the mean and standard deviation for each measurement.Standard deviations are at the end of the file.
library(dplyr)
merged_short<-select(mergedData, c("id","subjectID", contains("activity"), contains("mean"),contains("std")))
merged_short<-rename(merged_short, recordID=id)



#creating a data set with the average of each variable for each activity and each subject
library(reshape2)
#drop the variables that have different type, as those cannot be melted
premelt<-select(merged_short, -c("recordID","activitylabel"))
#melt the file
meltmerged<-melt(premelt, id=c("activity", "subjectID"))
#casting on activity and subject, aggregated by mean
averages<- dcast(meltmerged, activity + subjectID ~ variable, mean)

#merge the dropped activity labels back
averages<-merge( activitylabels, averages, by.x = "V1", by.y = "activity")
averages<-rename(averages, activity=V1, activitylabel=V2)
averages

write.table(averages, file="averages.csv", append=FALSE, row.names=FALSE)

