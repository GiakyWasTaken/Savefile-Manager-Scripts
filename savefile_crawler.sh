#!/bin/bash

# Source the .env file
source "$(dirname "${BASH_SOURCE[0]}")/.env"

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --auto-update|-a)
            # Auto-update already existing files only if the local file is newer
            auto_update=true
            shift
            ;;
        --force-update|-f)
            # Force update the already existing files even if the remote file is newer
            force_update=true
            shift
            ;;
        --ignore-existing|-i)
            # Ignore updating already existing files
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

saves_array_index=0

for save_path in "${SAVES_PATHS[@]}"; do
    # Check if the path exists
    if [[ ! -d "$save_path" ]]; then
        echo "Path \"$save_path\" does not exist"
        continue
    fi

    # Get the console name from the .env file
    console_name="${CONSOLE_NAMES[$saves_array_index]}"

    echo "Crawling \"$console_name\" saves inside \"$save_path\""

    output=$("$(dirname "${BASH_SOURCE[0]}")/Console_Scripts/get_console_id.sh" "$console_name")

    # Check if the console already exist on the db
    if [[ $output == *"not found"* ]]; then
        # Create the console
        output=$("$(dirname "${BASH_SOURCE[0]}")/Console_Scripts/store_console.sh" "$console_name" -v)
        
        # Get the exit code of the previous command
        exit_code=$?

        # Check if the verbose argument is provided
        if [[ $very_verbose == true ]]; then
            echo "$output"
        fi

        # Check the exit code and exit the script if it failed
        if [ $exit_code -ne 0 ]; then
            exit 1
        fi

        # Get the console id from the output
        console_id=$(echo "$output" | grep -oP '(?<="id":)[^,}]+')
        if [[ $console_id == "" ]]; then
            echo "Failed to get console id"
            exit 1
        fi

        if [[ $verbose == true ]]; then
            echo "Console \"$console_name\" created with id $console_id"
        fi
    else
        console_id=$output
    fi

    # Loop through each file in the directory and subdirectories
    IFS=$'\n'; set -f
    for file in $(find "$save_path"); do

        # Check if $file is a directory
        if [[ -d "$file" ]]; then
            if [[ verbose == true ]]; then
                echo "Now entering directory \"$file\""
            fi
            continue
        fi

        if [[ $very_verbose == true ]]; then
            echo "Storing \"$file\" to console $console_name with id $console_id"
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
        if [[ $exit_code -eq 0 ]]; then
            exit_code_0=$((exit_code_0 + 1))

        # If the file already exists save the file name to an array
        elif [[ $output == *"already exists"* ]]; then
                # Add the console id and the file name to the array
                existing_files+=("$console_id")
                existing_files+=("$file")
                # Increment the already_exists counter
                already_exists=$((already_exists + 1))
        else
            exit_code_1=$((exit_code_1 + 1))
        fi
    done

    unset IFS; set +f

    # Increment the saves_array_index
    saves_array_index=$((saves_array_index + 1))
done

# Print the count of exit codes
echo "Files successfully uploaded: $exit_code_0 / $((exit_code_0 + exit_code_1 + already_exists))"
echo "Files failed to upload: $exit_code_1 / $((exit_code_0 + exit_code_1 + already_exists))"
echo "Files that already exist: $already_exists / $((exit_code_0 + exit_code_1 + already_exists))"

# Check if the ignore-existing argument is provided or if there are no existing files
if [[ $ignore_existing == true || ${#existing_files[@]} -eq 0 ]]; then
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
for file_to_update in "${existing_files[@]}"; do

    # Check if the file_to_update is a console id
    if [[ $file_to_update =~ ^[0-9]+$ ]]; then
        console_id=$file_to_update
        continue
    fi

    # Subtract from file_to_update the path to the savefile
    for save_path in "${SAVES_PATHS[@]}"; do
        if [[ "$file_to_update" == "$save_path"* ]]; then
            file_path="${file_to_update#"$save_path"}"
            break
        fi
    done

    # Check which file is newer between the local and the remote
    if ! [[ $force_update == true ]]; then
        # Get the savefile ID from the file path
        savefile_id=$("$(dirname "${BASH_SOURCE[0]}")/Save_Scripts/get_save_id.sh" "$file_path" "$console_id")
        if [[ $savefile_id == *"not found"* ]]; then
            echo "Failed to get the savefile ID of \"$file_path\" with console ID $console_id"
            exit 1
        fi
        # Get the last modified date of the local file
        local_date=$(date -r "$file_to_update" +%s)
        # Get the last modified date of the remote file
        remote_file=$("$(dirname "${BASH_SOURCE[0]}")/Save_Scripts/show_save.sh" "$savefile_id" --raw)
        # Check if the remote file is newer
        remote_date=$(grep -oP '(?<=updated_at":")[^"]*' <<< "$remote_file")
        remote_date=$(date -d "$remote_date" +%s)
        if [[ $local_date -le $remote_date ]]; then
            # Skip the update if the remote file is newer
            if [[ $verbose == true ]]; then
                echo "Skipping \"$file_to_update\" because the remote file is newer or the same"
                skip_update=$((skip_update + 1))
            fi
            continue
        fi
        
    fi

    # Use the savefile name to get the savefile ID
    savefile_id=$("$(dirname "${BASH_SOURCE[0]}")/Save_Scripts/get_save_id.sh" "$file_path" "$console_id")

    if [[ $verbose == true ]]; then
        echo "Updating \"$file_to_update\" with ID $savefile_id"
    fi

    # Call your update script and pass the file as an argument
    if [[ $very_verbose == true ]]; then
        output=$("$(dirname "${BASH_SOURCE[0]}")/Save_Scripts/update_save.sh" "$file_to_update" "$savefile_id" --raw)
    else
        output=$("$(dirname "${BASH_SOURCE[0]}")/Save_Scripts/update_save.sh" "$file_to_update" "$savefile_id")
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
