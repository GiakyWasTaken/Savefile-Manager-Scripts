#!/bin/bash

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/../.env"

# API endpoint URL
store_url=$API_URL"savefile"

# Check if the file argument is provided
if [ $# -eq 0 ]; then
    echo "Please provide a file and relative console id or name as an argument."
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

# Check if the console id or name is provided
if [ -z "$1" ]; then
    echo "Please provide the console ID as an argument."
    exit 1
fi
# Check if the argument is an id or a name
if [[ $1 =~ ^[0-9]+$ ]]; then
    console_id="$1"
else
    # Get the console id from the console name
    console_id=$(./get_console_id.sh "$1")
    # Check if the console id is found
    if [ -z "$console_id" ]; then
        echo "Console name not found"
        exit 1
    fi
    console_name="$1"
fi
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

# Send store file request
response=$(curl -s -w "%{http_code}" -X POST \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    -F "savefile=@$file" \
    -F "fk_id_console=$console_id" \
    "$store_url")

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
    echo "Failed to upload $file"
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
if [ -n "$console_name" ]; then
    echo "Successfully uploaded $file_name with the console = $console_name"
else
    echo "Successfully uploaded $file_name with console ID = $console_id"
fi
