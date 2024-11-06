#!/bin/zsh

# Orion Browser Profile Migration Script
# This script migrates user data from Orion Browser to Orion RC Browser
# Including: profiles, extensions, settings, and other user data

# Base directories with full paths
ORION_DIR="${HOME}/Library/Application Support/Orion"
ORION_RC_DIR="${HOME}/Library/Application Support/Orion RC"
ORION_CONTAINER="${HOME}/Library/Containers/com.kagi.orion"
ORION_RC_CONTAINER="${HOME}/Library/Containers/com.kagi.orion-rc"
ORION_WEBKIT="${HOME}/Library/WebKit/com.kagi.kagimacOS"
ORION_RC_WEBKIT="${HOME}/Library/WebKit/com.kagi.kagimacOS.RC"
ORION_HTTP="${HOME}/Library/HTTPStorages/com.kagi.kagimacOS"
ORION_RC_HTTP="${HOME}/Library/HTTPStorages/com.kagi.kagimacOS.RC"

# Print script header
echo "\x1b[34m=== Orion Browser Migration Tool ===\x1b[0m"
echo "\x1b[32m[INFO]\x1b[0m Source: $ORION_DIR"
echo "\x1b[32m[INFO]\x1b[0m Destination: $ORION_RC_DIR"
echo "\x1b[32m[INFO]\x1b[0m Source Container: $ORION_CONTAINER"
echo "\x1b[32m[INFO]\x1b[0m Destination Container: $ORION_RC_CONTAINER"

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

# Function to copy a profile with all its data
function copy_profile() {
    local src_dir="$1"
    local profile_name="$2"
    
    echo "\x1b[32m[INFO]\x1b[0m Copying profile: $profile_name..."
    
    # Create profile directory in destination
    local dst_dir="$ORION_RC_DIR/$profile_name"
    mkdir -p "$dst_dir"
    
    # Copy profile data
    echo "\x1b[32m[INFO]\x1b[0m Copying profile data..."
    cp -rp "$src_dir/." "$dst_dir/"
    
    # Copy WebKit data if it exists
    if [ -d "$ORION_WEBKIT" ]; then
        echo "\x1b[32m[INFO]\x1b[0m Copying WebKit data..."
        mkdir -p "$ORION_RC_WEBKIT"
        cp -rp "$ORION_WEBKIT/." "$ORION_RC_WEBKIT/"
    fi
    
    # Copy HTTP Storage data if it exists
    if [ -d "$ORION_HTTP" ]; then
        echo "\x1b[32m[INFO]\x1b[0m Copying HTTP Storage data..."
        mkdir -p "$ORION_RC_HTTP"
        cp -rp "$ORION_HTTP/." "$ORION_RC_HTTP/"
    fi
    
    # Copy container data if it exists
    if [ -d "$ORION_CONTAINER/Data/Library/Application Support/Orion/$profile_name" ]; then
        echo "\x1b[32m[INFO]\x1b[0m Copying container data..."
        mkdir -p "$ORION_RC_CONTAINER/Data/Library/Application Support/Orion RC/$profile_name"
        cp -rp "$ORION_CONTAINER/Data/Library/Application Support/Orion/$profile_name/." "$ORION_RC_CONTAINER/Data/Library/Application Support/Orion RC/$profile_name/"
    fi
    
    echo "\x1b[32m[SUCCESS]\x1b[0m Copied profile: $profile_name"
}

# Copy UUID profile(s)
for uuid_dir in "$ORION_DIR"/*-*-*-*-*; do
    if [ -d "$uuid_dir" ]; then
        uuid_name=$(basename "$uuid_dir")
        copy_profile "$uuid_dir" "$uuid_name"
    fi
done

# Copy Defaults profile
if [ -d "$ORION_DIR/Defaults" ]; then
    copy_profile "$ORION_DIR/Defaults" "Defaults"
fi

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
# copy_browser_data "Defaults"
copy_browser_data "NativeMessagingHosts"
copy_browser_data "WebApps"
copy_browser_data "profiles"
copy_browser_data "snapshots"

# Add this after all profiles are copied
# Copy container structure
if [ -d "$ORION_CONTAINER" ]; then
    echo "\x1b[32m[INFO]\x1b[0m Copying container structure..."
    mkdir -p "$ORION_RC_CONTAINER"
    cp -rp "$ORION_CONTAINER/." "$ORION_RC_CONTAINER/"
fi

# Add this after all profiles are copied
# Copy additional browser data locations
echo "\x1b[32m[INFO]\x1b[0m Copying additional browser data..."

# Copy preferences
if [ -f "${HOME}/Library/Preferences/com.kagi.kagimacOS.plist" ]; then
    cp -p "${HOME}/Library/Preferences/com.kagi.kagimacOS.plist" "${HOME}/Library/Preferences/com.kagi.kagimacOS.RC.plist"
fi

# Copy saved state
if [ -d "${HOME}/Library/Saved Application State/com.kagi.kagimacOS.savedState" ]; then
    mkdir -p "${HOME}/Library/Saved Application State/com.kagi.kagimacOS.RC.savedState"
    cp -rp "${HOME}/Library/Saved Application State/com.kagi.kagimacOS.savedState/." "${HOME}/Library/Saved Application State/com.kagi.kagimacOS.RC.savedState/"
fi

echo "\x1b[34m=== Migration Complete ===\x1b[0m"
echo "\x1b[32m[INFO]\x1b[0m Please restart Orion RC to see your imported data"

