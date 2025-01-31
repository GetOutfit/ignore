# Ignore

A tool to manage and backup files listed in `.gitignore` files across multiple projects. This is particularly useful for backing up ignored configuration files, environment files, and other important files that shouldn't be committed to Git repositories.

## Features

- Lists all ignored files from `.gitignore` files in subdirectories
- Creates backups of ignored files while preserving directory structure
- Maintains a symlink to the latest backup for easy access
- Allows configuring excluded directories and file patterns

## Scripts

### list-ignored.sh

Lists all ignored files found in directories containing `.gitignore` files:
```bash
./list-ignored.sh
```

### save-ignored.sh

Creates a timestamped backup of all ignored files:
```bash
./save-ignored.sh
```

The script:
- Creates backups in the `backups` directory
- Generates timestamped archives (e.g., `ignored-backup_20250131_105140.tar.gz`)
- Maintains a symlink `ignored-backup.tar.gz` pointing to the latest backup

## Configuration

Both scripts share these configuration variables at the top of each file:
```bash
SOURCE_DIR="/mnt"               # Base directory to scan
EXCLUDED_DIRS=("letsencrypt" "node_modules")   # Directories to skip
EXCLUDED_FILES=("*.csv" "*.zip")               # File patterns to skip
```

Modify these variables to customize which files and directories to exclude from processing.

## Backup Contents

To view files in a backup without extracting:
```bash
tar tfz backups/ignored-backup.tar.gz    # List files only
tar tvfz backups/ignored-backup.tar.gz   # List files with details
```

To extract files:
```bash
tar xvfz backups/ignored-backup.tar.gz
```

## License

This project is open source and available under the MIT License.
