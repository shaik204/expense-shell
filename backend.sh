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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabled default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enable nodejs 20 " 

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installed nodejs "

id expense &>>$LOG_FILE
if [ $? -ne 0 ]; then
    echo -e "expense user doesnt exist...$G creating $N" | tee -a $LOG_FILE
    useradd expense &>>$LOG_FILE
    VALIDATE $? "creating expense user"
else
    echo -e "expense user already exists ...$Y skipping $N" | tee -a $LOG_FILE
fi   

mkdir -p /app
VALIDATE $? "creating /app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "downloading backend app code using curl command" 

cd /app
rm -rf /app/*     # remove the existing code
VALIDATE $? "removing old application files"

unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Extracting backend application code" 

npm install &>>$LOG_FILE 

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing MYSQL client"

mysql -h mysql.dreamsdelight.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "schema loading is success"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon reload"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "enabled backend"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "restarted backend"