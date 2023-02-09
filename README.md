---
title: '**Course Project - Getting and Cleaning HAR Data**'
author: '**Douglas Martins**'
output: html_document
---
## **Readme Documentation**

This document details the process taken to extract, merge, reformat, and clean a series of [measurement data]( https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)  from a [**Human Activity Recognition**](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) study conducted by **UC Irvine**.

The **"run_analysis.R"** script is runs in the same directory as the folder containing the raw data, in order that **read.table** functions can read the required files.

The raw data is contained in a number of .txt files located within the project root directory and its subdirectories. The relevant .txt files for the analysis are loaded to the enviroment using R's **read.table** function to create raw data.frame objects.
<br/><br/>

#### **Reading the .txt files**
```{r}
table <- read.table("path_to_file")
```

The raw data goes into the following data.frame objects:

* **training_setX**,**test_setX** - Raw sensor data from the training/testing set of the study.
* **training_setY**,**test_setY** - Activities performed by subjects from the training/testing set
* **subject_test**,**subject_train** - Numbers corresponding to the 21/9 subjects from the training/test set. Rows correspond to ones in X and Y sets.
* **feature_labels** - Contains variable names corresponding to the columns found in **X_train** and **X_test**.

#### **Merges the training and the test sets to create one data set.**
Tables from the test and training set (**training_setX** and **test_setX**, **training_setY** and **test_setY**, **subject_test** and **subject_train**) were combined using **rbind** into **features_merged**, **activity_merged**, and **subject_merged**. 
```{r}
features_merged <- rbind(test_setX, training_setX)
activity_merged <- rbind(test_setY, training_setY)
subject_merged <- rbind(subject_test, subject_train)
```
The combined data is then merged horizontally to create a complete dataframe, **df**, that contains all sensor data with corresponding subjects and activities. Then columns names are assigned from the **feature_labels.txt** file.

```{r}
df <- cbind(subject_merged,activity_merged,features_merged)
colnames(df) <- c('subject','activity',feature_names$variable_name)
```
<br/><br/>

#### **Extracts only the measurements on the mean and standard deviation for each measurement. **
Columns containing mean value and standard deviation data **df** contain the words "**mean**" and "**std()**" in their variable names. Applying the function **grep** returns a true/false vector the can then be used to filter only the variables containing such words (in addition to required **subject** and **activity**)
```{r}
is_mean_std <- grepl('subject|activity|mean|std',colnames(df))
df_mean_std <- df[,is_mean_std] %>% mutate(activity=as.factor(activity))
```
<br/><br/>

#### **Uses descriptive activity names to name the activities in the data set**
The numbers in the **activity** variable are replaced with factors with activity labels as described in "**activity_labels.txt**" in the root folder
```{r}
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt") %>% rename(index=V1,variable_name=V2) %>%
  mutate(variable_name=tolower(variable_name))
levels(df_mean_std$activity) <- activity_labels$variable_name
```
<br/><br/>

#### **Appropriately labels the data set with descriptive variable names.**
A function is defined in order to replace common misconceptions about naming and labeling variables, such as preferably lower case, avoiding confusing abbreviations and underscore or white spaces.
```{r}
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
```

The new descriptive variable names provide more information and readability than the original variable names.

<br/><br/>

#### **Tidy data set with the average of each variable for each activity and each subject.**
In order to find the average value for every combination of **subject** and **activity**, we can simply apply a multiple dimension grouping and subsequent summary of all non-group variables with the following code:
```{r}
tidy_df <- df_mean_std %>% group_by(activity,subject) %>% summarise_all(mean)
colnames(tidy_df) <-  c('subject','activity',paste('average of ',colnames(tbl)[-(1:2)]))
```
<br/><br/>

#### **Exporting tidy_df**
**tidy_df** is written to disk as a txt file, "**tidy_df.txt**", with the **write.txt** function.
```{r}
write.table(tidy_df, file = "tidy_df.txt", row.name=FALSE)
```
