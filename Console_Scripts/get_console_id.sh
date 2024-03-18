#!/bin/bash

# Check if the console name argument is provided
if [ -z "$1" ]; then
    echo "Please provide the console name as an argument."
    exit 1
fi

# Get the json file from a script that indexes all consoles from the API
json_file=$("$(dirname "${BASH_SOURCE[0]}")/index_consoles.sh" --raw)

# Check if index_consoles.sh failed
if [[ $json_file == *"Failed"* ]]; then
    echo "Failed to get the index of consoles"
    exit 1
fi

## Requires jq to be installed
# Parse the JSON file and select the console ID based on the provided console name
console_id=$(echo "$json_file" | jq -r --arg name "$1" '.[] | select(.console_name == $name) | .id')

# Check if the console ID is found
if [ -z "$console_id" ]; then
    echo "Console not found"
    exit 1
fi

# Echo the console ID
echo "$console_id"