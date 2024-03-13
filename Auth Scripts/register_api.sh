#!/bin/bash

# API registration endpoint
register_url="http://localhost:8000/api/register"

# API registration credentials
name="giaky"
password="giaky_pw"
email="giaky@example.com"

# Send registration request
response=$(curl -s -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "'"$name"'",
        "email": "'"$email"'",
        "password": "'"$password"'",
        "password_confirmation": "'"$password"'"
    }' \
    $register_url)

# Print the entire response
# echo "$response"

# Extract the token from the response
api_token=$(echo "$response" | grep -oP '(?<="token":")[^"]+')

# Check if the response says "email has already been taken"
if [[ $response == *"email has already been taken"* ]]; then
    echo "Email has already been taken"
    exit 1
fi

# Check if the response contains the token
if [[ $api_token == "" ]]; then
    echo "Failed to log in"
    exit 1
fi

# Print the API token
echo "API Token: $api_token"
