#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
EXTENSION_UUID="dock-from-dash@fthx.github.com"
EXTENSION_ID="4703"
EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"
EXTENSION_DIR="$EXTENSIONS_DIR/$EXTENSION_UUID"

echo -e "${GREEN}Starting Dock from Dash extension installation...${NC}"

# Check if GNOME Shell is installed
if ! command -v gnome-shell &> /dev/null; then
    echo -e "${RED}Error: GNOME Shell is not installed. This extension requires GNOME Shell.${NC}"
    exit 1
fi

# Get GNOME Shell version
GNOME_VERSION=$(gnome-shell --version | grep -oP '\d+\.\d+' | cut -d'.' -f1)
echo -e "${GREEN}Detected GNOME Shell version: $GNOME_VERSION${NC}"

# Ensure required dependencies are installed
echo -e "${GREEN}Installing required dependencies...${NC}"
sudo apt-get update
sudo apt-get install -y curl wget unzip jq gnome-shell-extensions

# Create extensions directory if it doesn't exist
mkdir -p "$EXTENSIONS_DIR"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Fetch extension metadata to get the correct version for the current GNOME Shell
echo -e "${GREEN}Fetching extension metadata...${NC}"
METADATA_URL="https://extensions.gnome.org/extension-info/?pk=${EXTENSION_ID}&shell_version=${GNOME_VERSION}"
EXTENSION_INFO=$(wget -q -O - "$METADATA_URL")

if [ -z "$EXTENSION_INFO" ]; then
    echo -e "${YELLOW}Warning: Could not fetch metadata for GNOME ${GNOME_VERSION}, trying alternative method...${NC}"
    # Try to get the latest version without specifying shell version
    METADATA_URL="https://extensions.gnome.org/extension-info/?pk=${EXTENSION_ID}"
    EXTENSION_INFO=$(wget -q -O - "$METADATA_URL")
fi

# Parse download URL from JSON response
DOWNLOAD_URL=$(echo "$EXTENSION_INFO" | jq -r '.download_url // empty')

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
    echo -e "${RED}Error: Could not find a compatible version for GNOME Shell ${GNOME_VERSION}${NC}"
    echo -e "${YELLOW}You may need to install this extension manually from: https://extensions.gnome.org/extension/${EXTENSION_ID}/dock-from-dash/${NC}"
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Prepend base URL if needed
if [[ "$DOWNLOAD_URL" == /download-extension/* ]]; then
    DOWNLOAD_URL="https://extensions.gnome.org${DOWNLOAD_URL}"
fi

echo -e "${GREEN}Downloading extension from: $DOWNLOAD_URL${NC}"
wget -q --show-progress "$DOWNLOAD_URL" -O extension.zip

# Remove existing installation if present
if [ -d "$EXTENSION_DIR" ]; then
    echo -e "${YELLOW}Removing existing installation...${NC}"
    rm -rf "$EXTENSION_DIR"
fi

# Create extension directory and extract
mkdir -p "$EXTENSION_DIR"
echo -e "${GREEN}Installing extension...${NC}"
unzip -q extension.zip -d "$EXTENSION_DIR"

# Verify installation
if [ ! -f "$EXTENSION_DIR/metadata.json" ]; then
    echo -e "${RED}Error: Installation failed - metadata.json not found${NC}"
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Enable the extension
echo -e "${GREEN}Enabling extension...${NC}"
gnome-extensions enable "$EXTENSION_UUID"

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Dock from Dash extension has been successfully installed!${NC}"
echo -e "${YELLOW}Note: You may need to restart GNOME Shell for the extension to take effect:${NC}"
echo -e "${YELLOW}  - Press Alt+F2, type 'r', and press Enter (X11)${NC}"
echo -e "${YELLOW}  - Or log out and log back in (Wayland)${NC}"
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}After restarting, hover over the bottom of your screen to access the dock!${NC}"

