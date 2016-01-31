library(plyr)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("data.zip")){
        download.file(url, "data.zip")
}

unzip("data.zip")
file.rename("UCI HAR Dataset", "data")

# 1. Merges the training and the test sets to create one data set.
mergedData <- rbind(read.table("./data/train/X_train.txt"),read.table("./data/test/X_test.txt"))
Label <- rbind(read.table("./data/train/y_train.txt"),read.table("./data/test/y_test.txt"))
Subject <- rbind(read.table("./data/train/subject_train.txt"),read.table("./data/test/subject_test.txt"))

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
features <- read.table("./data/features.txt")
reqfeatures <- grep("mean\\(\\){1}|std\\(\\){1}", features[,2])

# Make column name more readable
mergedData <- mergedData[, reqfeatures]
names(mergedData) <- features[reqfeatures, 2]
names(mergedData) <- gsub("\\(\\)","", names(mergedData))
names(mergedData) <- gsub("mean","Mean", names(mergedData))
names(mergedData) <- gsub("std","Standard", names(mergedData))
names(mergedData) <- gsub("-","", names(mergedData))

# 3. Uses descriptive activity names to name the activities in the data set
activities <- read.table("./data/activity_labels.txt")
activityLabel <- activities[Label[,1], 2]
Label[,1] <- activityLabel
names(Label) <- "activity"

# 4. Appropriately labels the data set with descriptive variable names. 
names(Subject) <- "subject"
finaldata <- cbind(Subject, Label, mergedData)

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
finalDataSet <- ddply(finaldata, .(subject, activity), function(x) colMeans(x[, -c(1,2)]))
write.table(finalDataSet, "finalData.txt", sep = "\t", row.name=FALSE)
