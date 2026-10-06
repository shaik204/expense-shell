#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y+%m+%d+%H+%M+%s)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"
mkdir -p "$LOGS_FOLDER"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:?Set MYSQL_ROOT_PASSWORD before running}"
MYSQL_HOST="${MYSQL_HOST:-mysql.example.com}"


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
   mysql -h ${MYSQL_HOST} -u root -p"${MYSQL_ROOT_PASSWORD}" -e 'show databases;' &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        echo "MYSQL root password is not setup,setting now" &>>$LOG_FILE
        mysql_secure_installation --set-root-pass "${MYSQL_ROOT_PASSWORD}"
        VALIDATE $? "Setting up root password"
    else
        echo -e "MYSQL root password is already setup...$Y skipping $N " | tee -a $LOG_FILE
    fi  


    

   
