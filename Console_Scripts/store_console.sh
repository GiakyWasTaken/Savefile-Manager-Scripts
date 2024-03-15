#!/bin/bash

# Check if the name argument is provided
if [ $# -eq 0 ]; then
    echo "Please provide a name for the console"
    exit 1
fi

# Store the name argument in a variable
name=$1
shift

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
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

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/../.env"

# API endpoint URL
create_console_url=$API_URL"console"

# Send store console request
response=$(curl -s -w "%{http_code}" -X POST \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{
        "console_name": "'"$name"'"
    }' \
    "$create_console_url")

# Separate the HTTP status code from the response
http_code=${response: -3}
response=${response::-3}

# Check for the verbose option
if [[ $verbose == true ]]; then
    echo "$response"
fi

# Check if the response goes through by checking if the response contains the console id
console_id=$(echo "$response" | grep -oP '(?<="id":)[^,}]+')
if [[ $console_id == "" ]]; then
    echo "Failed to create console"
    ./../http_codes.sh "$http_code"
    exit 1
fi

# Print the id of the created console
echo "$console_id"