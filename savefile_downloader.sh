#!/bin/bash

# Create and write a log file
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
exec > >(tee -i "$(dirname "${BASH_SOURCE[0]}")/log/savefile_downloader_$current_time.log")

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/.env"

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --verbose|-v)
            verbose=true
            shift
            ;;
        --force|-f)
            force=true
            shift
            ;;
        *)
            echo "Unknown option: $key"
            exit 1
            ;;
    esac
done

# Log in to the API
log_output=$("$(dirname "${BASH_SOURCE[0]}")/Auth_Scripts/login_api.sh")
if [[ $log_output == *"Token"* ]]; then
    # Retrieve the token from the log output
    API_TOKEN="$(echo "$log_output" | grep -oP '(?<=Token: ).*')"
    export API_TOKEN
    if [[ $verbose == true ]]; then
        echo "Logged in"
        echo "$log_output"
    fi
else
    echo "Failed to log in"
    exit 1
fi

# Index for the .env arrays
env_arrays_index=0

# Counter variables
successful_downloads=0
failed_downloads=0
skipped_files=0

# Main loop for uploading files
for console_name in "${CONSOLE_NAMES[@]}"; do

    if [[ $verbose == true ]]; then
        echo "Downloading savefiles for $console_name"
    fi

    # Get the console id from the API
    console_id=$("$(dirname "${BASH_SOURCE[0]}")/Console_Scripts/get_console_id.sh" "$console_name")

    # Check if the console ID is a number
    if ! [[ $console_id =~ ^[0-9]+$ ]]; then
        echo "Failed to get the console ID of $console_name"
        if [[ $verbose == true ]]; then
            echo "$console_id"
        fi
        continue
    fi

    # Get the relative path of the savefile
    savefile_path="${SAVES_PATHS[$env_arrays_index]}"

    # Get the all the savefiles for the console
    savefiles_json=$("$(dirname "${BASH_SOURCE[0]}")/Save_Scripts/index_saves.sh" --raw)

    # Get all id by filtering all the savefiles for the console
    savefile_ids=$(echo "$savefiles_json" | jq -r --argjson console_id "$console_id" '.[] | select(.fk_id_console == $console_id) | .id')

    # Loop through all the savefile ids
    for savefile_id in $savefile_ids; do

        # Get the savefile name
        savefile_name=$(echo "$savefiles_json" | jq -r --argjson savefile_id "$savefile_id" '.[] | select(.id == $savefile_id) | .file_name')
        savefile_relative_path=$(echo "$savefiles_json" | jq -r --argjson savefile_id "$savefile_id" '.[] | select(.id == $savefile_id) | .file_path')
        # echo "$savefile_relative_path"

        if [[ $savefile_relative_path == "/" ]]; then
            local_abs_path=$savefile_path$savefile_name 
        else
            local_abs_path=$savefile_path$savefile_relative_path$savefile_name
        fi

        # Check if the local file is newer than the remote file
        if [[ -f "$local_abs_path" ]] && [[ $force != true ]]; then
            # Get the modification time of the local file
            local_modification_time=$(stat -c %Y "$local_abs_path")

            # Get the modification time of the remote file
            remote_modification_time=$(echo "$savefiles_json" | jq -r --argjson savefile_id "$savefile_id" '.[] | select(.id == $savefile_id) | .updated_at')

            # Convert the remote modification time to seconds
            remote_modification_time=$(date -d "$remote_modification_time" +%s)

            # Check if the local file is newer than the remote file
            if [[ $local_modification_time -ge $remote_modification_time ]]; then
                if [[ $verbose == true ]]; then
                    echo "Local file is the same or newer than the remote file: $savefile_name"
                    skipped_files=$((skipped_files + 1))
                fi
                continue
            fi
        fi

        if [[ $verbose == true ]]; then
            echo "Downloading $savefile_name to $local_abs_path"
        fi

        # Download the savefile
        download_output=$("$(dirname "${BASH_SOURCE[0]}")/Save_Scripts/show_save.sh" "$savefile_id" --download)

        # Check if the download was successful
        if [[ $download_output == *"Failed"* ]]; then
            echo "Failed to download $savefile_name"
            if [[ $verbose == true ]]; then
                echo "$download_output"
            fi
            failed_downloads=$((failed_downloads + 1))
            continue
        fi

        # Check if the Downloads directory exists and is not empty
        if [[ ! -d "$(dirname "${BASH_SOURCE[0]}")/Downloads/" ]] || [[ -z "$(ls -A "$(dirname "${BASH_SOURCE[0]}")/Downloads/")" ]]; then
            echo "No files to copy from downloads directory"
            continue
        fi
        # Check if the savefile path exists
        if [[ ! -d "$savefile_path" ]]; then
            echo "Destination folder does not exist: $savefile_path"
            break
        fi

        # Move the savefile to the savefile path
        cp_output=$(cp -r "$(dirname "${BASH_SOURCE[0]}")/Downloads/"* "$savefile_path")
        rm_output=$(rm -rf "$(dirname "${BASH_SOURCE[0]}")/Downloads/")
        if [[ $verbose == true ]]; then
            # Print only if output aren't empty
            if [[ $cp_output != "" || $rm_output != "" ]]; then
                echo "$cp_output"
                echo "$rm_output"
            fi
        fi
        successful_downloads=$((successful_downloads + 1))

    done

    # Increment the index
    env_arrays_index=$((env_arrays_index + 1))

done

# Log out of the API
log_output=$("$(dirname "${BASH_SOURCE[0]}")/Auth_Scripts/logout_api.sh")
if [[ $verbose == true ]]; then
    if [[ $log_output == *"Logged out"* ]]; then
        echo "Logged out"
    else
        echo "Failed to log out"
        if [[ $very_verbose == true ]]; then
            echo "$log_output"
        fi
        exit 1
    fi
fi

# Print the results
echo "Files skipped: $skipped_files / $((successful_downloads + failed_downloads + skipped_files))"
echo "Files downloaded: $successful_downloads / $((successful_downloads + failed_downloads))"
echo "Files failed to download: $failed_downloads / $((successful_downloads + failed_downloads))"
