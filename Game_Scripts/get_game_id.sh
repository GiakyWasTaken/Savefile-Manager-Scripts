#!/bin/bash

# Check if the game name argument is provided
if [ -z "$1" ]; then
    echo "Please provide the game name as an argument."
    exit 1
fi

# Get the json file from a script that lists all games from the API
json_file=$(./list_games.sh --raw)

# Check if list_games.sh failed
if [[ $json_file == *"Failed"* ]]; then
    echo "Failed to get the list of games"
    exit 1
fi

## Requires jq to be installed
# Parse the JSON file and select the game ID based on the provided game name
game_id=$(echo "$json_file" | jq -r --arg name "$1" '.[] | select(.name == $name) | .id')

# Check if the game ID is found
if [ -z "$game_id" ]; then
    echo "Game not found"
    exit 1
fi

# Echo the game ID
echo "$game_id"