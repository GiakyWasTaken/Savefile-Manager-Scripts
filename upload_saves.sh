#!/bin/bash

# Source the .env file
source .env

# API endpoint URL
store_url=$API_URL"savefile"

# Cycle through each file in the NDS_SAVES_PATH
for file in "$NDS_SAVES_PATH"/*; do
    # Check if the file exists
    if [ -f "$file" ]; then
        # Send store file request
        response=$(curl -s -X POST \
            -H "Authorization: Bearer $API_TOKEN" \
            -F "savefile=@$file" \
            -F "fk_id_game=1" \
            "$store_url")
    
        # echo "$response"

        # Extract the file_name from the response
        file_name=$(echo "$response" | grep -oP '(?<="file_name":")[^"]+')
        echo "$file_name"

        # Check if the response contains the file_name
        if [[ $file_name == "" ]]; then
            echo "Failed to upload $file"
            echo "$response"
            exit 1
        fi

        # stop for loop
        break
    fi
done

