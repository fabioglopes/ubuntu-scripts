#!/bin/bash

# Cursor Installation Script
# Compatible with Ubuntu and Debian distributions
# Supports multiple desktop environments (GNOME, KDE, XFCE, MATE)

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
APP_NAME="Cursor"

# Ensure required dependencies are installed
ensure_dependencies() {
    if ! command -v wget &> /dev/null; then
        echo -e "${GREEN}Installing wget...${NC}"
        
        # Use apt if available, otherwise fall back to apt-get
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install -y wget
        elif command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y wget
        else
            echo -e "${RED}Error: No supported package manager found (apt or apt-get)${NC}"
            exit 1
        fi
    fi
}

echo -e "${GREEN}Starting Cursor installation...${NC}"

# Detect distribution
detect_distribution

# Ensure dependencies
ensure_dependencies

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download the latest version of Cursor (deb package)
echo -e "${GREEN}Downloading Cursor deb package...${NC}"
# Get the download URL from the API for deb package
CURSOR_JSON=$(wget -q -O - "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable")
CURSOR_URL=$(echo "$CURSOR_JSON" | grep -o '"downloadUrl":"[^"]*"' | cut -d'"' -f4)

if [[ -z "$CURSOR_URL" ]]; then
    echo -e "${RED}Error: Failed to get download URL${NC}"
    exit 1
fi

# Replace .AppImage with .deb in the URL
CURSOR_DEB_URL="${CURSOR_URL/.AppImage/.deb}"

# Download the deb package
wget -q --show-progress "$CURSOR_DEB_URL" -O cursor.deb

# Install the deb package
echo -e "${GREEN}Installing Cursor deb package...${NC}"
sudo apt-get install -y ./cursor.deb

# Update desktop database
update-desktop-database ~/.local/share/applications 2>/dev/null || true

# Pin to dock using gsettings
echo -e "${GREEN}Pinning Cursor to dock...${NC}"
CURRENT_FAVORITES=$(gsettings get org.gnome.shell favorite-apps)
if [ "$CURRENT_FAVORITES" = "@as []" ]; then
    # If favorites list is empty, create new list with just Cursor
    gsettings set org.gnome.shell favorite-apps "['cursor.desktop']"
else
    # If favorites list has items, append Cursor if not already there
    if [[ ! "$CURRENT_FAVORITES" =~ "cursor.desktop" ]]; then
        gsettings set org.gnome.shell favorite-apps "$(echo "$CURRENT_FAVORITES" | sed "s/]/, 'cursor.desktop']/")"
    else
        echo "Cursor is already pinned to dock."
    fi
fi

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Cursor has been successfully installed and pinned to your dock!${NC}"
echo -e "${GREEN}You can now launch it from the applications menu or the dock.${NC}" 