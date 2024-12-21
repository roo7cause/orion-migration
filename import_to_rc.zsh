#!/bin/zsh

# Orion Browser Profile Migration Script
# This script migrates user data from Orion Browser to Orion RC Browser
# Author: David Kasabji
# Date: 2024-11-06

# Color codes for output formatting
COL_BLUE='\x1b[34m'
COL_CYAN='\x1b[36m'
COL_RED='\x1b[31m'
COL_YELLOW='\x1b[33m'
COL_GREEN='\x1b[32m'
COL_RESET='\x1b[0m'

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
echo "${COL_BLUE}=== Orion Browser Migration Tool ===${COL_RESET}"
echo "${COL_CYAN}[INFO]${COL_RESET} Source: $ORION_DIR"
echo "${COL_CYAN}[INFO]${COL_RESET} Destination: $ORION_RC_DIR"
echo "${COL_CYAN}[INFO]${COL_RESET} Source Container: $ORION_CONTAINER"
echo "${COL_CYAN}[INFO]${COL_RESET} Destination Container: $ORION_RC_CONTAINER"

# Validate source directory exists
if [ ! -d "$ORION_DIR" ]; then
    echo "${COL_RED}[ERROR]${COL_RESET} Source directory not found. Is Orion Browser installed?"
    exit 1
fi

# Check if destination directory exists and handle it
if [ -d "$ORION_RC_DIR" ]; then
    echo "${COL_YELLOW}[WARNING]${COL_RESET} Destination directory already exists."
    echo "Choose an option:"
    echo "1) Backup existing data and continue"
    echo "2) Remove existing data and continue"
    echo "3) Exit"
    read "choice?Enter your choice (1-3): "
    
    case $choice in
        1)
            backup_dir="${ORION_RC_DIR}_backup_$(date '+%Y%m%d_%H%M%S')"
            echo "${COL_CYAN}[INFO]${COL_RESET} Backing up existing data to: $backup_dir"
            mv "$ORION_RC_DIR" "$backup_dir"
            ;;
        2)
            echo "${COL_CYAN}[INFO]${COL_RESET} Removing existing data..."
            rm -rf "$ORION_RC_DIR"
            ;;
        3)
            echo "${COL_RED}[EXIT]${COL_RESET} Migration cancelled by user"
            exit 0
            ;;
        *)
            echo "${COL_RED}[ERROR]${COL_RESET} Invalid choice"
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
    
    echo "${COL_CYAN}[INFO]${COL_RESET} Copying profile: $profile_name..."
    
    # Create profile directory in destination
    local dst_dir="$ORION_RC_DIR/$profile_name"
    mkdir -p "$dst_dir"
    
    # Copy profile data
    echo "${COL_CYAN}[INFO]${COL_RESET} Copying profile data..."
    cp -rp "$src_dir/." "$dst_dir/"
    
    # Copy WebKit data if it exists
    if [ -d "$ORION_WEBKIT" ]; then
        echo "${COL_CYAN}[INFO]${COL_RESET} Copying WebKit data..."
        mkdir -p "$ORION_RC_WEBKIT"
        cp -rp "$ORION_WEBKIT/." "$ORION_RC_WEBKIT/"
    fi
    
    # Copy HTTP Storage data if it exists
    if [ -d "$ORION_HTTP" ]; then
        echo "${COL_CYAN}[INFO]${COL_RESET} Copying HTTP Storage data..."
        mkdir -p "$ORION_RC_HTTP"
        cp -rp "$ORION_HTTP/." "$ORION_RC_HTTP/"
    fi
    
    # Copy container data if it exists
    if [ -d "$ORION_CONTAINER/Data/Library/Application Support/Orion/$profile_name" ]; then
        echo "${COL_CYAN}[INFO]${COL_RESET} Copying container data..."
        mkdir -p "$ORION_RC_CONTAINER/Data/Library/Application Support/Orion RC/$profile_name"
        cp -rp "$ORION_CONTAINER/Data/Library/Application Support/Orion/$profile_name/." "$ORION_RC_CONTAINER/Data/Library/Application Support/Orion RC/$profile_name/"
    fi
    
    echo "${COL_GREEN}[SUCCESS]${COL_RESET} Copied profile: $profile_name"
}

# Copy UUID profile(s)
uuid_dirs=("$ORION_DIR"/*-*-*-*-*-*)
if [ -d "${uuid_dirs[1]}" ]; then
    for uuid_dir in "$ORION_DIR"/*-*-*-*-*-*; do
        if [ -d "$uuid_dir" ]; then
            uuid_name=$(basename "$uuid_dir")
            copy_profile "$uuid_dir" "$uuid_name"
        fi
    done
else
    echo "${COL_YELLOW}[SKIP]${COL_RESET} No UUID profiles found"
fi

# Copy Defaults profile
if [ -d "$ORION_DIR/Defaults" ]; then
    copy_profile "$ORION_DIR/Defaults" "Defaults"
fi

# Function to copy browser data directories and files
function copy_browser_data() {
    local src="$ORION_DIR/$1"
    local dst="$ORION_RC_DIR/$1"
    
    echo "${COL_CYAN}[INFO]${COL_RESET} Copying $1..."
    if [ -e "$src" ]; then
        cp -r "$src" "$dst"
        echo "${COL_GREEN}[SUCCESS]${COL_RESET} Copied $1"
    else
        echo "${COL_YELLOW}[SKIP]${COL_RESET} Optional component $1 not found"
    fi
}

# Copy essential browser components
copy_browser_data "NativeMessagingHosts"
copy_browser_data "WebApps"
copy_browser_data "profiles"
copy_browser_data "snapshots"

# Copy container structure
if [ -d "$ORION_CONTAINER" ]; then
    echo "${COL_CYAN}[INFO]${COL_RESET} Copying container structure..."
    mkdir -p "$ORION_RC_CONTAINER"
    cp -rp "$ORION_CONTAINER/." "$ORION_RC_CONTAINER/"
fi

# Copy additional browser data locations
echo "${COL_CYAN}[INFO]${COL_RESET} Copying additional browser data..."

# Copy preferences (contains pinned tabs)
if [ -f "${HOME}/Library/Preferences/com.kagi.kagimacOS.plist" ]; then
    cp -p "${HOME}/Library/Preferences/com.kagi.kagimacOS.plist" "${HOME}/Library/Preferences/com.kagi.kagimacOS.RC.plist"
fi

# Copy saved state
if [ -d "${HOME}/Library/Saved Application State/com.kagi.kagimacOS.savedState" ]; then
    mkdir -p "${HOME}/Library/Saved Application State/com.kagi.kagimacOS.RC.savedState"
    cp -rp "${HOME}/Library/Saved Application State/com.kagi.kagimacOS.savedState/." "${HOME}/Library/Saved Application State/com.kagi.kagimacOS.RC.savedState/"
fi

echo "${COL_BLUE}=== Migration Complete ===${COL_RESET}"
echo "${COL_CYAN}[INFO]${COL_RESET} Please restart Orion RC to see your imported data"

