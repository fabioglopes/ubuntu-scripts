#!/bin/bash

# ============================================================
# Script Name: install_cura_with_gnome46.sh
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
#              6. Verifies the file association and MIME type registration.
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
INSTALL_DIR="$HOME/.local/bin"
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
APPIMAGE_FILE="${INSTALL_DIR}/${APP_NAME}.AppImage"
ICON_FILE="${ICON_DIR}/${APP_NAME}.png"
DESKTOP_FILE="${DESKTOP_ENTRY_DIR}/${APP_NAME}.desktop"

# Create directories if they do not exist
mkdir -p "$INSTALL_DIR" "$DESKTOP_ENTRY_DIR" "$ICON_DIR"

# Download the AppImage if it doesn't exist
if [ ! -f "$APPIMAGE_FILE" ]; then
  echo "Downloading Cura AppImage..."
  curl -L "$APPIMAGE_URL" -o "$APPIMAGE_FILE"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to download Cura AppImage."
    exit 1
  fi
  chmod +x "$APPIMAGE_FILE"
else
  echo "Cura AppImage already exists, skipping download."
fi

# Download the icon if it doesn't exist
if [ ! -f "$ICON_FILE" ]; then
  echo "Downloading Cura icon..."
  curl -L "$ICON_URL" -o "$ICON_FILE"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to download Cura icon."
    exit 1
  fi
else
  echo "Cura icon already exists, skipping download."
fi

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
Categories=Graphics;3DPrinting;
EOL

# Update desktop database
if command -v update-desktop-database > /dev/null; then
  update-desktop-database "$DESKTOP_ENTRY_DIR"
fi

# Ensure MIME types are registered
echo "Registering STL MIME types..."
mkdir -p "$HOME/.local/share/mime/packages"
cat > "$HOME/.local/share/mime/packages/ultimaker-cura.xml" <<EOL
<?xml version="1.0"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
    <mime-type type="application/sla">
        <comment>STL file</comment>
        <glob pattern="*.stl"/>
    </mime-type>
    <mime-type type="application/vnd.ms-pki.stl">
        <comment>STL file</comment>
        <glob pattern="*.stl"/>
    </mime-type>
</mime-info>
EOL

# Update MIME database
update-mime-database "$HOME/.local/share/mime"

# Associate STL files with Cura
echo "Associating STL files with Cura..."
xdg-mime default "${APP_NAME}.desktop" application/sla
xdg-mime default "${APP_NAME}.desktop" application/vnd.ms-pki.stl

# Verify MIME type association
echo "Verifying MIME type association..."
xdg-mime query default application/sla
xdg-mime query default application/vnd.ms-pki.stl

echo "Ultimaker Cura installation complete! You can now launch it from your application menu and open STL files directly with Cura."

