#!/bin/bash

# Prompt the user for backup or restore operation
echo "Choose an operation:"
echo "1. Backup"
echo "2. Restore"
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" == "1" ]; then
    # Backup operation
    read -p "Enter MySQL username: " username
    read -sp "Enter MySQL password: " password
    echo
    read -p "Enter backup file name: " backup_file

    # Perform backup
    mysqldump -u "$username" -p"$password" --all-databases > "$backup_file"

    echo "Backup completed successfully!"

elif [ "$choice" == "2" ]; then
    # Restore operation
    read -p "Enter MySQL username: " username
    read -sp "Enter MySQL password: " password
    echo
    read -p "Enter backup file name: " backup_file

    # Perform restore
    mysql -u "$username" -p"$password" < "$backup_file"

    echo "Restore completed successfully!"

else
    echo "Invalid choice. Exiting..."
    exit 1
fi
