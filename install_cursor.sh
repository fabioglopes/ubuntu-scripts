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
INSTALL_DIR="$HOME/.local/bin/cursor"
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
APPIMAGE_FILE="${INSTALL_DIR}/cursor.AppImage"
ICON_FILE="${ICON_DIR}/cursor.png"
DESKTOP_FILE="${DESKTOP_ENTRY_DIR}/cursor.desktop"
STARTUP_WM_CLASS="Cursor"

# Detect distribution
detect_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="$ID"
        DISTRO_NAME="$NAME"
    else
        echo -e "${RED}Error: Cannot detect distribution. /etc/os-release not found.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Detected distribution: $DISTRO_NAME${NC}"
}

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

# Create Cursor icon (simple approach to avoid system conflicts)
echo -e "${GREEN}Setting up Cursor icon...${NC}"

# Extract and create icon from AppImage
if [ ! -f "$ICON_FILE" ]; then
    echo -e "${GREEN}Extracting Cursor icon from AppImage...${NC}"
    
    # Extract the real icon from the AppImage
    if [ -f "$APPIMAGE_FILE" ]; then
        # Extract icon files from AppImage
        "$APPIMAGE_FILE" --appimage-extract "*.png" 2>/dev/null >/dev/null
        
        # Look for the Cursor icon
        if [ -f "squashfs-root/co.anysphere.cursor.png" ]; then
            cp "squashfs-root/co.anysphere.cursor.png" "$ICON_FILE"
            echo -e "${GREEN}Extracted real Cursor icon from AppImage${NC}"
        elif [ -f "squashfs-root/cursor.png" ]; then
            cp "squashfs-root/cursor.png" "$ICON_FILE"
            echo -e "${GREEN}Extracted Cursor icon from AppImage${NC}"
        else
            # Find any PNG that might be the icon
            FOUND_ICON=$(find squashfs-root -name "*.png" -type f | head -1)
            if [ -n "$FOUND_ICON" ]; then
                cp "$FOUND_ICON" "$ICON_FILE"
                echo -e "${GREEN}Extracted icon from AppImage: $(basename "$FOUND_ICON")${NC}"
            else
                echo -e "${YELLOW}No icon found in AppImage, creating placeholder...${NC}"
                # Create SVG placeholder as fallback
                cat > "$ICON_FILE" << 'EOL'
<svg width="256" height="256" xmlns="http://www.w3.org/2000/svg">
  <rect width="256" height="256" rx="32" fill="#007ACC"/>
  <text x="128" y="128" text-anchor="middle" dy=".3em" fill="white" font-family="Arial, sans-serif" font-size="80" font-weight="bold">C</text>
</svg>
EOL
            fi
        fi
        
        # Clean up extraction
        rm -rf squashfs-root 2>/dev/null || true
    else
        echo -e "${RED}AppImage not found, cannot extract icon${NC}"
    fi
else
    echo "Cursor icon already exists, skipping creation."
fi

# Create desktop shortcut
echo -e "${GREEN}Creating desktop shortcut...${NC}"
# Use full path to avoid theme conflicts
if [ -f "$ICON_FILE" ] && [ -s "$ICON_FILE" ]; then
    ICON_LINE="Icon=$ICON_FILE"
else
    ICON_LINE="Icon=text-editor"
    echo -e "${YELLOW}Using system default icon for desktop entry${NC}"
fi

cat > "$DESKTOP_FILE" << EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Cursor
Comment=AI-first code editor
Exec=$APPIMAGE_FILE --no-sandbox %U
$ICON_LINE
Terminal=false
Categories=Development;TextEditor;IDE;
StartupWMClass=$STARTUP_WM_CLASS
X-GNOME-SingleWindow=true
MimeType=text/plain;inode/directory;application/x-code-workspace;
EOL

# Make the desktop file executable
chmod +x "$DESKTOP_FILE"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_ENTRY_DIR"
else
    echo -e "${YELLOW}Warning: update-desktop-database not found, skipping desktop database update${NC}"
fi

# Pin to dock/taskbar (GNOME Shell specific)
pin_to_dock() {
    if command -v gsettings &> /dev/null; then
        echo -e "${GREEN}Pinning Cursor to dock...${NC}"
        CURRENT_FAVORITES=$(gsettings get org.gnome.shell favorite-apps 2>/dev/null || echo "@as []")
        if [ "$CURRENT_FAVORITES" = "@as []" ]; then
            # If favorites list is empty, create new list with just Cursor
            gsettings set org.gnome.shell favorite-apps "['cursor.desktop']" 2>/dev/null || true
        else
            # If favorites list has items, append Cursor
            gsettings set org.gnome.shell favorite-apps "$(echo "$CURRENT_FAVORITES" | sed "s/]/, 'cursor.desktop']/")" 2>/dev/null || true
        fi
    else
        echo -e "${YELLOW}Warning: gsettings not found, skipping dock pinning${NC}"
    fi
}

# Detect desktop environment and handle accordingly
detect_desktop_environment() {
    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
        DESKTOP_ENV="$XDG_CURRENT_DESKTOP"
    elif [ -n "$DESKTOP_SESSION" ]; then
        DESKTOP_ENV="$DESKTOP_SESSION"
    else
        DESKTOP_ENV="unknown"
    fi
    
    echo -e "${GREEN}Detected desktop environment: $DESKTOP_ENV${NC}"
    
    # Handle different desktop environments
    case "$DESKTOP_ENV" in
        *"GNOME"*|*"gnome"*)
            pin_to_dock
            ;;
        *"KDE"*|*"kde"*|*"plasma"*)
            echo -e "${YELLOW}KDE detected. You may need to manually add Cursor to your favorites.${NC}"
            ;;
        *"XFCE"*|*"xfce"*)
            echo -e "${YELLOW}XFCE detected. You may need to manually add Cursor to your panel.${NC}"
            ;;
        *"MATE"*|*"mate"*)
            echo -e "${YELLOW}MATE detected. You may need to manually add Cursor to your panel.${NC}"
            ;;
        *)
            echo -e "${YELLOW}Unknown desktop environment. You may need to manually add Cursor to your favorites/panel.${NC}"
            ;;
    esac
}

# Detect and handle desktop environment
detect_desktop_environment

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

# Clear icon cache and restart file manager (simplified approach like Bambu Studio)
echo -e "${GREEN}Updating icon cache...${NC}"
rm -rf ~/.cache/icon-cache.kcache 2>/dev/null || true
rm -rf ~/.cache/thumbnails 2>/dev/null || true

# Update icon cache properly
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$ICON_DIR" 2>/dev/null || true
fi

# Restart file manager to refresh icons
if command -v nautilus &> /dev/null; then
    nautilus -q && nautilus &
elif command -v thunar &> /dev/null; then
    thunar -q && thunar &
elif command -v dolphin &> /dev/null; then
    dolphin -q && dolphin &
else
    echo -e "${YELLOW}No supported file manager found for icon cache refresh${NC}"
fi

echo -e "${GREEN}Cursor has been successfully installed!${NC}"
echo -e "${GREEN}You can now launch it from the applications menu.${NC}"
if [[ "$DESKTOP_ENV" == *"GNOME"* ]]; then
    echo -e "${GREEN}It has also been pinned to your dock.${NC}"
fi 