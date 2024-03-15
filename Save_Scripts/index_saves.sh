#!/bin/bash

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/../.env"

# API endpoint URL
savefile_index_url=$API_URL"savefile"

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

# Send index savefiles request
response=$(curl -s -X GET \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$savefile_index_url")

# Check if the --raw option is specified
if [[ $raw_response == true ]]; then
    echo "$response"
    exit 0
fi

# Extract the names from the JSON response using pattern matching
names=$(echo "$response" | grep -o '"file_name":"[^"]*"' | cut -d'"' -f4)

if [[ $names == "" ]]; then
    echo "Failed to get the index of savefiles"
    echo "$response"
    exit 1
fi

# Echo the names separated by a newline
echo "$names"
