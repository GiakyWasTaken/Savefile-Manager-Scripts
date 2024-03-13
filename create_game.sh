#!/bin/bash

# Check if the name argument is provided
if [ $# -eq 0 ]; then
    echo "Please provide a name for the game."
    exit 1
fi

# Store the name argument in a variable
name=$1

# Source the .env file
source .env

# API endpoint URL
create_game_url=$API_URL"game"

# Send create game request
response=$(curl -s -X POST \
    -H "Authorization: Bearer dsa" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "'"$name"'"
    }' \
    "$create_game_url")

# Check if the response goes through by checking if the response contains the game "id"
game_id=$(echo "$response" | grep -oP '(?<="id":)[^,]+')
if [[ $game_id == "" ]]; then
    echo "Failed to create game"
    echo "$response"
    exit 1
fi

# Print the entire response
echo "$response"
