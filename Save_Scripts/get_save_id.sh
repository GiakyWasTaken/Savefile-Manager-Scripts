#!/bin/bash

# Check if the savefile name argument is provided
if [ -z "$1" ]; then
    echo "Please provide the savefile name as an argument"
    exit 1
fi
# Check if the game argument is provided
if [ -z "$2" ]; then
    echo "Please provide the game ID or name as an argument"
    exit 1
fi
# Check if the game argument is a number and set the game_id_flag
if [[ $2 =~ ^[0-9]+$ ]]; then
    game_id_flag=true
fi

# Get the json file from a script that indexes all savefiles from the API
json_file=$(./index_saves.sh --raw)

# Check if index_saves.sh failed
if [[ $json_file == *"Failed"* ]]; then
    echo "Failed to get the index of savefiles"
    exit 1
fi

## Requires jq to be installed
# Parse the JSON file and select the savefile ID for the provided savefile name
if [[ $game_id_flag == true ]]; then
    # Parse based on game ID
    savefile_id=$(echo "$json_file" | jq -r --arg savefile_name "$1" --argjson game_id "$2" '.[] | select(.file_name == $savefile_name and .fk_id_game == $game_id) | .id')
else
    # Parse based on game name
    savefile_id=$(echo "$json_file" | jq -r --arg savefile_name "$1" --arg game_name "$2" '.[] | select(.file_name == $savefile_name and .game_name == $game_name) | .id')
fi

# Check if the savefile ID is found
if [ -z "$savefile_id" ]; then
    echo "Savefile not found"
    exit 1
fi

# Echo the savefile ID
echo "$savefile_id"