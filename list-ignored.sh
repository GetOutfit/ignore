#!/usr/bin/env bash

# Configuration
SOURCE_DIR="/mnt"
EXCLUDED_DIRS=("letsencrypt" "node_modules")
EXCLUDED_FILES=("*.csv" "*.zip")

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
        echo "=== Files from $gitignore ==="
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
                echo "$file"
            fi
        done)
    fi
done
