#!/bin/bash

# Source the .env file
source .env

# API endpoint URL
savefile_delete_url=$API_URL"savefile"

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
savefile_delete_url="$savefile_delete_url/$savefile_id"

# Make the API request and save the response to a variable
response=$(curl -s -w "%{http_code}" -X DELETE \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$savefile_delete_url")

# Separate the HTTP status code from the response
http_code=${response: -3}
response=${response::-3}

# Check for the verbose option
if [[ $verbose == true ]]; then
    echo "$response"
fi

# Check if the request succeeded
if [[ $http_code == 200 ]]; then
    echo "Savefile successfully deleted"
    exit 0
else
    echo "Failed to delete the savefile"
    ./http_codes.sh "$http_code"
    exit 1
fi
