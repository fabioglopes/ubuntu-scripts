#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Variables
APP_NAME="Cursor"
INSTALL_DIR="$HOME/.local/bin/cursor"
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
APPIMAGE_FILE="${INSTALL_DIR}/cursor.AppImage"
ICON_FILE="${ICON_DIR}/cursor.png"
DESKTOP_FILE="${DESKTOP_ENTRY_DIR}/cursor.desktop"
STARTUP_WM_CLASS="Cursor"

# Ensure required dependencies are installed
ensure_dependencies() {
    if ! command -v wget &> /dev/null; then
        echo -e "${GREEN}Installing wget...${NC}"
        sudo apt-get update
        sudo apt-get install -y wget
    fi
}

echo -e "${GREEN}Starting Cursor installation...${NC}"

# Ensure dependencies
ensure_dependencies


# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Ensure directories exist
mkdir -p "$INSTALL_DIR" "$DESKTOP_ENTRY_DIR" "$ICON_DIR"

# Download the latest version of Cursor
echo -e "${GREEN}Downloading Cursor...${NC}"
# First get the download URL from the API
CURSOR_JSON=$(wget -q -O - "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable")
CURSOR_URL=$(echo "$CURSOR_JSON" | grep -o '"downloadUrl":"[^"]*"' | cut -d'"' -f4)

if [[ -z "$CURSOR_URL" ]]; then
    echo -e "${RED}Error: Failed to get download URL${NC}"
    exit 1
fi

# Download the actual AppImage
wget -q --show-progress "$CURSOR_URL" -O cursor.AppImage

# Move AppImage to installation directory
mv cursor.AppImage "$APPIMAGE_FILE"

# Make AppImage executable
chmod +x "$APPIMAGE_FILE"

# Download and set icon
echo -e "${GREEN}Setting up icon...${NC}"
if [ ! -f "$ICON_FILE" ]; then
    wget -q https://us1.discourse-cdn.com/flex020/uploads/cursor1/original/2X/a/a4f78589d63edd61a2843306f8e11bad9590f0ca.png -O "$ICON_FILE"
else
    echo "Cursor icon already exists, skipping download."
fi

# Create desktop shortcut
echo -e "${GREEN}Creating desktop shortcut...${NC}"
cat > "$DESKTOP_FILE" << EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Cursor
Comment=AI-first code editor
Exec=$APPIMAGE_FILE --no-sandbox %U
Icon=$ICON_FILE
Terminal=false
Categories=Development;TextEditor;IDE;
StartupWMClass=$STARTUP_WM_CLASS
X-GNOME-SingleWindow=true
MimeType=text/plain;inode/directory;application/x-code-workspace;
EOL

# Make the desktop file executable
chmod +x "$DESKTOP_FILE"

# Update desktop database
update-desktop-database "$DESKTOP_ENTRY_DIR"

# Pin to dock using gsettings
echo -e "${GREEN}Pinning Cursor to dock...${NC}"
CURRENT_FAVORITES=$(gsettings get org.gnome.shell favorite-apps)
if [ "$CURRENT_FAVORITES" = "@as []" ]; then
    # If favorites list is empty, create new list with just Cursor
    gsettings set org.gnome.shell favorite-apps "['cursor.desktop']"
else
    # If favorites list has items, append Cursor
    gsettings set org.gnome.shell favorite-apps "$(echo "$CURRENT_FAVORITES" | sed "s/]/, 'cursor.desktop']/")"
fi

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

# Clear icon cache and restart Nautilus
echo -e "${GREEN}Updating icon cache...${NC}"
rm -rf ~/.cache/icon-cache.kcache
nautilus -q && nautilus &

echo -e "${GREEN}Cursor has been successfully installed and pinned to your dock!${NC}"
echo -e "${GREEN}You can now launch it from the applications menu or the dock.${NC}" 