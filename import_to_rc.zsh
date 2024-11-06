#!/bin/zsh

# Orion Browser Profile Migration Script
# This script migrates user data from Orion Browser to Orion RC Browser
# Including: profiles, extensions, settings, and other user data

# Base directories with full paths
ORION_DIR="${HOME}/Library/Application Support/Orion"
ORION_RC_DIR="${HOME}/Library/Application Support/Orion RC"

# Print script header
echo "\x1b[34m=== Orion Browser Migration Tool ===\x1b[0m"
echo "\x1b[32m[INFO]\x1b[0m Source: $ORION_DIR"
echo "\x1b[32m[INFO]\x1b[0m Destination: $ORION_RC_DIR"

# Validate source directory exists
if [ ! -d "$ORION_DIR" ]; then
    echo "\x1b[31m[ERROR]\x1b[0m Source directory not found. Is Orion Browser installed?"
    exit 1
fi

# Check if destination directory exists and handle it
if [ -d "$ORION_RC_DIR" ]; then
    echo "\x1b[33m[WARNING]\x1b[0m Destination directory already exists."
    echo "Choose an option:"
    echo "1) Backup existing data and continue"
    echo "2) Remove existing data and continue"
    echo "3) Exit"
    read "choice?Enter your choice (1-3): "
    
    case $choice in
        1)
            backup_dir="${ORION_RC_DIR}_backup_$(date '+%Y%m%d_%H%M%S')"
            echo "\x1b[32m[INFO]\x1b[0m Backing up existing data to: $backup_dir"
            mv "$ORION_RC_DIR" "$backup_dir"
            ;;
        2)
            echo "\x1b[32m[INFO]\x1b[0m Removing existing data..."
            rm -rf "$ORION_RC_DIR"
            ;;
        3)
            echo "\x1b[31m[EXIT]\x1b[0m Migration cancelled by user"
            exit 0
            ;;
        *)
            echo "\x1b[31m[ERROR]\x1b[0m Invalid choice"
            exit 1
            ;;
    esac
fi

# Create destination directory
mkdir -p "$ORION_RC_DIR"

# Copy profile directories (contains main browser data and extensions)
for uuid_dir in "$ORION_DIR"/*-*-*-*-*; do
    if [ -d "$uuid_dir" ]; then
        uuid_name=$(basename "$uuid_dir")
        echo "\x1b[32m[INFO]\x1b[0m Copying profile directory $uuid_name..."
        
        # Ensure Extensions directory exists in destination
        mkdir -p "$ORION_RC_DIR/$uuid_name/Extensions"
        
        # Copy each extension individually to ensure integrity
        for ext_dir in "$uuid_dir/Extensions"/*; do
            if [ -d "$ext_dir" ]; then
                ext_name=$(basename "$ext_dir")
                echo "\x1b[32m[INFO]\x1b[0m Copying extension: $ext_name"
                cp -r "$ext_dir" "$ORION_RC_DIR/$uuid_name/Extensions/"
            fi
        done
        
        # Copy extensions.plist (contains extension settings and activation states)
        if [ -f "$uuid_dir/Extensions/extensions.plist" ]; then
            echo "\x1b[32m[INFO]\x1b[0m Copying extensions.plist..."
            cp "$uuid_dir/Extensions/extensions.plist" "$ORION_RC_DIR/$uuid_name/Extensions/"
        fi
        
        # Copy Extension State (contains extension runtime data)
        if [ -d "$uuid_dir/Extension State" ]; then
            echo "\x1b[32m[INFO]\x1b[0m Copying Extension State..."
            cp -r "$uuid_dir/Extension State" "$ORION_RC_DIR/$uuid_name/"
        fi
        
        echo "\x1b[32m[SUCCESS]\x1b[0m Copied profile directory"
    fi
done

# Function to copy browser data directories and files
function copy_browser_data() {
    local src="$ORION_DIR/$1"
    local dst="$ORION_RC_DIR/$1"
    
    echo "\x1b[32m[INFO]\x1b[0m Copying $1..."
    if [ -e "$src" ]; then
        cp -r "$src" "$dst"
        echo "\x1b[32m[SUCCESS]\x1b[0m Copied $1"
    else
        echo "\x1b[33m[SKIP]\x1b[0m Optional component $1 not found"
    fi
}

# Copy essential browser components
# Defaults: Browser default settings
# NativeMessagingHosts: Native app integration
# WebApps: Installed web applications
# profiles: Profile management data
# snapshots: Browser state snapshots
copy_browser_data "Defaults"
copy_browser_data "NativeMessagingHosts"
copy_browser_data "WebApps"
copy_browser_data "profiles"
copy_browser_data "snapshots"

echo "\x1b[34m=== Migration Complete ===\x1b[0m"
echo "\x1b[32m[INFO]\x1b[0m Please restart Orion RC to see your imported data"

