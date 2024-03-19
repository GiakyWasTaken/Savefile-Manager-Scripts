#!/bin/bash

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/../.env"

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

# API login endpoint
login_url=$API_URL"login"

# Send login request
response=$(curl -s -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{
        "email": "'"$EMAIL"'",
        "password": "'"$PASSWORD"'"
    }' \
    "$login_url")

if [[ $raw_response == true ]]; then
    echo "$response"
    exit 0
fi

# Extract the token from the response
api_token=$(echo "$response" | grep -oP '(?<="token":")[^"]+')

# Check if the response contains the token
if [[ $api_token == "" ]]; then
    echo "Failed to log in"
    exit 1
fi

# Print the token
echo "API Token: $api_token"

# Export the token
export API_TOKEN=$api_token