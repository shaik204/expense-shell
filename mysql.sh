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
      dnf install mysql-server -y
      VALIDATE $? "Installing mysql server"

        systemctl enable mysqld
        VALIDATE $? "enabled mysql server"

        systemctl start mysqld
        VALIDATE $? "started mysql server"
    mysql -h dreamsdelight.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        echo "MYSQL root password is not setup,setting now" &>>$LOG_FILE
        mysql_secure_installation --set-root-pass ExpenseApp@1
        VALIDATE $? "Setting up root password"
    else
        echo -e "MYSQL root password is already setup...$Y skipping $N " | tee -a $LOG_FILE
    fi  