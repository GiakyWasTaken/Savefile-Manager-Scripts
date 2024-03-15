#!/bin/bash

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/../.env"

# API endpoint URL
console_destroy_url=$API_URL"console"

# Get the console id from the argument
console_id="$1"
shift

# Check if the console id is provided
if [ -z "$console_id" ]; then
    echo "Please provide the console ID as an argument"
    exit 1
fi
# Check if the console id is a number
if ! [[ $console_id =~ ^[0-9]+$ ]]; then
    echo "Console ID must be a number"
    exit 1
fi

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

# Add the console id to the API endpoint URL
console_destroy_url="$console_destroy_url/$console_id"

# Send delete console request
response=$(curl -s -w "%{http_code}" -X DELETE \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$console_destroy_url")

# Separate the HTTP status code from the response
http_code=${response: -3}
response=${response::-3}

# Check for the verbose option
if [[ $verbose == true ]]; then
    echo "$response"
fi

# Check if the request succeeded
if [[ $http_code == 200 ]]; then
    echo "Console deleted"
    exit 0
else
    echo "Failed to delete the console"
    "$(dirname "${BASH_SOURCE[0]}")/../http_codes.sh" "$http_code"
    exit 1
fi
