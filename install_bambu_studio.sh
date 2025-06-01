#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Variables
APP_NAME="Bambu Studio"
INSTALL_DIR="$HOME/.local/bin/bambu-studio"
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
APPIMAGE_FILE="${INSTALL_DIR}/bambu-studio.AppImage"
ICON_FILE="${ICON_DIR}/bambu-studio.png"
DESKTOP_FILE="${DESKTOP_ENTRY_DIR}/bambu-studio.desktop"
STARTUP_WM_CLASS="BambuStudio"

# Ensure required dependencies are installed
ensure_dependencies() {
    echo -e "${GREEN}Checking dependencies...${NC}"
    local packages_to_install=""
    
    # Check for required packages
    if ! dpkg -l | grep -q libwebkit2gtk-4.1-0; then
        packages_to_install="$packages_to_install libwebkit2gtk-4.1-0"
    fi
    
    if ! command -v wget &> /dev/null; then
        packages_to_install="$packages_to_install wget"
    fi
    
    if ! command -v unzip &> /dev/null; then
        packages_to_install="$packages_to_install unzip"
    fi
    
    if [ -n "$packages_to_install" ]; then
        echo -e "${GREEN}Installing required dependencies:$packages_to_install${NC}"
        sudo apt-get update
        sudo apt-get install -y $packages_to_install
    fi
    
    # Create symlinks for WebKit compatibility (Ubuntu 24.04 compatibility)
    echo -e "${GREEN}Setting up WebKit compatibility...${NC}"
    if [ ! -f "/usr/lib/x86_64-linux-gnu/libwebkit2gtk-4.0.so.37" ]; then
        sudo ln -sf /usr/lib/x86_64-linux-gnu/libwebkit2gtk-4.1.so.0 /usr/lib/x86_64-linux-gnu/libwebkit2gtk-4.0.so.37
    fi
    
    if [ ! -f "/usr/lib/x86_64-linux-gnu/libjavascriptcoregtk-4.0.so.18" ]; then
        sudo ln -sf /usr/lib/x86_64-linux-gnu/libjavascriptcoregtk-4.1.so.0 /usr/lib/x86_64-linux-gnu/libjavascriptcoregtk-4.0.so.18
    fi
}

echo -e "${GREEN}Starting Bambu Studio installation...${NC}"

# Ensure dependencies
ensure_dependencies

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Ensure directories exist
mkdir -p "$INSTALL_DIR" "$DESKTOP_ENTRY_DIR" "$ICON_DIR"

# Download the latest version of Bambu Studio
echo -e "${GREEN}Fetching latest Bambu Studio release information...${NC}"
LATEST_RELEASE_JSON=$(wget -q -O - "https://api.github.com/repos/bambulab/BambuStudio/releases/latest")
LATEST_VERSION=$(echo "$LATEST_RELEASE_JSON" | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)

if [[ -z "$LATEST_VERSION" ]]; then
    echo -e "${RED}Error: Failed to get latest version information${NC}"
    exit 1
fi

echo -e "${GREEN}Latest version found: $LATEST_VERSION${NC}"

# Find the Ubuntu download URL from the latest release
DOWNLOAD_URL=$(echo "$LATEST_RELEASE_JSON" | grep -o '"browser_download_url": "[^"]*ubuntu[^"]*\.zip"' | cut -d'"' -f4 | head -1)

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo -e "${RED}Error: No Ubuntu download found for version $LATEST_VERSION${NC}"
    exit 1
fi

echo -e "${GREEN}Downloading Bambu Studio $LATEST_VERSION...${NC}"
DOWNLOAD_FILENAME=$(basename "$DOWNLOAD_URL")
wget -q --show-progress "$DOWNLOAD_URL"

# Extract the zip file
echo -e "${GREEN}Extracting Bambu Studio...${NC}"
unzip -q "$DOWNLOAD_FILENAME"

# Find the AppImage file (it might have a different name based on version)
APPIMAGE_SOURCE=$(find . -name "*.AppImage" -type f | head -1)

if [[ -z "$APPIMAGE_SOURCE" ]]; then
    echo -e "${RED}Error: No AppImage found in the downloaded archive${NC}"
    exit 1
fi

echo -e "${GREEN}Found AppImage: $APPIMAGE_SOURCE${NC}"

# Move AppImage to installation directory
mv "$APPIMAGE_SOURCE" "$APPIMAGE_FILE"

# Make AppImage executable
chmod +x "$APPIMAGE_FILE"

# Download and set icon (convert SVG to PNG for better compatibility)
echo -e "${GREEN}Setting up icon...${NC}"
if [ ! -f "$ICON_FILE" ]; then
    # Download SVG and convert to PNG with transparent background
    wget -q https://raw.githubusercontent.com/bambulab/BambuStudio/master/resources/images/BambuStudio.svg -O bambu-studio.svg
    # Convert SVG to PNG with transparent background using the best available tool
    if command -v inkscape &> /dev/null; then
        inkscape bambu-studio.svg --export-type=png --export-filename="$ICON_FILE" --export-width=256 --export-height=256 --export-background-opacity=0
    elif command -v convert &> /dev/null; then
        convert bambu-studio.svg -background transparent -resize 256x256 "$ICON_FILE"
    elif command -v rsvg-convert &> /dev/null; then
        rsvg-convert -w 256 -h 256 -b transparent bambu-studio.svg -o "$ICON_FILE"
    else
        # Fallback: try to download a PNG version or use the SVG as-is
        echo "Warning: No SVG converter found, trying fallback icon"
        wget -q https://github.com/bambulab/BambuStudio/raw/master/resources/images/BambuStudio_128.png -O "$ICON_FILE" || cp bambu-studio.svg "$ICON_FILE"
    fi
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
Categories=Graphics;3DGraphics;Engineering;
StartupWMClass=$STARTUP_WM_CLASS
MimeType=model/stl;application/sla;application/vnd.ms-pki.stl;model/x.stl-ascii;model/x.stl-binary;
X-GNOME-SingleWindow=true
EOL

# Make the desktop file executable
chmod +x "$DESKTOP_FILE"

# Update desktop database
update-desktop-database "$DESKTOP_ENTRY_DIR"

# Register STL MIME types with proper definitions
echo -e "${GREEN}Registering STL MIME types...${NC}"
mkdir -p "$HOME/.local/share/mime/packages"
cat > "$HOME/.local/share/mime/packages/bambu-studio.xml" << EOL
<?xml version="1.0"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
    <mime-type type="model/stl">
        <comment>STL 3D Model</comment>
        <comment xml:lang="en">STL 3D Model</comment>
        <glob pattern="*.stl"/>
        <glob pattern="*.STL"/>
        <magic priority="50">
            <match value="solid" type="string" offset="0"/>
        </magic>
        <icon name="model-stl"/>
    </mime-type>
    <mime-type type="application/sla">
        <comment>SLA 3D Model</comment>
        <comment xml:lang="en">SLA 3D Model</comment>
        <glob pattern="*.stl"/>
        <glob pattern="*.STL"/>
        <icon name="model-stl"/>
    </mime-type>
    <mime-type type="application/vnd.ms-pki.stl">
        <comment>STL 3D Model (Microsoft)</comment>
        <comment xml:lang="en">STL 3D Model (Microsoft)</comment>
        <glob pattern="*.stl"/>
        <glob pattern="*.STL"/>
        <icon name="model-stl"/>
    </mime-type>
    <mime-type type="model/x.stl-ascii">
        <comment>STL 3D Model (ASCII)</comment>
        <comment xml:lang="en">STL 3D Model (ASCII)</comment>
        <glob pattern="*.stl"/>
        <glob pattern="*.STL"/>
        <icon name="model-stl"/>
    </mime-type>
    <mime-type type="model/x.stl-binary">
        <comment>STL 3D Model (Binary)</comment>
        <comment xml:lang="en">STL 3D Model (Binary)</comment>
        <glob pattern="*.stl"/>
        <glob pattern="*.STL"/>
        <icon name="model-stl"/>
    </mime-type>
</mime-info>
EOL

# Update MIME database
echo -e "${GREEN}Updating MIME database...${NC}"
update-mime-database "$HOME/.local/share/mime"

# Set up MIME type icon for STL files
echo -e "${GREEN}Setting up MIME type icon for STL files...${NC}"
mkdir -p "$HOME/.local/share/icons/hicolor/{48x48,128x128,256x256}/mimetypes"

# Create multiple sizes of the model-stl icon
convert "$ICON_FILE" -resize 48x48 "$HOME/.local/share/icons/hicolor/48x48/mimetypes/model-stl.png"
convert "$ICON_FILE" -resize 128x128 "$HOME/.local/share/icons/hicolor/128x128/mimetypes/model-stl.png"
cp "$ICON_FILE" "$HOME/.local/share/icons/hicolor/256x256/mimetypes/model-stl.png"

# Also override the application-x-3dmf icon which takes precedence for STL files
cp "$HOME/.local/share/icons/hicolor/48x48/mimetypes/model-stl.png" "$HOME/.local/share/icons/hicolor/48x48/mimetypes/application-x-3dmf.png"
cp "$HOME/.local/share/icons/hicolor/128x128/mimetypes/model-stl.png" "$HOME/.local/share/icons/hicolor/128x128/mimetypes/application-x-3dmf.png"
cp "$HOME/.local/share/icons/hicolor/256x256/mimetypes/model-stl.png" "$HOME/.local/share/icons/hicolor/256x256/mimetypes/application-x-3dmf.png"

gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

# Replace system STL icons in Yaru theme (this ensures the icons actually show up)
echo -e "${GREEN}Replacing system STL icons with Bambu Studio icon...${NC}"
if [ -f "/usr/share/icons/Yaru/16x16/mimetypes/model-stl.png" ]; then
    # Save the SVG for system icon replacement
    cp bambu-studio.svg "$HOME/.local/share/icons/bambu-studio.svg" 2>/dev/null || true
    
    # Replace system STL icons with Bambu Studio icon
    for size in 16 24 32 48 256; do
        if [ -f "/usr/share/icons/Yaru/${size}x${size}/mimetypes/model-stl.png" ]; then
            # Create Bambu Studio icon at the correct size
            temp_icon="/tmp/bambu-system-${size}.png"
            if command -v inkscape &> /dev/null; then
                inkscape bambu-studio.svg --export-type=png --export-filename="$temp_icon" --export-width=$size --export-height=$size --export-background-opacity=0 2>/dev/null
            else
                convert bambu-studio.svg -background transparent -resize ${size}x${size} "$temp_icon"
            fi
            
            # Replace the system icon
            sudo rm -f "/usr/share/icons/Yaru/${size}x${size}/mimetypes/model-stl.png"
            sudo cp "$temp_icon" "/usr/share/icons/Yaru/${size}x${size}/mimetypes/model-stl.png"
            sudo chmod 644 "/usr/share/icons/Yaru/${size}x${size}/mimetypes/model-stl.png"
            rm -f "$temp_icon"
        fi
        
        # Also replace the @2x versions if they exist
        if [ -f "/usr/share/icons/Yaru/${size}x${size}@2x/mimetypes/model-stl.png" ]; then
            temp_icon="/tmp/bambu-system-${size}@2x.png"
            double_size=$((size * 2))
            if command -v inkscape &> /dev/null; then
                inkscape bambu-studio.svg --export-type=png --export-filename="$temp_icon" --export-width=$double_size --export-height=$double_size --export-background-opacity=0 2>/dev/null
            else
                convert bambu-studio.svg -background transparent -resize ${double_size}x${double_size} "$temp_icon"
            fi
            
            sudo rm -f "/usr/share/icons/Yaru/${size}x${size}@2x/mimetypes/model-stl.png"
            sudo cp "$temp_icon" "/usr/share/icons/Yaru/${size}x${size}@2x/mimetypes/model-stl.png"
            sudo chmod 644 "/usr/share/icons/Yaru/${size}x${size}@2x/mimetypes/model-stl.png"
            rm -f "$temp_icon"
        fi
    done
    
    # Update system icon cache
    sudo gtk-update-icon-cache -f -t /usr/share/icons/Yaru 2>/dev/null || true
    echo -e "${GREEN}System STL icons replaced successfully!${NC}"
else
    echo -e "${GREEN}No system STL icons found to replace.${NC}"
fi

# Associate STL files with Bambu Studio (multiple MIME types)
echo -e "${GREEN}Associating STL files with Bambu Studio...${NC}"
xdg-mime default bambu-studio.desktop model/stl
xdg-mime default bambu-studio.desktop application/sla
xdg-mime default bambu-studio.desktop application/vnd.ms-pki.stl
xdg-mime default bambu-studio.desktop model/x.stl-ascii
xdg-mime default bambu-studio.desktop model/x.stl-binary

# Pin to dock using gsettings
echo -e "${GREEN}Pinning Bambu Studio to dock...${NC}"
CURRENT_FAVORITES=$(gsettings get org.gnome.shell favorite-apps)
if [ "$CURRENT_FAVORITES" = "@as []" ]; then
    # If favorites list is empty, create new list with just Bambu Studio
    gsettings set org.gnome.shell favorite-apps "['bambu-studio.desktop']"
else
    # If favorites list has items, append Bambu Studio if not already present
    if ! echo "$CURRENT_FAVORITES" | grep -q "bambu-studio.desktop"; then
    gsettings set org.gnome.shell favorite-apps "$(echo "$CURRENT_FAVORITES" | sed "s/]/, 'bambu-studio.desktop']/")"
    fi
fi

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

# Clear icon cache and restart Nautilus
echo -e "${GREEN}Updating icon cache...${NC}"
rm -rf ~/.cache/icon-cache.kcache
rm -rf ~/.cache/thumbnails
# Update icon cache properly
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$ICON_DIR" 2>/dev/null || true
fi
nautilus -q && nautilus &

echo -e "${GREEN}Bambu Studio has been successfully installed and pinned to your dock!${NC}"
echo -e "${GREEN}You can now launch it from the applications menu or the dock.${NC}"
echo -e "${GREEN}STL files are now associated with Bambu Studio.${NC}" 