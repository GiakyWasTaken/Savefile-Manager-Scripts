#!/bin/bash

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/../.env"

# Check if the savefile id argument is provided
if [ -z "$1" ]; then
    echo "Please provide the savefile ID as an argument"
    exit 1
fi
# Check if the savefile id is a number
if [[ ! $1 =~ ^[0-9]+$ ]]; then
    echo "Invalid savefile ID"
    exit 1
fi
# Save the savefile id
savefile_id=$1
shift

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

# API endpoint URL
savefile_show_url=$API_URL"savefile/"$savefile_id

# Send show savefiles request
response=$(curl -s -X GET \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$savefile_show_url")

# Remove backslashes from the response
response=${response//\\/}

# Check if the --raw option is specified
if [[ $raw_response == true ]]; then
    echo "$response"
    exit 0
fi

# Extract the name from the JSON
file_name=$(echo "$response" | grep -o '"file_name":"[^"]*"' | cut -d'"' -f4)
file_path=$(echo "$response" | grep -o '"file_path":"[^"]*"' | cut -d'"' -f4)

if [[ $file_name == "" ]]; then
    echo "Failed to get savefile"
    echo "$response"
    exit 1
fi

# Echo the name separated by a newline
echo "\"$file_path$file_name\""
