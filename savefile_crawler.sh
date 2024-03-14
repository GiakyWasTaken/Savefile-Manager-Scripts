#!/bin/bash

# Source the .env file
source .env

# Counter variables
exit_code_0=0
exit_code_1=0

# To-do: Add which directory to parse from argument

# Loop through each file and pass it as an argument to another script
for file in "$NDS_SAVES_PATH"/*; do
    # Call your other script and pass the file as an argument
    ./upload_saves.sh "$file"

    # Get the exit code of the previous command
    exit_code=$?

    # Check the exit code and increment the respective counter
    if [ $exit_code -eq 0 ]; then
        exit_code_0=$((exit_code_0 + 1))
    else
        exit_code_1=$((exit_code_1 + 1))
    fi
done

# Print the count of exit codes
echo "Files successfully uploaded: $exit_code_0"
echo "Files failed to upload: $exit_code_1"