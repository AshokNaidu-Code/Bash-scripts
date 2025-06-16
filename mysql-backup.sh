#!/bin/bash

# Configuration
DB_NAME="mysql"
DB_USER="root"
BACKUP_DIR="/var/backups/mysql"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_backup_${TIMESTAMP}.sql.gz"
LOG_FILE="/var/log/mysql_backup.log"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Function to backup MySQL
backup_mysql() {
    echo "Backing up MySQL database: $DB_NAME..."
    mysqldump -u "$DB_USER" -p "$DB_NAME" | gzip > "$BACKUP_FILE"
    echo "$(date) - Backup completed: $BACKUP_FILE" | tee -a "$LOG_FILE"
}

# Function to restore MySQL
restore_mysql() {
    read -p "Enter backup file to restore: " RESTORE_FILE
    echo "Restoring MySQL database from $RESTORE_FILE..."
    gunzip < "$RESTORE_FILE" | mysql -u "$DB_USER" -p "$DB_NAME"
    echo "$(date) - Restore completed from: $RESTORE_FILE" | tee -a "$LOG_FILE"
}

# Main menu
while true; do
    echo -e "\nMySQL Backup and Restore Tool"
    echo "1. Backup Database"
    echo "2. Restore Database"
    echo "3. Exit"
    read -p "Choose an option: " OPTION

    case $OPTION in
        1) backup_mysql ;;
        2) restore_mysql ;;
        3) break ;;
        *) echo "Invalid option, try again." ;;
    esac
done

echo "MySQL Backup and Restore Tool closed."
