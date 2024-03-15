#!/bin/bash

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/.env"

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --auto-update|-a)
            auto_update=true
            shift
            ;;
        --force-update|-f)
            force_update=true
            shift
            ;;
        --ignore-existing|-i)
            ignore_existing=true
            shift
            ;;
        --verbose|-v)
            verbose=true
            shift
            ;;
        -vv)
            verbose=true
            very_verbose=true
            shift
            ;;
        *)
            echo "Unknown option: $key"
            exit 1
            ;;
    esac
done

# Counter variables
exit_code_0=0
exit_code_1=0
already_exists=0

### To-do create a loop that goes through each path in the .env
### associates it with a console name and if it doesn't exist
### creates a new console and associates its id
crawling_dir=$PATH_SAVES_NDS
console_name=$CONSOLE_NAME_NDS
console_id=$ID_CONSOLE_NDS



# Log in to the API
log_output=$("$(dirname "${BASH_SOURCE[0]}")/Auth_Scripts/login_api.sh")
if [[ $log_output == *"Token"* ]]; then
    # Retrieve the token from the log output
    API_TOKEN="$(echo "$log_output" | grep -oP '(?<=Token: ).*')"
    export API_TOKEN

    if [[ $verbose == true ]]; then
        echo "Logged in"
    fi
    if [[ $very_verbose == true ]]; then
        echo "$log_output"
    fi
else
    echo "Failed to log in"
    exit 1
fi

# Loop through each file and pass it as an argument to another script
for file in "$crawling_dir"/*; do

    if [[ $very_verbose == true ]]; then
        echo "Storing \"$file\" to console id $console_id"
    fi
    
    # Call your other script and pass the file as an argument
    output=$("$(dirname "${BASH_SOURCE[0]}")/Save_Scripts/store_save.sh" "$file" "$console_id" --raw)

    # Get the exit code of the previous command
    exit_code=$?

    # Check if the verbose argument is provided
    if [[ $verbose == true ]]; then
        echo "$output"
    fi

    # Check the exit code and increment the respective counter
    if [ $exit_code -eq 0 ]; then
        exit_code_0=$((exit_code_0 + 1))
    else
        # Check if is auth error
        # If the file already exists save the file name to an array
        if [[ $output == *"already exists"* ]]; then
            # Add the file name to the array
            existing_files+=("$file")
            # Increment the already_exists counter
            already_exists=$((already_exists + 1))
        fi
        exit_code_1=$((exit_code_1 + 1))
    fi
done

# Print the count of exit codes
echo "Files successfully uploaded: $exit_code_0 / $((exit_code_0 + exit_code_1))"
echo "Files failed to upload: $exit_code_1 / $((exit_code_0 + exit_code_1))"
echo "Files that already exist: $already_exists / $exit_code_1"

# Check if the ignore-existing argument is provided or if there are no existing files
if [[ $ignore_existing == true || ${#existing_files[@]} -eq 0 ]]; then
    # Log out of the API
    log_output=$(. "$(dirname "${BASH_SOURCE[0]}")/Auth_Scripts/logout_api.sh")
    unset API_TOKEN
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
    exit 0
fi

# Manage the already existing files

# Check if auto-update argument is provided
if [[ $auto_update != true ]]; then
    # Ask the user if they want to update the already existing files
    read -r -p "Do you want to update the already existing files? (y/N): " update_existing
    # Check the user's response and perform the update if requested
    if [[ $update_existing == "y" || $update_existing == "Y" ]]; then
        auto_update=true
    else 
        # Exit the script if the user does not want to update the files
        # Log out of the API
        log_output=$("$(dirname "${BASH_SOURCE[0]}")/Auth_Scripts/logout_api.sh")
        unset API_TOKEN
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
        exit 0
    fi
else
    echo "Auto-updating already existing files..."
fi

# Reset the counters
exit_code_0=0
exit_code_1=0
skip_update=0

# Loop through each existing file and pass it as an argument to the update script
for updated_file in "${existing_files[@]}"; do

    # Subtract from updated_file the path to the savefile
    file_path="${updated_file#"$crawling_dir"}"

    # Check which file is newer between the local and the remote
    if ! [[ $force_update == true ]]; then
        # Get the savefile ID from the file path
        savefile_id=$("$(dirname "${BASH_SOURCE[0]}")/Save_Scripts/get_save_id.sh" "$file_path" "$console_id")
        # Get the last modified date of the local file
        local_date=$(date -r "$updated_file" +%s)
        # Get the last modified date of the remote file
        remote_file=$("$(dirname "${BASH_SOURCE[0]}")/Save_Scripts/show_save.sh" "$savefile_id" --raw)
        # Check if the remote file is newer
        remote_date=$(grep -oP '(?<=updated_at":")[^"]*' <<< "$remote_file")
        remote_date=$(date -d "$remote_date" +%s)
        if [[ $local_date -le $remote_date ]]; then
            # Skip the update if the remote file is newer
            if [[ $verbose == true ]]; then
                echo "Skipping \"$file_path\" because the remote file is newer or the same"
                skip_update=$((skip_update + 1))
            fi
            continue
        fi
        
    fi

    # Use the savefile name to get the savefile ID
    savefile_id=$("$(dirname "${BASH_SOURCE[0]}")/Save_Scripts/get_save_id.sh" "$file_path" "$console_id")

    if [[ $verbose == true ]]; then
        echo "Updating \"$file_path\" with ID $savefile_id"
    fi

    # Call your update script and pass the file as an argument
    if [[ $very_verbose == true ]]; then
        output=$("$(dirname "${BASH_SOURCE[0]}")/Save_Scripts/update_save.sh" "$updated_file" "$savefile_id" --raw)
    else
        output=$("$(dirname "${BASH_SOURCE[0]}")/Save_Scripts/update_save.sh" "$updated_file" "$savefile_id")
    fi

    # Get the exit code of the previous command
    exit_code=$?

    # Check if the verbose argument is provided
    if [[ $verbose == true ]]; then
        echo "$output"
    fi

    # Check the exit code and increment the respective counter
    if [ $exit_code -eq 0 ]; then
        exit_code_0=$((exit_code_0 + 1))
    else
        exit_code_1=$((exit_code_1 + 1))
    fi
done

# Log out of the API
log_output=$("$(dirname "${BASH_SOURCE[0]}")/Auth_Scripts/logout_api.sh")
unset API_TOKEN
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

# Print the count of exit codes
echo "Files skipped: $skip_update / $((exit_code_0 + exit_code_1 + skip_update))"
echo "Files successfully updated: $exit_code_0 / $((exit_code_0 + exit_code_1))"
echo "Files failed to update: $exit_code_1 / $((exit_code_0 + exit_code_1))"
