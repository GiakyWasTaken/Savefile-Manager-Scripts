#!/bin/bash

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/../.env"

# API endpoint URL
update_url=$API_URL"savefile"

# Check if the file argument is provided
if [ $# -eq 0 ]; then
    echo "Please provide a file, a savefile id and a timestamp as an argument"
    exit 1
fi

# Get the file path from the argument
file="$1"
shift

# Check if the file exists
if [ ! -f "$file" ]; then
    echo "File $file does not exist."
    exit 1
fi

# Get the savefile id from the argument
id_savefile="$1"
shift

# Check if the savefile id is provided and is a number
if [[ $id_savefile == "" ]]; then
    echo "Please provide a savefile id as an argument"
    exit 1
elif ! [[ $id_savefile =~ ^[0-9]+$ ]]; then
    echo "Savefile id must be a number."
    exit 1
fi

# Get the timestamp from the argument
update_timestamp="$1"
shift

# Check if the timestamp is provided
if [[ $update_timestamp == "" ]]; then
    update_timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
fi

# Check if the timestamp is in a valid format (Y-m-d H:i:s)
if ! [[ $update_timestamp =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
    echo "Timestamp must be in the format Y-m-d H:i:s."
    exit 1
fi

# Add the savefile id to the URL
update_url="$update_url/$id_savefile"

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --raw)
            raw_response=true
            shift
            ;;
        *)
            echo "Unknown option: $key"
            exit 1
            ;;
    esac
done

# Send update file request
response=$(curl -s -w "%{http_code}" -X POST \
    -H "Authorization: Bearer $API_TOKEN" \
    -F "_method=PUT" \
    -F "savefile=@$file" \
    -F "updated_at=$update_timestamp" \
    "$update_url")

# Separate the HTTP status code from the response
http_code=${response: -3}
response=${response::-3}

# Check if the --raw argument is provided
if [[ $raw_response == true ]]; then
    # Print the raw response
    echo "$response"

    # Check if the response contains the file_name to determine the exit code
    if [[ $response == *"file_name"* ]]; then
        exit 0
    else
        exit 1
    fi
fi

# Extract the file_name from the response
file_name=$(echo "$response" | grep -oP '(?<="file_name":")[^"]+')
file_path=$(echo "$response" | grep -oP '(?<="file_path":")[^"]+':1)

# Check if the response contains the file_name
if [[ $file_name == "" ]]; then
    echo "Failed to update $file"
    "$(dirname "${BASH_SOURCE[0]}")/../http_codes.sh" "$http_code"
    exit 1
fi

# Print the file_name
echo "Savefile with ID = $id_savefile locally \"$file_path$file_name\" updated"
