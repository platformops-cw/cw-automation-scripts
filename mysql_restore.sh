#!/bin/bash

# Purpose: To Rebuild MySQL index
# Author: Anas Moiz Hashmi from Cloudways


echo -e "Start Restoring Databases"

echo -e "\nCheck MySQL status"
/etc/init.d/mysql  status

read -r -p "If MySQL is running press Y else N  [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]

then

#   ******************************************************************************************************************
#   ********************************************** DATABASE DUMP *****************************************************
#   ******************************************************************************************************************

databases=`mysql -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

echo -e "Start Dumping Databases\n"

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
	mysqldump  --databases $db > $db.sql
    fi
done

#   ******************************************************************************************************************
#   ********************************************** STOPPING SERVICES *************************************************
#   ******************************************************************************************************************

echo -e "\nStopping Monit"
/etc/init.d/monit  stop

echo -e "\nStopping MySQL"
/etc/init.d/mysql  stop

#   ******************************************************************************************************************
#   ********************************************** REMOVING DATABASES ************************************************
#   ******************************************************************************************************************

echo -e "\nRemoving ibdata files"
rm /var/lib/mysql/ib*
ls /var/lib/mysql

#databases=`ls |   grep .sql  | cut -d'.' -f1`

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Deleting database: $db"
        rm -rf /var/lib/mysql/$db
    fi
done

ls /var/lib/mysql
#   ******************************************************************************************************************
#   ********************************************** STARTING SERVICES *************************************************
#   ******************************************************************************************************************

echo -n "[mysqld]" > /etc/mysql/conf.d/custom.cnf

echo -e "\nStarting MySQL"
/etc/init.d/mysql  start

echo -e "\nStarting Monit"
/etc/init.d/monit  start


#   ******************************************************************************************************************
#   ********************************************** CREATING DATABASES ************************************************
#   ******************************************************************************************************************

echo -e "\nCreating Application's Databases:"

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Creating database: $db"
        mysql -e "CREATE DATABASE $db;"
    fi
done

#   ******************************************************************************************************************
#   ********************************************** IMPORTING DATABASES ***********************************************
#   ******************************************************************************************************************

echo -e "\nStart Importing Databases"

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Importing database: $db"
        mysql $db < $db.sql
    fi
done


echo -e "\nDatabase Restored Successfully"


else

echo -e "\nOperation Cancelled"
fi


