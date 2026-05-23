#!/bin/bash

# Prompt for user input
read -p "Enter a name for the export folder: " NAME

# TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
# FOLDER_NAME="${NAME}_${TIMESTAMP}"
FOLDER_NAME="${NAME}"

# Check if the folder already exists
if [ -d "$FOLDER_NAME" ]; then
    read -p "This folder already exists. Do you want to replace it? (y/n): " CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "cancelled."
        exit 1
    else
        rm -rf "$FOLDER_NAME"
        echo "Existing folder removed."
    fi
fi

# Create the new directory
mkdir -p "$FOLDER_NAME"

# Copy the desired files/directories
cp sibships "$FOLDER_NAME"
cp analysis "$FOLDER_NAME"
cp nf3_constants.p "$FOLDER_NAME"

# Confirm completion
echo "Files successfully copied to: $FOLDER_NAME"