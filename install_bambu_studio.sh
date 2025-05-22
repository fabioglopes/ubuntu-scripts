#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Variables
APP_NAME="Bambu Studio"
ICON_THEME="Yaru"
INSTALL_DIR="$HOME/.local/bin/bambu-studio"
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
APPIMAGE_FILE="${INSTALL_DIR}/bambu-studio.AppImage"
ICON_FILE="${ICON_DIR}/bambu-studio.svg"
DESKTOP_FILE="${DESKTOP_ENTRY_DIR}/bambu-studio.desktop"
STARTUP_WM_CLASS="bambu-studio"

echo -e "${GREEN}Starting Bambu Studio installation...${NC}"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Ensure directories exist
mkdir -p "$INSTALL_DIR" "$DESKTOP_ENTRY_DIR" "$ICON_DIR"

# Download the latest version of Bambu Studio
echo -e "${GREEN}Downloading Bambu Studio...${NC}"
wget -q --show-progress https://github.com/bambulab/BambuStudio/releases/download/V02.00.03.54/BambuStudio_ubuntu-22.04_PR-6688.zip

# Extract the zip file
echo -e "${GREEN}Extracting Bambu Studio...${NC}"
unzip -q BambuStudio_ubuntu-22.04_PR-6688.zip

# Move AppImage to installation directory
mv Bambu_Studio_ubuntu-22.04_PR-6688.AppImage "$APPIMAGE_FILE"

# Make AppImage executable
chmod +x "$APPIMAGE_FILE"

# Download and set icon
echo -e "${GREEN}Setting up icon...${NC}"
if [ ! -f "$ICON_FILE" ]; then
    wget -q https://raw.githubusercontent.com/bambulab/BambuStudio/master/resources/images/BambuStudio.svg -O "$ICON_FILE"
else
    echo "Bambu Studio icon already exists, skipping download."
fi

# Create desktop shortcut
echo -e "${GREEN}Creating desktop shortcut...${NC}"
cat > "$DESKTOP_FILE" << EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Bambu Studio
Comment=3D Printing Software
Exec=$APPIMAGE_FILE %U
Icon=$ICON_FILE
Terminal=false
Categories=Graphics;3DGraphics;
StartupWMClass=$STARTUP_WM_CLASS
MimeType=application/sla;application/vnd.ms-pki.stl;
X-GNOME-SingleWindow=true
EOL

# Make the desktop file executable
chmod +x "$DESKTOP_FILE"

# Update desktop database
update-desktop-database "$DESKTOP_ENTRY_DIR"

# Register STL MIME types
echo -e "${GREEN}Registering STL MIME types...${NC}"
mkdir -p "$HOME/.local/share/mime/packages"
cat > "$HOME/.local/share/mime/packages/bambu-studio.xml" << EOL
<?xml version="1.0"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
    <mime-type type="application/sla">
        <comment>STL file</comment>
        <glob pattern="*.stl"/>
        <icon name="application-sla"/>
    </mime-type>
    <mime-type type="application/vnd.ms-pki.stl">
        <comment>STL file</comment>
        <glob pattern="*.stl"/>
        <icon name="application-sla"/>
    </mime-type>
</mime-info>
EOL

# Update MIME database
echo -e "${GREEN}Updating MIME database...${NC}"
update-mime-database "$HOME/.local/share/mime"

# Associate STL files with Bambu Studio
echo -e "${GREEN}Associating STL files with Bambu Studio...${NC}"
xdg-mime default bambu-studio.desktop application/sla
xdg-mime default bambu-studio.desktop application/vnd.ms-pki.stl

# Pin to dock using gsettings
echo -e "${GREEN}Pinning Bambu Studio to dock...${NC}"
CURRENT_FAVORITES=$(gsettings get org.gnome.shell favorite-apps)
if [ "$CURRENT_FAVORITES" = "@as []" ]; then
    # If favorites list is empty, create new list with just Bambu Studio
    gsettings set org.gnome.shell favorite-apps "['bambu-studio.desktop']"
else
    # If favorites list has items, append Bambu Studio
    gsettings set org.gnome.shell favorite-apps "$(echo "$CURRENT_FAVORITES" | sed "s/]/, 'bambu-studio.desktop']/")"
fi

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

# Clear icon cache and restart Nautilus
echo -e "${GREEN}Updating icon cache...${NC}"
rm -rf ~/.cache/icon-cache.kcache
nautilus -q && nautilus &

echo -e "${GREEN}Bambu Studio has been successfully installed and pinned to your dock!${NC}"
echo -e "${GREEN}You can now launch it from the applications menu or the dock.${NC}"
echo -e "${GREEN}STL files are now associated with Bambu Studio.${NC}" 