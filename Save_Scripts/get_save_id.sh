#!/bin/bash

# Check if the savefile path argument is provided
if [ -z "$1" ]; then
    echo "Please provide the savefile path as an argument"
    exit 1
fi

# Separate the file dir from the file name using the last / as a delimiter
file_path="${1%/*}/"
file_name="${1##*/}"

# Check if the console name or id argument is provided
if [ -z "$2" ]; then
    echo "Please provide the console name or ID as an argument"
    exit 1
fi
# Check if the console name or id is a number
if [[ $2 =~ ^[0-9]+$ ]]; then
    console_id_flag=true
fi

# Get the json file from a script that indexes all savefiles from the API
json_file=$(./index_saves.sh --raw)

# Check if index_saves.sh failed
if [[ $json_file == *"Failed"* ]]; then
    echo "Failed to get the index of savefiles"
    exit 1
fi

# Check if json_file is not null and is a valid JSON
if [ -z "$json_file" ] || ! (echo "$json_file" | jq . >/dev/null 2>&1); then
     echo "Invalid JSON or null value"
     exit 1
fi

## Requires jq to be installed
# Parse the JSON file and select the savefile ID for the provided savefile name
if [[ $console_id_flag == true ]]; then
    # Parse based on console id
    savefile_id=$(echo "$json_file" | jq -r --arg savefile_name "$file_name" --arg file_path "$file_path" --argjson console_id "$2" '.[] | select(.file_name == $savefile_name and .file_path == $file_path and .fk_id_console == $console_id) | .id')
else
    # Parse based on console name
    savefile_id=$(echo "$json_file" | jq -r --arg savefile_name "$file_name" --arg file_path "$file_path" --arg console_name "$2" '.[] | select(.file_name == $savefile_name and .file_path == $file_path and .console_name == $console_name) | .id')
fi

# Check if the savefile ID is found
if [ -z "$savefile_id" ]; then
    echo "Savefile not found"
    exit 1
fi

# Echo the savefile ID
echo "$savefile_id"