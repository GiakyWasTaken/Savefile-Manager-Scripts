#!/bin/bash

# Source the .env file
source .env

# API endpoint URL
game_delete_url=$API_URL"game"

# Get the game id from the argument
game_id="$1"
shift

# Check if the game id is provided
if [ -z "$game_id" ]; then
    echo "Please provide the game ID as an argument"
    exit 1
fi
# Check if the game id is a number
if ! [[ $game_id =~ ^[0-9]+$ ]]; then
    echo "Game ID must be a number"
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

# Add the game id to the API endpoint URL
game_delete_url="$game_delete_url/$game_id"

# Make the API request and save the response to a variable
response=$(curl -s -w "%{http_code}" -X DELETE \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$game_delete_url")

# Separate the HTTP status code from the response
http_code=${response: -3}
response=${response::-3}

# Check for the verbose option
if [[ $verbose == true ]]; then
    echo "$response"
fi

# Check if the request succeeded
if [[ $http_code == 204 ]]; then
    echo "Game successfully deleted"
    exit 0
else
    echo "Failed to delete the game"
    ./../http_codes.sh "$http_code"
    exit 1
fi
