#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y+%m+%d+%H+%M+%s)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"
mkdir -p "$LOGS_FOLDER"


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
CHECK_ROOT(){
    if [ "$USERID" -ne 0 ]; then
        echo -e "$R Please run the script with root privileges $N" | tee -a $LOG_FILE
        exit 1
    fi       

}
 

 VALIDATE(){
    if [ $1 -ne 0 ]
    then
            echo -e "$R $2 is failed $N " | tee -a $LOG_FILE
            exit 1
    else        
            echo -e "$G $2 is success $N" | tee -a $LOG_FILE
    fi         


 }

echo -e "$G script started executing at : $(date)" | tee -a $LOG_FILE
CHECK_ROOT 

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installed nginx succeeded"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "enabling nginx"

systemctl start nginx  &>>$LOG_FILE
VALIDATE $? "starting nginx"
 
rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
VALIDATE $? "removing default website" 

#downloading frontend code
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "downloading frontend code"

#extracting frontend content
cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "extract frontend code"

cp /home/ec2-user/expense-shell/expense.config /etc/nginx/default.d/expense.conf
VALIDATE $? "copied expense config"

systemctl restart nginx

