#!/bin/bash

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/../.env"

# API endpoint URL
update_url=$API_URL"savefile"

# Check if the file argument is provided
if [ $# -eq 0 ]; then
    echo "Please provide a file as an argument"
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

# Check if the response contains the file_name
if [[ $file_name == "" ]]; then
    echo "Failed to update $file"
    # Print the response if shorter than 5 lines
    if [ "$(echo "$response" | wc -l)" -le 5 ]; then
        echo "$response"
    else
        # Otherwise print the HTTP status code
        ./../http_codes.sh "$http_code"
    fi
    exit 1
fi

# Print the file_name
echo "Successfully updated savefile with ID = $id_savefile named locally $file_name"
