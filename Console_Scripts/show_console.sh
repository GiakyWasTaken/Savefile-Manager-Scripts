#!/bin/bash

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/../.env"

# Check if the console id argument is provided
if [ -z "$1" ]; then
    echo "Please provide the console ID as an argument"
    exit 1
fi
# Check if the console id is a number
if [[ ! $1 =~ ^[0-9]+$ ]]; then
    echo "Invalid console ID"
    exit 1
fi
# Save the console id
console_id=$1
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
console_show_url=$API_URL"console/"$console_id

# Send show consoles request
response=$(curl -s -X GET \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$console_show_url")

# Check if the --raw option is specified
if [[ $raw_response == true ]]; then
    echo "$response"
    exit 0
fi

# Extract the name from the JSON
console_name=$(echo "$response" | grep -o '"console_name":"[^"]*"' | cut -d'"' -f4)

if [[ $console_name == "" ]]; then
    echo "Failed to get console"
    echo "$response"
    exit 1
fi

# Echo the name separated by a newline
echo "$console_name"
