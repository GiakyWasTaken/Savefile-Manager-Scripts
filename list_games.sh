#!/bin/bash

# Source the .env file
source .env

# API endpoint URL
game_list_url=$API_URL"game"

# Make the API request and save the response to a variable
response=$(curl -s -X GET \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$game_list_url")

# Extract the names from the JSON response using pattern matching
names=$(echo "$response" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)

if [[ $names == "" ]]; then
    echo "Failed to get the list of games"
    echo "$response"
    exit 1
fi

# Loop through each name and echo it
for name in $names; do
    echo "$name"
done

# May change the script later...