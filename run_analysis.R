

# Step 1 - Download the archive file and set working directory

file_url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("UCI.zip")){download.file(file_url,"UCI.zip")}
unzip("UCI.zip",exdir = "Data")
src_file<-paste(getwd(),"/","Data",sep="")
list.files(src_file,recursive = TRUE)

#Step 2 - Extract required files to define variables
###UCI Har dataset files
act_lbs<-read.csv(paste(src_file,"/","UCI Har Dataset","/","activity_labels.txt",sep=""),header=FALSE,sep="",skipNul = TRUE)
ftrs<-read.csv(paste(src_file,"/","UCI Har Dataset","/","features.txt",sep=""),header=FALSE,sep="",skipNul = TRUE)
names(act_lbs)<-c("code","lbls")

###Test folder files
X_ts<-read.csv(paste(src_file,"/","UCI Har Dataset","/","test","/","X_test.txt",sep=""),header=FALSE,sep="",skipNul = TRUE)
Y_ts<-read.csv(paste(src_file,"/","UCI Har Dataset","/","test","/","Y_test.txt",sep=""),header=FALSE,sep="",skipNul = TRUE)
s_ts<-read.csv(paste(src_file,"/","UCI Har Dataset","/","test","/","subject_test.txt",sep=""),header=FALSE,sep="",skipNul = TRUE)
names(s_ts)<-"sub"
names(Y_ts)<-"code"
names(X_ts)<-ftrs$V2

###Train folder files
X_tr<-read.csv(paste(src_file,"/","UCI Har Dataset","/","train","/","X_train.txt",sep=""),header=FALSE,sep="",skipNul = TRUE)
Y_tr<-read.csv(paste(src_file,"/","UCI Har Dataset","/","train","/","Y_train.txt",sep=""),header=FALSE,sep="",skipNul = TRUE)
s_tr<-read.csv(paste(src_file,"/","UCI Har Dataset","/","train","/","subject_train.txt",sep=""),header=FALSE,sep="",skipNul = TRUE)
names(s_tr)<-"sub"
names(Y_tr)<-"code"
names(X_tr)<-ftrs$V2

#Step 3 - combine all files
###test files
lbs_ts<-merge(Y_ts,act_lbs,by="code",sort = F)
test_data<-cbind(lbs_ts,s_ts,X_ts,sort=F)
test_data$ID<-"test"

###train files
lbs_tr<-merge(Y_tr,act_lbs,by="code",sort = F)
train_data<-cbind(lbs_tr,s_tr,X_tr,sort=F)
train_data$ID<-"train"

###combine both data sets -all data
all_data<-rbind(test_data,train_data)



#Step 4 - creating a tidy data set
###assign descriptive names
names(all_data)<-gsub("^t", "time", names(all_data))
names(all_data)<-gsub("^f", "frequency", names(all_data))
names(all_data)<-gsub("Acc", "Accelerometer", names(all_data))
names(all_data)<-gsub("Gyro", "Gyroscope", names(all_data))
names(all_data)<-gsub("Mag", "Magnitude", names(all_data))
names(all_data)<-gsub("BodyBody", "Body", names(all_data))

###select only mean and std deviation variables for new data set
library(tidyr)
new<-all_data[,c(1:3,grep("mean",colnames(all_data)),grep("std",colnames(all_data)))]


#Step 5 - create a new data set 
###Criteria  - 
#+Average of each variable for each activity 
#+Average of each variable for each subject

final<-aggregate(.~sub+code+lbls,new,mean)
final<-final[order(final$lbls,final$sub),]

#Step 6 - load file as "codebook.Rmd"
library("knitr")
knit(codebook.Rmd")

