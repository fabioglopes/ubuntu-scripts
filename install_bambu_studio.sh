#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
APP_NAME="Bambu Studio"
INSTALL_DIR="$HOME/.local/bin/bambu-studio"
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
APPIMAGE_FILE="${INSTALL_DIR}/bambu-studio.AppImage"
ICON_FILE="${ICON_DIR}/bambu-studio.svg"
DESKTOP_FILE="${DESKTOP_ENTRY_DIR}/bambu-studio.desktop"
STARTUP_WM_CLASS="BambuStudio"

# Custom download URL (can be set via command line)
CUSTOM_DOWNLOAD_URL=""

# Function to show usage
show_usage() {
    echo -e "${GREEN}Bambu Studio Installation Script${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -u, --url URL     Specify a custom download URL for the Bambu Studio file (zip or AppImage)"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Install latest available version"
    echo "  $0 -u https://example.com/bambu.zip  # Install from custom zip URL"
    echo "  $0 -u https://example.com/bambu.AppImage  # Install from custom AppImage URL"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--url)
            CUSTOM_DOWNLOAD_URL="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

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
    
    # Check for image conversion tools
    if ! command -v convert &> /dev/null && ! command -v inkscape &> /dev/null && ! command -v rsvg-convert &> /dev/null; then
        echo -e "${YELLOW}No image conversion tools found. Installing ImageMagick for icon processing...${NC}"
        packages_to_install="$packages_to_install imagemagick"
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

# Determine download URL and version
if [[ -n "$CUSTOM_DOWNLOAD_URL" ]]; then
    echo -e "${YELLOW}Using custom download URL: $CUSTOM_DOWNLOAD_URL${NC}"
    DOWNLOAD_URL="$CUSTOM_DOWNLOAD_URL"
    LATEST_VERSION="custom"
    
    # Validate URL format
    if [[ ! "$DOWNLOAD_URL" =~ ^https?:// ]]; then
        echo -e "${RED}Error: Invalid URL format. Please provide a valid HTTP/HTTPS URL.${NC}"
        exit 1
    fi
else
    # Download the latest version of Bambu Studio
    echo -e "${GREEN}Fetching latest Bambu Studio release information...${NC}"
    LATEST_RELEASE_JSON=$(wget -q -O - "https://api.github.com/repos/bambulab/BambuStudio/releases/latest")
    LATEST_VERSION=$(echo "$LATEST_RELEASE_JSON" | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)

    if [[ -z "$LATEST_VERSION" ]]; then
        echo -e "${RED}Error: Failed to get latest version information${NC}"
        exit 1
    fi

    echo -e "${GREEN}Latest version found: $LATEST_VERSION${NC}"

    # Find the Ubuntu download URL from the latest release (try both zip and AppImage)
    DOWNLOAD_URL=$(echo "$LATEST_RELEASE_JSON" | grep -o '"browser_download_url": "[^"]*ubuntu[^"]*\.\(zip\|AppImage\)"' | cut -d'"' -f4 | head -1)

    if [[ -z "$DOWNLOAD_URL" ]]; then
        echo -e "${RED}Error: No Ubuntu download found for version $LATEST_VERSION${NC}"
        echo -e "${YELLOW}You can specify a custom download URL using: $0 --url <URL>${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}Downloading Bambu Studio $LATEST_VERSION...${NC}"
DOWNLOAD_FILENAME=$(basename "$DOWNLOAD_URL")
wget -q --show-progress "$DOWNLOAD_URL"

# Check if the downloaded file is a zip or AppImage
if [[ "$DOWNLOAD_FILENAME" == *.zip ]]; then
    echo -e "${GREEN}Extracting Bambu Studio from zip file...${NC}"
    unzip -q "$DOWNLOAD_FILENAME"
    
    # Find the AppImage file (it might have a different name based on version)
    APPIMAGE_SOURCE=$(find . -name "*.AppImage" -type f | head -1)
    
    if [[ -z "$APPIMAGE_SOURCE" ]]; then
        echo -e "${RED}Error: No AppImage found in the downloaded zip archive${NC}"
        echo -e "${YELLOW}Please check if the provided URL contains a valid Bambu Studio zip file.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Found AppImage in zip: $APPIMAGE_SOURCE${NC}"
    
elif [[ "$DOWNLOAD_FILENAME" == *.AppImage ]]; then
    echo -e "${GREEN}Downloaded AppImage directly${NC}"
    APPIMAGE_SOURCE="$DOWNLOAD_FILENAME"
    
    # Verify it's actually an AppImage file
    if ! file "$APPIMAGE_SOURCE" | grep -q "executable"; then
        echo -e "${RED}Error: Downloaded file is not a valid AppImage${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Found AppImage: $APPIMAGE_SOURCE${NC}"
    
else
    echo -e "${RED}Error: Downloaded file is neither a zip nor an AppImage${NC}"
    echo -e "${YELLOW}Supported file types: .zip (containing AppImage) or .AppImage (direct)${NC}"
    exit 1
fi

# Move AppImage to installation directory
mv "$APPIMAGE_SOURCE" "$APPIMAGE_FILE"

# Make AppImage executable
chmod +x "$APPIMAGE_FILE"

# Download and set icon (convert SVG to PNG for better compatibility)
echo -e "${GREEN}Setting up icon...${NC}"
if [ ! -f "$ICON_FILE" ]; then
    # Download SVG and convert to PNG with transparent background
    echo -e "${GREEN}Downloading Bambu Studio icon...${NC}"
    if wget -q https://raw.githubusercontent.com/bambulab/BambuStudio/master/resources/images/BambuStudio.svg -O bambu-studio.svg; then
        echo -e "${GREEN}SVG icon downloaded successfully${NC}"
        
        # Debug: Check file details
        echo -e "${GREEN}Checking downloaded file...${NC}"
        ls -la bambu-studio.svg
        file bambu-studio.svg
        
        # Verify the SVG file exists and has content
        if [ -f "bambu-studio.svg" ] && [ -s "bambu-studio.svg" ]; then
            # Check if it's actually an SVG file
            if head -n 1 bambu-studio.svg | grep -q "<?xml\|<svg"; then
                echo -e "${GREEN}Valid SVG file detected — using it directly as app icon${NC}"
                mkdir -p "$ICON_DIR"
                cp "$PWD/bambu-studio.svg" "$ICON_FILE"
                echo -e "${GREEN}SVG icon installed at: $ICON_FILE${NC}"
            else
                echo -e "${RED}Downloaded file is not a valid SVG${NC}"
                echo -e "${YELLOW}File content (first few lines):${NC}"
                head -n 5 bambu-studio.svg
                # Try PNG fallback
                echo -e "${YELLOW}Trying PNG fallback...${NC}"
                if ! wget -q https://github.com/bambulab/BambuStudio/raw/master/resources/images/BambuStudio_128.png -O "$ICON_FILE"; then
                    echo -e "${RED}PNG fallback also failed, creating placeholder icon${NC}"
                    # Create a simple placeholder icon
                    echo '<svg width="256" height="256" xmlns="http://www.w3.org/2000/svg"><rect width="256" height="256" fill="#4CAF50"/><text x="128" y="128" text-anchor="middle" dy=".3em" fill="white" font-size="24">BS</text></svg>' > "$ICON_FILE"
                fi
            fi
        else
            echo -e "${RED}SVG file is empty or corrupted${NC}"
            # Try PNG fallback
            echo -e "${YELLOW}Trying PNG fallback...${NC}"
            if ! wget -q https://github.com/bambulab/BambuStudio/raw/master/resources/images/BambuStudio_128.png -O "$ICON_FILE"; then
                echo -e "${RED}PNG fallback also failed, creating placeholder icon${NC}"
                # Create a simple placeholder icon
                echo '<svg width="256" height="256" xmlns="http://www.w3.org/2000/svg"><rect width="256" height="256" fill="#4CAF50"/><text x="128" y="128" text-anchor="middle" dy=".3em" fill="white" font-size="24">BS</text></svg>' > "$ICON_FILE"
            fi
        fi
    else
        echo -e "${RED}Failed to download SVG icon${NC}"
        # Try PNG fallback
        echo -e "${YELLOW}Trying PNG fallback...${NC}"
        if wget -q https://github.com/bambulab/BambuStudio/raw/master/resources/images/BambuStudio_128.png -O "$ICON_FILE"; then
            echo -e "${GREEN}Downloaded PNG fallback icon${NC}"
        else
            echo -e "${RED}PNG fallback also failed, creating placeholder icon${NC}"
            # Create a simple placeholder icon
            echo '<svg width="256" height="256" xmlns="http://www.w3.org/2000/svg"><rect width="256" height="256" fill="#4CAF50"/><text x="128" y="128" text-anchor="middle" dy=".3em" fill="white" font-size="24">BS</text></svg>' > "$ICON_FILE"
        fi
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

# Set up MIME type icon for STL files (only if convert is available)
if command -v convert &> /dev/null; then
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
else
    echo -e "${YELLOW}Skipping MIME type icon setup (ImageMagick not available)${NC}"
fi

# Replace system STL icons in Yaru theme (this ensures the icons actually show up)
if command -v convert &> /dev/null || command -v inkscape &> /dev/null; then
    echo -e "${GREEN}Replacing system STL icons with Bambu Studio icon...${NC}"
    if [ -f "/usr/share/icons/Yaru/16x16/mimetypes/model-stl.png" ] && [ -f "$PWD/bambu-studio.svg" ]; then
        # Save the SVG for system icon replacement
        cp "$PWD/bambu-studio.svg" "$HOME/.local/share/icons/bambu-studio.svg" 2>/dev/null || true
        
        # Replace system STL icons with Bambu Studio icon
        for size in 16 24 32 48 256; do
            if [ -f "/usr/share/icons/Yaru/${size}x${size}/mimetypes/model-stl.png" ]; then
                # Create Bambu Studio icon at the correct size
                temp_icon="/tmp/bambu-system-${size}.png"
                if command -v inkscape &> /dev/null; then
                    inkscape "$PWD/bambu-studio.svg" --export-type=png --export-filename="$temp_icon" --export-width=$size --export-height=$size --export-background-opacity=0 2>/dev/null
                elif command -v convert &> /dev/null; then
                    convert "$PWD/bambu-studio.svg" -background transparent -resize ${size}x${size} "$temp_icon"
                fi
                
                if [ -f "$temp_icon" ]; then
                    # Replace the system icon
                    sudo rm -f "/usr/share/icons/Yaru/${size}x${size}/mimetypes/model-stl.png"
                    sudo cp "$temp_icon" "/usr/share/icons/Yaru/${size}x${size}/mimetypes/model-stl.png"
                    sudo chmod 644 "/usr/share/icons/Yaru/${size}x${size}/mimetypes/model-stl.png"
                    rm -f "$temp_icon"
                fi
            fi
            
            # Also replace the @2x versions if they exist
            if [ -f "/usr/share/icons/Yaru/${size}x${size}@2x/mimetypes/model-stl.png" ]; then
                temp_icon="/tmp/bambu-system-${size}@2x.png"
                double_size=$((size * 2))
                if command -v inkscape &> /dev/null; then
                    inkscape "$PWD/bambu-studio.svg" --export-type=png --export-filename="$temp_icon" --export-width=$double_size --export-height=$double_size --export-background-opacity=0 2>/dev/null
                elif command -v convert &> /dev/null; then
                    convert "$PWD/bambu-studio.svg" -background transparent -resize ${double_size}x${double_size} "$temp_icon"
                fi
                
                if [ -f "$temp_icon" ]; then
                    sudo rm -f "/usr/share/icons/Yaru/${size}x${size}@2x/mimetypes/model-stl.png"
                    sudo cp "$temp_icon" "/usr/share/icons/Yaru/${size}x${size}@2x/mimetypes/model-stl.png"
                    sudo chmod 644 "/usr/share/icons/Yaru/${size}x${size}@2x/mimetypes/model-stl.png"
                    rm -f "$temp_icon"
                fi
            fi
        done
        
        # Update system icon cache
        sudo gtk-update-icon-cache -f -t /usr/share/icons/Yaru 2>/dev/null || true
        echo -e "${GREEN}System STL icons replaced successfully!${NC}"
    else
        echo -e "${GREEN}No system STL icons found to replace.${NC}"
    fi
else
    echo -e "${YELLOW}Skipping system icon replacement (no image conversion tools available)${NC}"
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