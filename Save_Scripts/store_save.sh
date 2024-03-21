#!/bin/bash

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/../.env"

# API endpoint URL
store_url=$API_URL"savefile"

# Check if the file argument is provided
if [ $# -eq 0 ]; then
    echo "Please provide a file and relative console id or name as an argument"
    exit 1
fi

# Get the file path from the argument
file="$1"
shift

# Check if the file exists
if [ ! -f "$file" ]; then
    echo "File $file does not exist."
    exit 1
fi

# Check if the console id or name is provided
if [ -z "$1" ]; then
    echo "Please provide the console ID as an argument"
    exit 1
fi
# Check if the argument is an id or a name
if [[ $1 =~ ^[0-9]+$ ]]; then
    console_id="$1"
else
    # Get the console id from the console name
    console_id=$("$(dirname "${BASH_SOURCE[0]}")/get_console_id.sh" "$1")
    # Check if the console id is found
    if [ -z "$console_id" ]; then
        echo "Console name not found"
        exit 1
    fi
fi
shift

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --raw)
            raw_response=true
            shift
            ;;
        *)
            echo "Unknown option: $key"
            exit 1
            ;;
    esac
done

# Separate the file name from the path
file_name=$(basename "$file")
abs_path=$(dirname "$file")

# Subtract from the absolute path the save paths
for save_path in "${SAVES_PATHS[@]}"; do
    if [[ "$abs_path" == "$save_path"* ]]; then
        file_path="${abs_path#"$save_path"}"
        break
    fi
done

# Check if the file path is an empty string
if [[ $file_path == "" ]]; then
    file_path="/"
fi

# Get the file timestamp
file_timestamp=$(date -r "$file" +"%Y-%m-%dT%H:%M:%S")

# Send store file request
response=$(curl -s -w "%{http_code}" -X POST \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Accept: application/json" \
    -F "savefile=@$file" \
    -F "file_name=$file_name" \
    -F "file_path=$file_path" \
    -F "updated_at=$file_timestamp" \
    -F "fk_id_console=$console_id" \
    "$store_url")

# Separate the HTTP status code from the response
http_code=${response: -3}
response=${response::-3}
response=${response//\\/}

# Check if the --raw argument is provided
if [[ $raw_response == true ]]; then
    # Print the raw response
    echo "$response"

    # Check if the response contains the file_name to determine the exit code
    if [[ $http_code == 201 ]]; then
        exit 0
    else
        exit 1
    fi
fi


# Check if the file already exists
if [[ $http_code == 409 ]]; then
    echo "File \"$file\" already exists"
    exit 1
fi

# Check the HTTP status code for success
if ! [[ $http_code == 201 ]]; then
    echo "Failed to upload \"$file\""
    "$(dirname "${BASH_SOURCE[0]}")/../http_codes.sh" "$http_code"
    exit 1
fi

# Extract the id from the response
savefile_id=$(echo "$response" | grep -oP '(?<="id":)[^,}]*')

# Print the id of the created savefile
echo "$savefile_id"
