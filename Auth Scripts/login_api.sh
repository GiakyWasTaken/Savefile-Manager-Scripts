#!/bin/bash

# API login endpoint
login_url="http://localhost:8000/api/login"

# API login credentials
email="giaky@example.com"
password="giaky_pw"


# Send login request
response=$(curl -s -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{
        "email": "'"$email"'",
        "password": "'"$password"'"
    }' \
    $login_url)

# Print the entire response
# echo "$response"

# Extract the token from the response
api_token=$(echo "$response" | grep -oP '(?<="token":")[^"]+')

# Check if the response contains the token
if [[ $api_token == "" ]]; then
    echo "Failed to log in"
    exit 1
fi

# Print the token
echo "API Token: $api_token"
