#!/bin/bash

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/../.env"

# API endpoint URL
savefile_destroy_url=$API_URL"savefile"

# Get the savefile id from the argument
savefile_id="$1"
shift

# Check if the savefile id is provided
if [ -z "$savefile_id" ]; then
    echo "Please provide the savefile ID as an argument"
    exit 1
fi
# Check if the savefile id is a number
if ! [[ $savefile_id =~ ^[0-9]+$ ]]; then
    echo "Savefile ID must be a number"
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

# Add the savefile id to the API endpoint URL
savefile_destroy_url="$savefile_destroy_url/$savefile_id"

# Send delete savefile request
response=$(curl -s -w "%{http_code}" -X DELETE \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$savefile_destroy_url")

# Separate the HTTP status code from the response
http_code=${response: -3}
response=${response::-3}

# Check for the verbose option
if [[ $verbose == true ]]; then
    echo "$response"
fi

# Check if the request succeeded
if [[ $http_code == 200 ]]; then
    echo "Savefile deleted"
    exit 0
else
    echo "Failed to delete the savefile"
    "$(dirname "${BASH_SOURCE[0]}")/../http_codes.sh" "$http_code"
    exit 1
fi
