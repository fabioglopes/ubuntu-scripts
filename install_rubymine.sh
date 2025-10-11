#!/bin/bash

# RubyMine Installation Script
# Compatible with Ubuntu and Debian distributions
# Downloads latest RubyMine, extracts, and sets up desktop integration

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
APP_NAME="RubyMine"
INSTALL_DIR="$HOME/.local/bin/rubymine"
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
DESKTOP_FILE="${DESKTOP_ENTRY_DIR}/rubymine.desktop"
STARTUP_WM_CLASS="jetbrains-rubymine"

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
    local packages_to_install=""
    
    # Check for required packages
    for package in wget tar curl jq; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            packages_to_install="$packages_to_install $package"
        fi
    done
    
    if [ -n "$packages_to_install" ]; then
        echo -e "${GREEN}Installing required dependencies:$packages_to_install${NC}"
        
        # Use apt if available, otherwise fall back to apt-get
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install -y $packages_to_install
        elif command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y $packages_to_install
        else
            echo -e "${RED}Error: No supported package manager found (apt or apt-get)${NC}"
            exit 1
        fi
    fi
}

# Function to get latest RubyMine version and download URL
get_latest_rubymine_info() {
    echo -e "${GREEN}Fetching latest RubyMine release information...${NC}"
    
    # JetBrains data API endpoint for RubyMine
    local api_url="https://data.services.jetbrains.com/products/releases?code=RM&latest=true&type=release"
    
    # Get the latest release info
    local release_data=$(curl -s "$api_url")
    
    if [ -z "$release_data" ]; then
        echo -e "${RED}Error: Failed to fetch RubyMine release information${NC}"
        exit 1
    fi
    
    # Extract version and download URL
    LATEST_VERSION=$(echo "$release_data" | jq -r '.RM[0].version')
    DOWNLOAD_URL=$(echo "$release_data" | jq -r '.RM[0].downloads.linux.link')
    
    if [ "$LATEST_VERSION" = "null" ] || [ "$DOWNLOAD_URL" = "null" ]; then
        echo -e "${RED}Error: Could not parse RubyMine release information${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Latest RubyMine version: $LATEST_VERSION${NC}"
    echo -e "${GREEN}Download URL: $DOWNLOAD_URL${NC}"
}

# Check if RubyMine is already installed
check_existing_installation() {
    if [ -d "$INSTALL_DIR" ] && [ -f "$INSTALL_DIR/bin/rubymine.sh" ]; then
        echo -e "${YELLOW}RubyMine installation found at $INSTALL_DIR${NC}"
        
        # Try to get installed version
        if [ -f "$INSTALL_DIR/product-info.json" ]; then
            local installed_version=$(jq -r '.version' "$INSTALL_DIR/product-info.json" 2>/dev/null || echo "unknown")
            echo -e "${YELLOW}Installed version: $installed_version${NC}"
            
            if [ "$installed_version" = "$LATEST_VERSION" ]; then
                echo -e "${GREEN}Latest version is already installed!${NC}"
                read -p "Do you want to reinstall? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo -e "${GREEN}Installation cancelled.${NC}"
                    exit 0
                fi
            else
                echo -e "${YELLOW}A different version is installed. Proceeding with update...${NC}"
            fi
        else
            echo -e "${YELLOW}Cannot determine installed version. Proceeding with installation...${NC}"
        fi
        
        # Remove existing installation
        echo -e "${GREEN}Removing existing installation...${NC}"
        rm -rf "$INSTALL_DIR"
    fi
}

# Download and install RubyMine
install_rubymine() {
    echo -e "${GREEN}Starting RubyMine installation...${NC}"
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Ensure directories exist
    mkdir -p "$INSTALL_DIR" "$DESKTOP_ENTRY_DIR" "$ICON_DIR"
    
    # Download RubyMine
    echo -e "${GREEN}Downloading RubyMine $LATEST_VERSION...${NC}"
    DOWNLOAD_FILENAME=$(basename "$DOWNLOAD_URL")
    wget -q --show-progress "$DOWNLOAD_URL" -O "$DOWNLOAD_FILENAME"
    
    if [ ! -f "$DOWNLOAD_FILENAME" ]; then
        echo -e "${RED}Error: Download failed${NC}"
        exit 1
    fi
    
    # Extract RubyMine
    echo -e "${GREEN}Extracting RubyMine...${NC}"
    tar -xzf "$DOWNLOAD_FILENAME"
    
    # Find the extracted directory (it usually has a name like RubyMine-2023.3.2)
    EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "RubyMine-*" | head -1)
    
    if [ -z "$EXTRACTED_DIR" ]; then
        echo -e "${RED}Error: Could not find extracted RubyMine directory${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Found extracted directory: $EXTRACTED_DIR${NC}"
    
    # Move to installation directory
    mv "$EXTRACTED_DIR"/* "$INSTALL_DIR/"
    
    # Make the main script executable
    chmod +x "$INSTALL_DIR/bin/rubymine.sh"
    
    echo -e "${GREEN}RubyMine installed to $INSTALL_DIR${NC}"
}

# Set up RubyMine icon
setup_icon() {
    echo -e "${GREEN}Setting up RubyMine icon...${NC}"
    
    # Look for RubyMine icon in the installation
    local icon_candidates=(
        "$INSTALL_DIR/bin/rubymine.png"
        "$INSTALL_DIR/bin/rubymine.svg"
        "$INSTALL_DIR/lib/rubymine.png"
        "$INSTALL_DIR/lib/rubymine.svg"
        "$INSTALL_DIR/plugins/ruby/lib/ruby.png"
    )
    
    local icon_found=""
    for candidate in "${icon_candidates[@]}"; do
        if [ -f "$candidate" ]; then
            icon_found="$candidate"
            echo -e "${GREEN}Found icon: $candidate${NC}"
            break
        fi
    done
    
    if [ -n "$icon_found" ]; then
        # Copy icon to user icons directory
        local icon_extension="${icon_found##*.}"
        local icon_file="$ICON_DIR/rubymine.$icon_extension"
        cp "$icon_found" "$icon_file"
        echo -e "${GREEN}Icon installed to $icon_file${NC}"
        ICON_PATH="$icon_file"
    else
        echo -e "${YELLOW}No icon found in RubyMine installation, creating placeholder...${NC}"
        # Create a simple SVG icon
        cat > "$ICON_DIR/rubymine.svg" << 'EOL'
<svg width="256" height="256" xmlns="http://www.w3.org/2000/svg">
  <rect width="256" height="256" rx="32" fill="#DD1100"/>
  <rect x="32" y="32" width="192" height="192" rx="16" fill="#000000"/>
  <text x="128" y="110" text-anchor="middle" dy=".3em" fill="#DD1100" font-family="Arial, sans-serif" font-size="32" font-weight="bold">Ruby</text>
  <text x="128" y="150" text-anchor="middle" dy=".3em" fill="#DD1100" font-family="Arial, sans-serif" font-size="32" font-weight="bold">Mine</text>
</svg>
EOL
        ICON_PATH="$ICON_DIR/rubymine.svg"
        echo -e "${GREEN}Created placeholder icon${NC}"
    fi
}

# Create desktop entry
create_desktop_entry() {
    echo -e "${GREEN}Creating desktop entry...${NC}"
    
    cat > "$DESKTOP_FILE" << EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=RubyMine
Comment=Ruby and Rails IDE
Exec=$INSTALL_DIR/bin/rubymine.sh %f
Icon=$ICON_PATH
Terminal=false
Categories=Development;IDE;
StartupWMClass=$STARTUP_WM_CLASS
MimeType=text/x-ruby;application/x-ruby;text/x-script.ruby;
Keywords=ruby;rails;ide;jetbrains;development;
EOL
    
    # Make the desktop file executable
    chmod +x "$DESKTOP_FILE"
    
    echo -e "${GREEN}Desktop entry created at $DESKTOP_FILE${NC}"
}

# Update desktop database and icon cache
update_desktop_environment() {
    echo -e "${GREEN}Updating desktop environment...${NC}"
    
    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$DESKTOP_ENTRY_DIR" 2>/dev/null || true
    fi
    
    # Update icon cache
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f -t "$ICON_DIR" 2>/dev/null || true
    fi
    
    # Clear icon caches
    rm -rf ~/.cache/icon-cache.kcache 2>/dev/null || true
    rm -rf ~/.cache/thumbnails 2>/dev/null || true
}

# Detect desktop environment and handle dock integration
setup_dock_integration() {
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
            if command -v gsettings &> /dev/null; then
                echo -e "${GREEN}Adding RubyMine to GNOME favorites...${NC}"
                CURRENT_FAVORITES=$(gsettings get org.gnome.shell favorite-apps 2>/dev/null || echo "@as []")
                if ! echo "$CURRENT_FAVORITES" | grep -q "rubymine.desktop"; then
                    if [ "$CURRENT_FAVORITES" = "@as []" ]; then
                        gsettings set org.gnome.shell favorite-apps "['rubymine.desktop']" 2>/dev/null || true
                    else
                        gsettings set org.gnome.shell favorite-apps "$(echo "$CURRENT_FAVORITES" | sed "s/]/, 'rubymine.desktop']/")" 2>/dev/null || true
                    fi
                    echo -e "${GREEN}RubyMine added to dock${NC}"
                else
                    echo -e "${YELLOW}RubyMine already in dock${NC}"
                fi
            fi
            ;;
        *)
            echo -e "${YELLOW}Desktop environment not specifically supported for dock integration${NC}"
            echo -e "${YELLOW}RubyMine should appear in your applications menu${NC}"
            ;;
    esac
}

# Create command line launcher
create_cli_launcher() {
    echo -e "${GREEN}Creating command line launcher...${NC}"
    
    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"
    
    cat > "$bin_dir/rubymine" << EOL
#!/bin/bash
# RubyMine command line launcher
exec "$INSTALL_DIR/bin/rubymine.sh" "\$@"
EOL
    
    chmod +x "$bin_dir/rubymine"
    
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo -e "${YELLOW}Note: Add $HOME/.local/bin to your PATH to use 'rubymine' command${NC}"
        echo -e "${YELLOW}Add this line to your ~/.bashrc: export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    else
        echo -e "${GREEN}Command line launcher 'rubymine' is now available${NC}"
    fi
}

# Cleanup function
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        cd - > /dev/null 2>&1 || true
        rm -rf "$TEMP_DIR"
    fi
}

# Main installation function
main() {
    echo -e "${GREEN}Starting RubyMine installation...${NC}"
    
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Detect distribution
    detect_distribution
    
    # Ensure dependencies
    ensure_dependencies
    
    # Get latest version info
    get_latest_rubymine_info
    
    # Check existing installation
    check_existing_installation
    
    # Install RubyMine
    install_rubymine
    
    # Set up icon
    setup_icon
    
    # Create desktop entry
    create_desktop_entry
    
    # Create CLI launcher
    create_cli_launcher
    
    # Update desktop environment
    update_desktop_environment
    
    # Set up dock integration
    setup_dock_integration
    
    # Cleanup
    cleanup
    
    echo -e "${GREEN}RubyMine $LATEST_VERSION has been successfully installed!${NC}"
    echo -e "${GREEN}Installation location: $INSTALL_DIR${NC}"
    echo -e "${GREEN}You can now launch RubyMine from:${NC}"
    echo -e "${GREEN}  - Applications menu${NC}"
    echo -e "${GREEN}  - Command line: rubymine${NC}"
    echo -e "${GREEN}  - Direct execution: $INSTALL_DIR/bin/rubymine.sh${NC}"
    
    if [[ "$DESKTOP_ENV" == *"GNOME"* ]]; then
        echo -e "${GREEN}RubyMine has been added to your dock.${NC}"
    fi
}

# Run main function
main "$@"
