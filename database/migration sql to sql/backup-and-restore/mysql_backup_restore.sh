#!/bin/bash

# Prompt the user for backup or restore operation
echo "Choose an operation:"
echo "1. Backup"
echo "2. Restore"
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" == "1" ]; then
    # Backup operation
    read -p "Enter MySQL username: " username

    # Read the MySQL password securely
    echo -n "Enter MySQL password: "
    read -s password
    echo

    read -p "Enter backup file name: " backup_file

    # Perform backup
    mysqldump -u "$username" --password="$password" --all-databases > "$backup_file"

    echo "Backup completed successfully!"

elif [ "$choice" == "2" ]; then
    # Restore operation
    read -p "Enter MySQL username: " username

    # Read the MySQL password securely
    echo -n "Enter MySQL password: "
    read -s password
    echo

    read -p "Enter backup file name: " backup_file

    # Perform restore excluding the 'mysql' database
    mysql -u "$username" --password="$password" -e "SET FOREIGN_KEY_CHECKS=0; SET UNIQUE_CHECKS=0; SET SQL_MODE='NO_AUTO_VALUE_ON_ZERO';" 

    for db in $(mysql -u "$username" --password="$password" -e "SHOW DATABASES;" | awk '{ if ($1 != "Database" && $1 != "information_schema" && $1 != "performance_schema" && $1 != "mysql" && $1 != "sys") print $1 }'); do
        echo "Restoring database: $db"
        mysql -u "$username" --password="$password" "$db" < "$backup_file"
    done

    echo "Restore completed successfully!"

else
    echo "Invalid choice. Exiting..."
    exit 1
fi
