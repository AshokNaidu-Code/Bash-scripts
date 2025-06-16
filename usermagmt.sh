#!/bin/bash
#Log file
LOG_FILE="/var/log/user_management.log"

# Function to add a new user
add_user() {
    read -p "Enter new username: " USERNAME
    sudo useradd -m "$USERNAME"
    sudo passwd "$USERNAME"
    echo "$(date) - User $USERNAME added." | tee -a "$LOG_FILE"
}

# Function to modify an existing user
modify_user() {
    read -p "Enter current username: " CURRENT_USER
    read -p "Enter new username: " NEW_USER
    sudo usermod -l "$NEW_USER" "$CURRENT_USER"
    echo "$(date) - User $CURRENT_USER renamed to $NEW_USER." | tee -a "$LOG_FILE"
}

# Function to delete a user
delete_user() {
    read -p "Enter username to delete: " USERNAME
    sudo userdel -r "$USERNAME"
    echo "$(date) - User $USERNAME deleted." | tee -a "$LOG_FILE"
}

# Function to set password policies
set_password_policy() {
    echo "Setting password policy..."
    sudo sed -i 's/PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs
    sudo sed -i 's/PASS_MIN_DAYS.*/PASS_MIN_DAYS 7/' /etc/login.defs
    sudo sed -i 's/PASS_WARN_AGE.*/PASS_WARN_AGE 14/' /etc/login.defs
    echo "$(date) - Password policy updated." | tee -a "$LOG_FILE"
}

# Function to manage user permissions (add/remove sudo)
manage_permissions() {
    read -p "Enter username to modify permissions: " USERNAME
    read -p "Grant sudo privileges? (yes/no): " RESPONSE

    if [[ "$RESPONSE" == "yes" ]]; then
        sudo usermod -aG sudo "$USERNAME"
        echo "$(date) - Sudo permissions granted to $USERNAME." | tee -a "$LOG_FILE"
    else
        sudo deluser "$USERNAME" sudo
        echo "$(date) - Sudo permissions revoked for $USERNAME." | tee -a "$LOG_FILE"
    fi
}

# Main menu
while true; do
    echo -e "\nUser Account Management Tool"
    echo "1. Add User"
    echo "2. Modify User"
    echo "3. Delete User"
    echo "4. Set Password Policies"
    echo "5. Manage Permissions"
    echo "6. Exit"
    read -p "Choose an option: " OPTION

    case $OPTION in
        1) add_user ;;
        2) modify_user ;;
        3) delete_user ;;
        4) set_password_policy ;;
        5) manage_permissions ;;
        6) break ;;
        *) echo "Invalid option, try again." ;;
    esac
done

echo "User Account Management Tool closed."

