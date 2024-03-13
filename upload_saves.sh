#!/bin/bash

# Source the .env file
source .env

store_url=$API_URL"savefile"

for file in "$NDS_SAVES_PATH"/*; do
    if [ -f "$file" ]; then
        response=$(curl -X POST \
            -H "Authorization: Bearer $API_TOKEN" \
            -F "savefile=@$file" \
            -F "fk_id_game=1" \
            "$store_url")
    
        # echo "$response"

        if [[ $response == *"Unauthenticated"* ]]; then
            echo "Unauthenticated"
            exit 1
        fi

        # Extract the file_name from the response
        file_name=$(echo "$response" | grep -oP '(?<="file_name":")[^"]+')
        echo "$file_name"
        
        # stop for loop
        break
    fi
done

