#!/bin/bash

# Source the .env file
source .env

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --auto-update)
            auto_update=true
            shift
            ;;
        --ignore-existing)
            ignore_existing=true
            shift
            ;;
        --verbose|-v)
            verbose=true
            shift
            ;;
        *)
            echo "Unknown option: $key"
            exit 1
            ;;
    esac
done

# Counter variables
exit_code_0=0
exit_code_1=0
already_exists=0

### To-do: Add which directory to parse from argument

# Loop through each file and pass it as an argument to another script
for file in "$NDS_SAVES_PATH"/*; do
    # Call your other script and pass the file as an argument
    output=$(./upload_save.sh "$file")

    # Get the exit code of the previous command
    exit_code=$?

    # Check if the verbose argument is provided
    if [[ $verbose == true ]]; then
        echo "$output"
    fi

    # Check the exit code and increment the respective counter
    if [ $exit_code -eq 0 ]; then
        exit_code_0=$((exit_code_0 + 1))
    else
        # If the file already exists save the file name to an array
        if [[ $output == *"already exists"* ]]; then
            # Extract the file name from the path
            file=$(basename "$file")
            # Add the file name to the array
            existing_files+=("$file")
            # Increment the already_exists counter
            already_exists=$((already_exists + 1))
        fi
        exit_code_1=$((exit_code_1 + 1))
    fi
done

# Print the count of exit codes
echo "Files successfully uploaded: $exit_code_0"
echo "Files failed to upload: $exit_code_1"

# Check if the ignore-existing argument is provided or if there are no existing files
if [[ $ignore_existing == true || ${#existing_files[@]} -eq 0 ]]; then
    exit 0
fi

# Manage the already existing files
echo "Files that already exist: $already_exists"

# Check if auto-update argument is provided
if [[ $auto_update != true ]]; then
    # Ask the user if they want to update the already existing files
    read -r -p "Do you want to update the already existing files? (y/N): " update_existing
    # Check the user's response and perform the update if requested
    if [[ $update_existing == "y" || $update_existing == "Y" ]]; then
        auto_update=true
    else 
        # Exit the script if the user does not want to update the files
        exit 0
    fi
fi

### To-do: Add savefile ID to know which file to update

# Loop through each existing file and pass it as an argument to the update script
for existing_file in "${existing_files[@]}"; do
    # Call your update script and pass the file as an argument
    echo "Updating $existing_file"
    ./update_save.sh "$existing_file"
done
