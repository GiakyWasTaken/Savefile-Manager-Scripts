#!/bin/bash

log_dir=$(dirname "${BASH_SOURCE[0]}")/log/

# Find files older than a day and delete them
find "$log_dir" -type f -mtime +1 -exec rm {} \;