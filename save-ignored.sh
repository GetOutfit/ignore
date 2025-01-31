#!/usr/bin/env bash

# Load configuration from .env
ENV_FILE="$(dirname "$(readlink -f "$0")")/.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found at $ENV_FILE"
    echo
    echo "Please create .env file with the following content:"
    echo "SOURCE_DIR=\"/mnt\"                            # Base directory to scan"
    echo "EXCLUDED_DIRS=(\"letsencrypt\" \"node_modules\") # Directories to skip"
    echo "EXCLUDED_FILES=(\"*.csv\" \"*.zip\")             # File patterns to skip"
    exit 1
fi
source "$ENV_FILE"

# Get the directory where the script is located
script_dir=$(dirname "$(readlink -f "$0")")
backup_dir="${script_dir}/backups"

# Create backups directory if it doesn't exist
mkdir -p "$backup_dir"

# Create a timestamp for the backup file
timestamp=$(date +%Y%m%d_%H%M%S)
backup_file="${backup_dir}/ignored-backup_${timestamp}.tar.gz"

# Create a temporary directory for the files
temp_dir=$(mktemp -d)

# Function to check if path contains excluded directory
contains_excluded_dir() {
    local check_path="$1"
    for excluded_dir in "${EXCLUDED_DIRS[@]}"; do
        # Use grep to match exact directory names in path
        if echo "$check_path" | grep -q "/\($excluded_dir\)/\|/\($excluded_dir\)$"; then
            return 0  # true in bash
        fi
    done
    return 1  # false in bash
}

# Process each .gitignore file
for gitignore in "${SOURCE_DIR}"/*/.gitignore; do
    dir=$(dirname "$gitignore")
    dir_name=$(basename "$dir")
    
    echo "Processing directory: $dir"

    # Skip if this directory contains excluded directory
    if contains_excluded_dir "$dir"; then
        echo "  Skipping directory: $dir (contains excluded directory)"
        continue
    fi

    if [ -f "$gitignore" ]; then
        # Create subdirectory in temp directory to maintain structure
        mkdir -p "${temp_dir}/${dir_name}"

        # Change to the directory and copy ignored files
        (cd "$dir" && git ls-files --ignored --exclude-standard --others | \
        while read file; do
            full_path="$dir/$file"
            
            # Skip if file path contains excluded directory
            if contains_excluded_dir "$full_path"; then
                continue
            fi
            
            # Skip if file matches excluded pattern
            skip=false
            for excluded_file in "${EXCLUDED_FILES[@]}"; do
                if [[ "$file" == $excluded_file ]]; then
                    skip=true
                    break
                fi
            done
            
            if [ "$skip" = false ] && [ -f "$file" ]; then
                # Create directory structure in temp directory
                mkdir -p "${temp_dir}/${dir_name}/$(dirname "$file")"
                # Copy the file, preserving path
                cp --parents "$file" "${temp_dir}/${dir_name}/"
            fi
        done)
    fi
done

# Create the archive
tar -czf "$backup_file" -C "$temp_dir" .

# Clean up
rm -rf "$temp_dir"

# Create/update symlink to the latest backup
latest_link="${backup_dir}/ignored-backup.tar.gz"
ln -sf "$(basename "$backup_file")" "$latest_link"

echo "Backup created: $backup_file"
echo "Updated symlink: $latest_link -> $(basename "$backup_file")"
