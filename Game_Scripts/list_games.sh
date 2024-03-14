#!/bin/bash

# Source the .env file
source .env

# API endpoint URL
game_list_url=$API_URL"game"

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

# Make the API request and save the response to a variable
response=$(curl -s -X GET \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$game_list_url")

# Check if the --raw option is specified
if [[ $raw_response == true ]]; then
    echo "$response"
    exit 0
fi

# Extract the names from the JSON response using pattern matching
names=$(echo "$response" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)

if [[ $names == "" ]]; then
    echo "Failed to get the list of games"
    echo "$response"
    exit 1
fi

# Echo the names separated by a newline
echo "$names"

# May change the script later...