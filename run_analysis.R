## Download the data and put the file in the data folder

if(!file.exists("./data")) {dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
download.file(fileUrl, destfile = "./data/Dataset.zip", method = "curl")

## Unzip the file

unzip(zipfile = "./data/Dataset.zip", exdir = "./data")

## Unzipped files are in folder UIC HAR Dataset.  Get the list of the files

path_rf <- file.path("./data", "UCI HAR Dataset")
files <- list.files(path_rf, recursive = TRUE)
files

## Output form step 3

## [1] "activity_labels.txt"                         
## [2] "features_info.txt"                           
## [3] "features.txt"                                
## [4] "README.txt"                                  
## [5] "test/Inertial Signals/body_acc_x_test.txt"   
## [6] "test/Inertial Signals/body_acc_y_test.txt"   
## [7] "test/Inertial Signals/body_acc_z_test.txt"   
## [8] "test/Inertial Signals/body_gyro_x_test.txt"  
## [9] "test/Inertial Signals/body_gyro_y_test.txt"  
## [10] "test/Inertial Signals/body_gyro_z_test.txt"  
## [11] "test/Inertial Signals/total_acc_x_test.txt"  
## [12] "test/Inertial Signals/total_acc_y_test.txt"  
## [13] "test/Inertial Signals/total_acc_z_test.txt"  
## [14] "test/subject_test.txt"                       
## [15] "test/X_test.txt"                             
## [16] "test/y_test.txt"                             
## [17] "train/Inertial Signals/body_acc_x_train.txt" 
## [18] "train/Inertial Signals/body_acc_y_train.txt" 
## [19] "train/Inertial Signals/body_acc_z_train.txt" 
## [20] "train/Inertial Signals/body_gyro_x_train.txt"
## [21] "train/Inertial Signals/body_gyro_y_train.txt"
## [22] "train/Inertial Signals/body_gyro_z_train.txt"
## [23] "train/Inertial Signals/total_acc_x_train.txt"
## [24] "train/Inertial Signals/total_acc_y_train.txt"
## [25] "train/Inertial Signals/total_acc_z_train.txt"
## [26] "train/subject_train.txt"                     
## [27] "train/X_train.txt"                           
## [28] "train/y_train.txt" 

##  Read the files
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"), 
                               header = FALSE)
dataSubjectTest <- read.table(file.path(path_rf, "test", "subject_test.txt"), 
                              header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "y_train.txt"), 
        header = FALSE)
dataActivityTest <- read.table(file.path(path_rf, "test", "y_test.txt"), 
                                header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "x_train.txt"), 
                                header = FALSE)
dataFeaturesTest <- read.table(file.path(path_rf, "test", "x_test.txt"), 
                                header = FALSE)

##  Review the properties of the variables
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataActivityTrain)
str(dataActivityTest)
str(dataFeaturesTrain)
str(dataFeaturesTest)

## 1.) Merge the training and the test sets to create one data set.

## Concatenate the data tables by row
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity <- rbind(dataActivityTrain, dataActivityTest)
dataFeatures <- rbind(dataFeaturesTrain, dataFeaturesTest)

## Set names to the variables
names(dataSubject) <- c("subject")
names(dataActivity) <- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"), head = FALSE)
names(dataFeatures) <- dataFeaturesNames$V2

## Merge columns to get the data frame for all data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

## 2.)  Extracts only the measurements on the mean and standard deviation for 
##      each measurement.

##  Subset name of Features by measurements on the mean and standard deviation
subdataFeaturesNames <- dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", 
        dataFeaturesNames$V2)]

##  Subset the data frame by selected names of Features
selectedNames <- c(as.character(subdataFeaturesNames), "subject", "activity")
Data <- subset(Data, select = selectedNames)

##  Verify the structures of the data frame
str(Data)


##  3.)  Uses descriptive activity names to name the activities in the data set

##  Read dsicriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"), 
        header = FALSE)

##  Assign approriate labels
dataActivity[, 1] <- activityLabels[dataActivity[, 1], 2]
names(dataActivity) <- "activity"

## Verify
head(dataActivity$activity, 30)

## 4.)  Appropriately labels the data set with descriptive variable names.

## Prefex t will be replaced by time
## Acc will be replaced by Accelerometer
## Gyro will be replaced by Gyroscope
## Prefex f will be replaced by frequency
## Mag will be replaced by Magnnitude
## BodyBody will be replaced by Body

names(Data) <- gsub("^t", "time", names(Data))
names(Data) <- gsub("^f", "frequency", names(Data))
names(Data) <- gsub("Acc", "Accelerometer", names(Data))
names(Data) <- gsub("Gyro", "Gyroscope", names(Data))
names(Data) <- gsub("Mag", "Magnitude", names(Data))
names(Data) <- gsub("BodyBody", "Body", names(Data))

## Verify
names(Data)

##  5.) From the data set in step 4, creates a second, independent tidy data 
##      set with the average of each variable for each activity and each subject.

library(plyr)
Data2 <- aggregate(. ~subject + activity, Data, mean)
Data2 <- Data2[order(Data2$subject, Data2$activity), ]
write.table(Data2, file = "tidydata.txt", row.names = FALSE)

