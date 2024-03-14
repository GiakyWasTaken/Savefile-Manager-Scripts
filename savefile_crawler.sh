#!/bin/bash

# Source the .env file
source .env

# Parse the directory where the crawler will look for savefiles from argument
crawling_dir="$1"
shift

# Check if the directory is provided
if [ -z "$crawling_dir" ]; then
    echo "No directory provided"
    exit 1
fi
# Check if the directory exists
if [ ! -d "$crawling_dir" ]; then
    echo "Directory $crawling_dir does not exist"
    exit 1
fi

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

### To-do: Remove hardcoded game_id and dir, and get it from the game name or folder, maybe?
game_id=1
crawling_dir=$NDS_SAVES_PATH

# Loop through each file and pass it as an argument to another script
for file in "$crawling_dir"/*; do
    # Call your other script and pass the file as an argument
    output=$(./Save_Scripts/store_save.sh "$file" "$game_id")

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
            # Add the file name to the array
            existing_files+=("$file")
            # Increment the already_exists counter
            already_exists=$((already_exists + 1))
        fi
        exit_code_1=$((exit_code_1 + 1))
    fi
done

# Print the count of exit codes
echo "Files successfully uploaded: $exit_code_0 / $((exit_code_0 + exit_code_1))"
echo "Files failed to upload: $exit_code_1 / $((exit_code_0 + exit_code_1))"
echo "Files that already exist: $already_exists / $exit_code_1"

# Check if the ignore-existing argument is provided or if there are no existing files
if [[ $ignore_existing == true || ${#existing_files[@]} -eq 0 ]]; then
    exit 0
fi

# Manage the already existing files

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
else
    echo "Auto-updating already existing files..."
fi

# Reset the counters
exit_code_0=0
exit_code_1=0

# Loop through each existing file and pass it as an argument to the update script
for existing_file in "${existing_files[@]}"; do
    # Extract the savefile name from the file path
    savefile_name=$(basename "$existing_file") 

    # Use the savefile name to get the savefile ID
    savefile_id=$(./Save_Scripts/get_save_id.sh "$savefile_name" $game_id)

    if [[ $verbose == true ]]; then
        echo "Updating $savefile_name with ID $savefile_id"
    fi

    # Call your update script and pass the file as an argument
    output=$(./Save_Scripts/update_save.sh "$existing_file" "$savefile_id")

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
        exit_code_1=$((exit_code_1 + 1))
    fi
done

# Print the count of exit codes
echo "Files successfully updated: $exit_code_0 / $((exit_code_0 + exit_code_1))"
echo "Files failed to update: $exit_code_1 / $((exit_code_0 + exit_code_1))"
