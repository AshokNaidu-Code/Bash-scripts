#!/bin/bash
#Function to encrypt a file
encrypt_file() {
    read -p "Enter the file to encrypt: " INPUT_FILE
    read -p "Enter output encrypted file name: " OUTPUT_FILE
    openssl enc -aes-256-cbc -salt -in "$INPUT_FILE" -out "$OUTPUT_FILE" -k "$(prompt_passphrase)"
    echo "File '$INPUT_FILE' encrypted as '$OUTPUT_FILE'."
}

# Function to decrypt a file
decrypt_file() {
    read -p "Enter the encrypted file to decrypt: " INPUT_FILE
    read -p "Enter output decrypted file name: " OUTPUT_FILE
    openssl enc -aes-256-cbc -d -in "$INPUT_FILE" -out "$OUTPUT_FILE" -k "$(prompt_passphrase)"
    echo "File '$INPUT_FILE' decrypted as '$OUTPUT_FILE'."
}

# Function to prompt for passphrase
prompt_passphrase() {
    read -s -p "Enter passphrase: " PASSPHRASE
    echo "$PASSPHRASE"
}

# Main menu
while true; do
    echo -e "\nFile Encryption/Decryption Tool"
    echo "1. Encrypt File"
    echo "2. Decrypt File"
    echo "3. Exit"
    read -p "Choose an option: " OPTION

    case $OPTION in
        1) encrypt_file ;;
        2) decrypt_file ;;
        3) break ;;
        *) echo "Invalid option, try again." ;;
    esac
done

echo "File Encryption/Decryption Tool closed."

