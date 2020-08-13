# You should create one R script called run_analysis.R that does the following.
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.

library(dplyr)

# prepare for file download
filename <- "Coursera_Tidy.zip"
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#download dataset
download.file(fileURL, filename, method="curl")
unzip(filename)

path <- getwd()
#extract activity and feature names
activityLabels <- read.table(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))

features <- read.table(file.path(path, "UCI HAR Dataset/features.txt")
                       , col.names = c("classLabels", "featureName"))

# Read train dataset 
ID_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "ID")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$featureName)
y_train <- read.table("UCI HAR Dataset/train/Y_train.txt", col.names = "classLabels")
y_train_label <- left_join(y_train, activityLabels, by = "classLabels")

#combine into one set
tidy_train <- cbind(ID_train, y_train_label, x_train)
tidy_train <- select(tidy_train, -classLabels)

# Read test dataset 
ID_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "ID")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$featureName)
y_test <- read.table("UCI HAR Dataset/test/Y_test.txt", col.names = "classLabels")
y_test_label <- left_join(y_test, activityLabels, by = "classLabels")

#combine into one set
tidy_test <- cbind(ID_test, y_test_label, x_test)
tidy_test <- select(tidy_test, -classLabels)

#combine all data
alldata <- rbind(tidy_test,tidy_train)

#Pull out means and std only
avgstd <- select(alldata, contains ("mean"), contains("std"))
#reformat to factors for processing
avgstd$ID <- as.factor(alldata$ID)
avgstd$activityName <- as.factor(alldata$activityName)

#Creates a new data.frame that only has the means
avg <- avgstd %>%
  group_by(ID, activityName) %>% summarise_each(funs(mean))
#write to a text file
write.table(avg, file = "tidyavgs.txt", row.names = FALSE)

