#!/bin/bash

# ============================================================
# Script Name: install_cura_with_yaru.sh
# Description: This script automates the installation of Ultimaker Cura,
#              a popular 3D printing slicing software, for Ubuntu systems 
#              running GNOME 46.2. It performs the following tasks:
#
#              1. Downloads the Cura AppImage from the official GitHub release page
#                 (if it is not already downloaded).
#              2. Downloads a corresponding Cura icon (if it is not already downloaded).
#              3. Makes the AppImage executable and installs it to the user's 
#                 local binaries folder (~/.local/bin).
#              4. Creates a desktop entry file (~/.local/share/applications) so that 
#                 Cura appears in the application menu with a proper icon.
#              5. Registers STL file MIME types (application/sla and 
#                 application/vnd.ms-pki.stl) and associates these file types 
#                 with Ultimaker Cura, enabling double-click to open STL files.
#              6. Sets Cura's icon for `.stl` files in the active Yaru theme.
#              7. Verifies the file association and MIME type registration.
#
# Author: Fabio Lopes
# Date: 2024-12-04
# Usage: Run the script directly. Ensure you have curl installed.
#
# Requirements:
# - curl for downloading the AppImage and icon
# - GNOME environment (tested on GNOME 46.2)
# ============================================================

# Variables
APPIMAGE_URL="https://github.com/Ultimaker/Cura/releases/download/5.9.0/UltiMaker-Cura-5.9.0-linux-X64.AppImage"
ICON_URL="https://raw.githubusercontent.com/Ultimaker/Cura/master/resources/images/cura-icon.png"
APP_NAME="Ultimaker-Cura"
ICON_THEME="Yaru"
INSTALL_DIR="$HOME/.local/bin"
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
MIME_ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/mimetypes"
APPIMAGE_FILE="${INSTALL_DIR}/${APP_NAME}.AppImage"
ICON_FILE="${ICON_DIR}/application-sla.png"
YARU_MIME_ICON_FILE="/usr/share/icons/${ICON_THEME}/256x256/mimetypes/application-sla.png"
DESKTOP_FILE="${DESKTOP_ENTRY_DIR}/${APP_NAME}.desktop"

# Ensure directories exist
mkdir -p "$INSTALL_DIR" "$DESKTOP_ENTRY_DIR" "$ICON_DIR" "$MIME_ICON_DIR"

# Download the AppImage
if [ ! -f "$APPIMAGE_FILE" ]; then
  echo "Downloading Cura AppImage..."
  curl -L "$APPIMAGE_URL" -o "$APPIMAGE_FILE"
  chmod +x "$APPIMAGE_FILE"
else
  echo "Cura AppImage already exists, skipping download."
fi

# Download the icon
if [ ! -f "$ICON_FILE" ]; then
  echo "Downloading Cura icon..."
  curl -L "$ICON_URL" -o "$ICON_FILE"
else
  echo "Cura icon already exists, skipping download."
fi

# Copy the icon for STL MIME types in the Yaru theme
echo "Setting Cura icon for STL files in the Yaru theme..."
sudo mkdir -p "/usr/share/icons/${ICON_THEME}/256x256/mimetypes"
sudo cp "$ICON_FILE" "$YARU_MIME_ICON_FILE"

# Update Yaru icon cache
echo "Updating the Yaru icon cache..."
sudo gtk-update-icon-cache "/usr/share/icons/${ICON_THEME}"

# Create a .desktop file
echo "Creating desktop entry for Cura..."
cat > "$DESKTOP_FILE" <<EOL
[Desktop Entry]
Type=Application
Name=Ultimaker Cura
Exec=${APPIMAGE_FILE} %U
Icon=${ICON_FILE}
Terminal=false
MimeType=application/sla;application/vnd.ms-pki.stl;
Categories=Graphics;X-3DPrinting;
EOL

# Update desktop database
echo "Updating desktop database..."
update-desktop-database "$DESKTOP_ENTRY_DIR"

# Register STL MIME types
echo "Registering STL MIME types..."
mkdir -p "$HOME/.local/share/mime/packages"
cat > "$HOME/.local/share/mime/packages/ultimaker-cura.xml" <<EOL
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
echo "Updating MIME database..."
update-mime-database "$HOME/.local/share/mime"

# Associate STL files with Cura
echo "Associating STL files with Cura..."
xdg-mime default "${APP_NAME}.desktop" application/sla
xdg-mime default "${APP_NAME}.desktop" application/vnd.ms-pki.stl

# Restart Nautilus
echo "Restarting Nautilus..."
nautilus -q && nautilus &

echo "Ultimaker Cura installation complete! STL files are now associated with Cura, and the Cura icon is displayed in Nautilus."

