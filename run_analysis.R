library(tidyr)
library(dplyr)

training_setX <- read.table("UCI HAR Dataset/train/X_train.txt")
training_setY <- read.table("UCI HAR Dataset/train/y_train.txt")
test_setX <- read.table("UCI HAR Dataset/test/X_test.txt")
test_setY <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
feature_labels <- read.table("UCI HAR Dataset/features.txt") %>% rename(index=V1,variable_name=V2)

# 1. Merge Datasets

features_merged <- rbind(test_setX, training_setX)
activity_merged <- rbind(test_setY, training_setY)
subject_merged <- rbind(subject_test, subject_train)

df <- cbind(subject_merged,activity_merged,features_merged)
colnames(df) <- c('subject','activity',feature_names$variable_name)

# 2. Filter Mean/Stdev from all measurements

is_mean_std <- grepl('subject|activity|mean|std',colnames(df))
df_mean_std <- df[,is_mean_std] %>% mutate(activity=as.factor(activity))

# 3. Uses descriptive activity names to name the activities in the data set

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt") %>% rename(index=V1,variable_name=V2) %>%
  mutate(variable_name=tolower(variable_name))

levels(df_mean_std$activity) <- activity_labels$variable_name

# 4. Appropriately labels the data set with descriptive variable names. 

descriptive_names_function <- function(x) {
  # This function replaces unnecessary abbreviations, and adds readability 
  x <- gsub(pattern = '-',replacement = '',x,ignore.case = F)
  x <- gsub(pattern = 'tBody',replacement = ' time body ',x,ignore.case = F)
  x <- gsub(pattern = 'fBody',replacement = ' frequency body ',x,ignore.case = F)
  x <- gsub(pattern = 'tGravity',replacement = ' time gravity ',x,ignore.case = F)
  x <- gsub(pattern = 'fGravity',replacement = ' frequency gravity ',x,ignore.case = F)
  x <- gsub(pattern = 'Acc',replacement = ' acceleration ',x,ignore.case = F)
  x <- gsub(pattern = 'Gyro',replacement = ' gyroscope ',x,ignore.case = F)
  x <- gsub(pattern = 'Mag',replacement = ' magnitude ',x,ignore.case = F)
  x <- gsub(pattern = 'Jerk',replacement = ' jerk ',x,ignore.case = F)
  x <- gsub(pattern = 'mean\\(\\)',replacement = ' mean ',x,ignore.case = F)
  x <- gsub(pattern = 'std\\(\\)',replacement = ' standard deviation ',x,ignore.case = F)
  x <- gsub(pattern = 'meanFreq\\(\\)',replacement = ' frequency mean ',x,ignore.case = F)
  x <- gsub(pattern = '  +',replacement = ' ',x,ignore.case = F)
  x <- gsub(pattern = ' $|^ ',replacement = '',x,ignore.case = F)
  x <- tolower(x)
}

feature_labels <- data_frame(variable_name=colnames(df_mean_std)) %>% 
  mutate(variable_name=descriptive_names_function(variable_name))

colnames(df_mean_std) <- feature_labels$variable_name
colnames(df_mean_std)

# 5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

tbl <- df_mean_std %>% group_by(activity,subject) %>% summarise_all(mean) 
colnames(tbl) <-  c('subject','activity',paste('average of ',colnames(tbl)[-(1:2)]))












