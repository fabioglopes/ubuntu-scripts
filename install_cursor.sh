#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
APP_NAME="Cursor"
INSTALL_DIR="$HOME/.local/bin/cursor"
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
API_URL="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
ICON_URL="https://us1.discourse-cdn.com/flex020/uploads/cursor1/original/2X/a/a4f78589d63edd61a2843306f8e11bad9590f0ca.png"
APPIMAGE_FILE="${INSTALL_DIR}/cursor.AppImage"
ICON_FILE="${ICON_DIR}/cursor.png"
DESKTOP_FILE="${DESKTOP_ENTRY_DIR}/cursor.desktop"
STARTUP_WM_CLASS="Cursor"

# Cursor shell function to be added to config files
read -r -d '' CURSOR_FUNCTION << 'EOL'
# Cursor AI IDE launcher function
function cursor() {
    local args=""
    if [ $# -eq 0 ]; then
        args=$(pwd)
    else
        for arg in "$@"; do
            args="$args $arg"
        done
    fi
    local executable="$HOME/.local/bin/cursor/cursor.AppImage"
    (nohup $executable --no-sandbox "$args" >/dev/null 2>&1 &)
}
EOL

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

# Ensure required dependencies are installed
ensure_dependencies() {
    if ! command -v curl &> /dev/null; then
        echo -e "${GREEN}Installing curl...${NC}"
        sudo apt-get update
        sudo apt-get install -y curl
    fi
}

# Check if Cursor is currently running
check_cursor_running() {
    if pgrep -f "cursor.AppImage" > /dev/null; then
        return 0  # Cursor is running
    else
        return 1  # Cursor is not running
    fi
}

# Fetch the latest version information from the Cursor API
fetch_latest_version() {
    local api_response
    api_response=$(curl -s "$API_URL")
    CURSOR_URL=$(echo "$api_response" | grep -o '"downloadUrl":"[^"]*"' | cut -d'"' -f4)
    LATEST_VERSION=$(echo "$api_response" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)

    if [[ -z "$CURSOR_URL" || -z "$LATEST_VERSION" ]]; then
        echo -e "${RED}Error: Failed to fetch version information from API${NC}"
        return 1
    fi

    return 0
}

# Get the currently installed version of Cursor
get_current_version() {
    if [[ -f "$APPIMAGE_FILE" ]]; then
        CURRENT_VERSION=$("$APPIMAGE_FILE" --version 2>/dev/null | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+" | head -1)
        if [[ -z "$CURRENT_VERSION" ]]; then
            CURRENT_VERSION="unknown"
        fi
    else
        CURRENT_VERSION="not installed"
    fi
}

# Determine and get the appropriate shell config file
get_shell_config_file() {
    local shell_path=$(echo "$SHELL")
    local config_file=""

    case "$shell_path" in
        */zsh)
            if [[ -f "$HOME/.zshrc" ]]; then
                config_file="$HOME/.zshrc"
            else
                touch "$HOME/.zshrc"
                config_file="$HOME/.zshrc"
            fi
            ;;
        */bash)
            if [[ -f "$HOME/.bashrc" ]]; then
                config_file="$HOME/.bashrc"
            else
                touch "$HOME/.bashrc"
                config_file="$HOME/.bashrc"
            fi
            ;;
        *)
            if [[ -f "$HOME/.bashrc" ]]; then
                config_file="$HOME/.bashrc"
            else
                touch "$HOME/.bashrc"
                config_file="$HOME/.bashrc"
            fi
            ;;
    esac

    echo "$config_file"
}

# Add the cursor function to shell configuration if it doesn't exist
setup_shell_function() {
    local config_file=$(get_shell_config_file)

    echo -e "${GREEN}Checking for existing cursor function in $config_file...${NC}"

    if grep -q "function cursor()" "$config_file"; then
        echo -e "${GREEN}Cursor function already exists in $config_file. No changes needed.${NC}"
        return 0
    fi

    echo -e "${GREEN}Adding cursor function to $config_file...${NC}"
    echo -e "\n$CURSOR_FUNCTION" >> "$config_file"
    echo -e "${GREEN}Cursor function added to $config_file.${NC}"
    echo -e "${GREEN}Please restart your terminal or run 'source $config_file' to use the cursor command.${NC}"

    return 0
}

# -----------------------------------------------------------------------------
# Main Installation
# -----------------------------------------------------------------------------

echo -e "${GREEN}Starting Cursor installation...${NC}"

# Ensure dependencies
ensure_dependencies

# Check if Cursor is running
if check_cursor_running; then
    echo -e "${RED}Error: Cursor is currently running.${NC}"
    echo -e "${RED}Please close all instances of Cursor and try again.${NC}"
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Ensure directories exist
mkdir -p "$INSTALL_DIR" "$DESKTOP_ENTRY_DIR" "$ICON_DIR"

# Fetch latest version
if ! fetch_latest_version; then
    echo -e "${RED}Installation failed. Could not get latest version information.${NC}"
    exit 1
fi

# Download Cursor AppImage
echo -e "${GREEN}Downloading Cursor version $LATEST_VERSION...${NC}"
curl -L "$CURSOR_URL" -o "$APPIMAGE_FILE"

# Make AppImage executable
chmod +x "$APPIMAGE_FILE"

# Download and set icon
echo -e "${GREEN}Setting up icon...${NC}"
if [ ! -f "$ICON_FILE" ]; then
    curl -L "$ICON_URL" -o "$ICON_FILE"
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

# Setup shell function
setup_shell_function

# Pin to dock using gsettings
echo -e "${GREEN}Pinning Cursor to dock...${NC}"
CURRENT_FAVORITES=$(gsettings get org.gnome.shell favorite-apps)
if [ "$CURRENT_FAVORITES" = "@as []" ]; then
    gsettings set org.gnome.shell favorite-apps "['cursor.desktop']"
else
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
echo -e "${GREEN}You can now launch it from the applications menu, the dock, or by typing 'cursor' in your terminal.${NC}" 