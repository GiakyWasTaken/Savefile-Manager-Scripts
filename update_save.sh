#!/bin/bash

# Source the .env file
source .env

# API endpoint URL
update_url=$API_URL"savefile"

# Check if the file argument is provided
if [ $# -eq 0 ]; then
    echo "Please provide a file as an argument."
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
    echo "Please provide a game id as an argument."
    exit 1
elif ! [[ $id_savefile =~ ^[0-9]+$ ]]; then
    echo "Savefile ID must be a number."
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

# Send store file request
response=$(curl -s -X POST \
    -H "Authorization: Bearer $API_TOKEN" \
    -F "_method=PUT" \
    -F "savefile=@$file" \
    "$update_url")

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
else
    # Extract the file_name from the response
    file_name=$(echo "$response" | grep -oP '(?<="file_name":")[^"]+')

    # Check if the response contains the file_name
    if [[ $file_name == "" ]]; then
        echo "Failed to upload $file"
        echo "$response"
        exit 1
    fi

    # Print the file_name
    echo "Successfully uploaded $file_name"
fi
