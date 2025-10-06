#!/bin/bash

# Basic Setup Script for Development Environment
# Compatible with Ubuntu and Debian distributions
# Includes intelligent checks to skip already completed steps
# 
# Features:
# - Distribution detection (Ubuntu/Debian)
# - Package manager compatibility (apt/apt-get)
# - Skip already installed packages/tools
# - Proper error handling and cleanup
# - Color-coded output for better UX

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect distribution
detect_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="$ID"
        DISTRO_NAME="$NAME"
        DISTRO_VERSION_CODENAME="$VERSION_CODENAME"
    else
        echo -e "${RED}Error: Cannot detect distribution. /etc/os-release not found.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Detected distribution: $DISTRO_NAME${NC}"
}

# Check if package is installed
is_package_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update package manager (works with both apt and apt-get)
update_packages() {
    if command -v apt &> /dev/null; then
        sudo apt update
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update
    else
        echo -e "${RED}Error: No supported package manager found (apt or apt-get)${NC}"
        exit 1
    fi
}

# Install packages (works with both apt and apt-get)
install_packages() {
    if command -v apt &> /dev/null; then
        sudo apt install -y "$@"
    elif command -v apt-get &> /dev/null; then
        sudo apt-get install -y "$@"
    else
        echo -e "${RED}Error: No supported package manager found (apt or apt-get)${NC}"
        exit 1
    fi
}

install_base_setup() {
    echo -e "${GREEN}=== Base Setup ===${NC}"
    
    # Detect distribution
    detect_distribution
    
    # Create software-projects directory
    echo "Creating software-projects directory..."
    if [ ! -d ~/software-projects ]; then
        mkdir -p ~/software-projects
        echo -e "${GREEN}software-projects directory created.${NC}"
    else
        echo -e "${YELLOW}software-projects directory already exists.${NC}"
    fi

    # Install base packages
    echo "Checking base packages..."
    PACKAGES_TO_INSTALL=""
    
    for package in curl git build-essential libpq-dev; do
        if ! is_package_installed "$package"; then
            PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $package"
        else
            echo -e "${YELLOW}$package is already installed${NC}"
        fi
    done
    
    if [ -n "$PACKAGES_TO_INSTALL" ]; then
        echo -e "${GREEN}Installing base packages:$PACKAGES_TO_INSTALL${NC}"
        update_packages
        install_packages $PACKAGES_TO_INSTALL
    else
        echo -e "${GREEN}All base packages are already installed${NC}"
    fi

    # Install Flameshot
    echo "Checking Flameshot..."
    if ! is_package_installed "flameshot"; then
        echo -e "${GREEN}Installing Flameshot...${NC}"
        install_packages flameshot
    else
        echo -e "${YELLOW}Flameshot is already installed${NC}"
    fi

    echo "Copying SSH key..."
    if [ -f "id_rsa" ]; then
        mkdir -p ~/.ssh
        cp id_rsa ~/.ssh/id_rsa
        chmod 400 ~/.ssh/id_rsa
        echo "SSH key copied successfully."
    else
        echo "Error: id_rsa file not found!"
    fi

    echo "Setting up bash_git configuration..."
    # Copy .bash_git file to home directory if it doesn't exist there
    if [ ! -f ~/.bash_git ]; then
        if [ -f .bash_git ]; then
            cp .bash_git ~/.bash_git
            echo ".bash_git file copied to home directory"
        else
            echo "Error: .bash_git file not found in current directory!"
        fi
    else
        echo ".bash_git file already exists in home directory"
    fi

    # Add .bash_git configuration to .bashrc
    if ! grep -q "bash_git" ~/.bashrc; then
        echo "# Adding bash_git configuration"
        echo "if [ -f ~/.bash_git ]; then" >> ~/.bashrc
        echo "   . ~/.bash_git" >> ~/.bashrc
        echo "fi" >> ~/.bashrc
        echo "bash_git configuration added to .bashrc"
    else
        echo "bash_git configuration already exists in .bashrc"
    fi
}



install_mise_ruby() {
    echo -e "${GREEN}=== Mise, Ruby, and Node.js Setup ===${NC}"
    
    # Check if mise is already installed
    if command_exists "mise"; then
        echo -e "${YELLOW}Mise is already installed${NC}"
    else
        echo -e "${GREEN}Installing Mise dependencies...${NC}"
        PACKAGES_TO_INSTALL=""
        for package in build-essential rustc libssl-dev libyaml-dev zlib1g-dev libgmp-dev; do
            if ! is_package_installed "$package"; then
                PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $package"
            fi
        done
        
        if [ -n "$PACKAGES_TO_INSTALL" ]; then
            update_packages
            install_packages $PACKAGES_TO_INSTALL
        fi
        
        echo -e "${GREEN}Installing Mise...${NC}"
        curl https://mise.run | sh
        
        # Add mise activation to bashrc if not already there
        if ! grep -q "mise activate bash" ~/.bashrc; then
            echo 'eval "$(mise activate bash)"' >> ~/.bashrc
            echo -e "${GREEN}Added mise activation to .bashrc${NC}"
        else
            echo -e "${YELLOW}Mise activation already in .bashrc${NC}"
        fi
        
        # Source bashrc to make mise available
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # Check if Ruby is installed via mise
    if mise list ruby 2>/dev/null | grep -q "ruby"; then
        echo -e "${YELLOW}Ruby is already installed via mise${NC}"
    else
        echo -e "${GREEN}Installing Ruby via mise...${NC}"
        mise install ruby@3
        mise use --global ruby@3
    fi

    # Check if Node.js is installed via mise
    if mise list node 2>/dev/null | grep -q "node"; then
        echo -e "${YELLOW}Node.js is already installed via mise${NC}"
    else
        echo -e "${GREEN}Installing Node.js via mise...${NC}"
        mise install node@lts
        mise use --global node@lts
    fi

    # Install Yarn if not already installed
    if command_exists "yarn"; then
        echo -e "${YELLOW}Yarn is already installed${NC}"
    else
        echo -e "${GREEN}Installing Yarn...${NC}"
        # Use modern GPG key handling for Debian compatibility
        curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/yarn-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/yarn-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
        update_packages
        install_packages yarn
    fi
}

install_postgres() {
    echo -e "${GREEN}=== PostgreSQL Setup ===${NC}"
    
    # Check if PostgreSQL is already installed
    if is_package_installed "postgresql"; then
        echo -e "${YELLOW}PostgreSQL is already installed${NC}"
        
        # Check if postgres user password is already set
        if sudo -u postgres psql -c "SELECT 1;" >/dev/null 2>&1; then
            echo -e "${YELLOW}PostgreSQL is already configured${NC}"
        else
            echo -e "${GREEN}Setting PostgreSQL password...${NC}"
            sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
        fi
    else
        echo -e "${GREEN}Installing PostgreSQL...${NC}"
        update_packages
        install_packages postgresql postgresql-client
        
        echo -e "${GREEN}Setting PostgreSQL password...${NC}"
        sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
        echo -e "${GREEN}PostgreSQL installed and configured${NC}"
    fi
}

install_docker() {
    echo -e "${GREEN}=== Docker Setup ===${NC}"
    
    # Check if Docker is already installed
    if command_exists "docker"; then
        echo -e "${YELLOW}Docker is already installed${NC}"
        docker --version
        return
    fi
    
    echo -e "${GREEN}Installing Docker...${NC}"
    
    # Detect distribution for correct repository
    detect_distribution
    
    # Determine the correct Docker repository
    case "$DISTRO_ID" in
        ubuntu)
            DOCKER_REPO="ubuntu"
            ;;
        debian)
            DOCKER_REPO="debian"
            ;;
        *)
            echo -e "${YELLOW}Unknown distribution, trying Ubuntu repository...${NC}"
            DOCKER_REPO="ubuntu"
            ;;
    esac
    
    # Install Docker
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/$DOCKER_REPO/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Use distribution-specific repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DOCKER_REPO $DISTRO_VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    update_packages
    install_packages docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    echo -e "${GREEN}Docker installed successfully${NC}"
    echo -e "${YELLOW}Note: You may need to log out and log back in for Docker group membership to take effect${NC}"
}

install_browsers() {
    echo -e "${GREEN}=== Browsers Setup ===${NC}"
    
    # Ensure curl is installed
    if ! command_exists "curl"; then
        echo -e "${GREEN}Installing curl...${NC}"
        update_packages
        install_packages curl
    fi

    # Install Brave Browser
    if command_exists "brave-browser"; then
        echo -e "${YELLOW}Brave Browser is already installed${NC}"
    else
        echo -e "${GREEN}Installing Brave Browser...${NC}"
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        update_packages
        install_packages brave-browser
        echo -e "${GREEN}Brave Browser installed${NC}"
    fi

    # Install Google Chrome
    if command_exists "google-chrome"; then
        echo -e "${YELLOW}Google Chrome is already installed${NC}"
    else
        echo -e "${GREEN}Installing Google Chrome...${NC}"
        # Create temporary directory
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        if [ -f "google-chrome-stable_current_amd64.deb" ]; then
            install_packages ./google-chrome-stable_current_amd64.deb
            echo -e "${GREEN}Google Chrome installed${NC}"
        else
            echo -e "${RED}Failed to download Google Chrome${NC}"
        fi
        
        # Cleanup
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
    fi
}

install_ides() {
    echo -e "${GREEN}=== IDEs Setup ===${NC}"
    
    # Check if snap is available
    if ! command_exists "snap"; then
        echo -e "${YELLOW}Snap is not available, skipping IDE installation${NC}"
        echo -e "${YELLOW}You can install VS Code manually from: https://code.visualstudio.com/${NC}"
        return
    fi
    
    # Install VS Code
    if snap list code >/dev/null 2>&1; then
        echo -e "${YELLOW}VS Code is already installed${NC}"
    else
        echo -e "${GREEN}Installing VS Code...${NC}"
        sudo snap install code --classic
        echo -e "${GREEN}VS Code installed${NC}"
    fi
    
    # Install RubyMine
    if snap list rubymine >/dev/null 2>&1; then
        echo -e "${YELLOW}RubyMine is already installed${NC}"
    else
        echo -e "${GREEN}Installing RubyMine...${NC}"
        sudo snap install rubymine --classic
        echo -e "${GREEN}RubyMine installed${NC}"
    fi
}

install_lastpass() {
    echo -e "${GREEN}=== LastPass Setup ===${NC}"
    
    # Check if LastPass is already installed
    if command_exists "lastpass"; then
        echo -e "${YELLOW}LastPass is already installed${NC}"
        return
    fi
    
    echo -e "${GREEN}Installing LastPass...${NC}"
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    wget https://download.cloud.lastpass.com/linux/lplinux.tar.bz2
    if [ -f "lplinux.tar.bz2" ]; then
        tar xjvf lplinux.tar.bz2
        if [ -f "install_lastpass.sh" ]; then
            chmod +x install_lastpass.sh
            ./install_lastpass.sh
            echo -e "${GREEN}LastPass installed${NC}"
        else
            echo -e "${RED}Error: install_lastpass.sh not found!${NC}"
        fi
    else
        echo -e "${RED}Error: LastPass download failed!${NC}"
    fi
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
}

install_cura() {
    echo -e "${GREEN}=== Cura Setup ===${NC}"
    
    # Check if Cura is already installed
    if command_exists "cura" || [ -f "$HOME/.local/bin/cura/cura.AppImage" ]; then
        echo -e "${YELLOW}Cura is already installed${NC}"
        return
    fi
    
    echo -e "${GREEN}Installing Cura...${NC}"
    if [ -f "install_cura.sh" ]; then
        chmod +x install_cura.sh
        ./install_cura.sh
        echo -e "${GREEN}Cura installation completed${NC}"
    else
        echo -e "${RED}Error: install_cura.sh not found in current directory!${NC}"
        echo -e "${YELLOW}Make sure you're running this script from the ubuntu-scripts directory${NC}"
    fi
}


install_all() {
    install_base_setup
    install_mise_ruby
    install_postgres
    install_docker
    install_browsers
    install_ides
    install_lastpass
    install_cura
}


while true; do
    echo "Select options to install (comma-separated, e.g., 1,3,5):"
    echo "1) Base Setup (includes software-projects directory, SSH key, bash_git config, and Flameshot)"
    echo "2) Mise and Latest Ruby (Includes Node.js)"
    echo "3) PostgreSQL"
    echo "4) Docker"
    echo "5) Browsers (Brave & Chrome)"
    echo "6) VS Code & RubyMine"
    echo "7) LastPass"
    echo "8) Install Cura"
    echo "9) Install All"
    echo "10) Exit"
    read -p "Enter your choices: " choices

    # Process choices
    IFS=',' read -ra selected_options <<< "$choices"
    for option in "${selected_options[@]}"; do
        option=$(echo "$option" | tr -d '[:space:]')
        case $option in
            1) install_base_setup ;;
            2) install_mise_ruby ;;
            3) install_postgres ;;
            4) install_docker ;;
            5) install_browsers ;;
            6) install_ides ;;
            7) install_lastpass ;;
            8) install_cura ;;
            9) install_all ;;
            10) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid option: $option" ;;
        esac
    done
done