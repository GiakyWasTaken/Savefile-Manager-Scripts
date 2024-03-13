#!/bin/bash

# Source the .env file
source ../.env

# API logout endpoint
logout_url=$API_URL"logout"

# API token
token=$API_TOKEN

# Send logout request
response=$(curl -X GET \
    -H "Authorization: Bearer $token" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$logout_url")

# Check if the response contains "Logged out"
if [[ $response == *"Logged out"* ]]; then
    echo "Logged out"
elif [[ $response == *"Unauthenticated"* ]]; then
    echo "Unauthenticated"
    exit 1
else
    echo "Failed to log out"
    exit 1
fi

# Remove the token from the .env file
sed -i '/API_TOKEN/d' ../.env
