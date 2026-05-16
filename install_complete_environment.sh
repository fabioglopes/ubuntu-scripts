#!/bin/bash

# Complete Development Environment Setup Script for Ubuntu/Debian
# Installs all development tools, IDEs, databases, and essential libraries
# For fresh Ubuntu/Debian installation
#
# Usage: chmod +x install_complete_environment.sh && ./install_complete_environment.sh

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
DISTRO_ID=""
DISTRO_NAME=""
DISTRO_VERSION_CODENAME=""

# ============================================================================
# Utility Functions
# ============================================================================

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Detect distribution
detect_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="$ID"
        DISTRO_NAME="$NAME"
        DISTRO_VERSION_CODENAME="$VERSION_CODENAME"
        print_success "Detected: $DISTRO_NAME"
    else
        print_error "Cannot detect distribution"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if package is installed
is_package_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

# Update package manager
update_packages() {
    print_info "Updating package lists..."
    if command -v apt &> /dev/null; then
        sudo apt update
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update
    else
        print_error "No supported package manager found"
        exit 1
    fi
}

# Install packages
install_packages() {
    local packages_to_install=""

    for package in "$@"; do
        if ! is_package_installed "$package"; then
            packages_to_install="$packages_to_install $package"
        else
            print_warning "$package already installed"
        fi
    done

    if [ -n "$packages_to_install" ]; then
        echo "Installing:$packages_to_install"
        if command -v apt &> /dev/null; then
            sudo apt install -y $packages_to_install
        elif command -v apt-get &> /dev/null; then
            sudo apt-get install -y $packages_to_install
        fi
    fi
}

# ============================================================================
# Installation Functions
# ============================================================================

install_base_packages() {
    print_header "Installing Base Packages"

    update_packages

    local base_packages=(
        "curl"
        "wget"
        "git"
        "build-essential"
        "libpq-dev"
        "ca-certificates"
        "apt-transport-https"
        "software-properties-common"
        "gnupg"
        "lsb-release"
        "zip"
        "unzip"
        "7zip"
        "vim"
        "nano"
        "htop"
        "net-tools"
        "dnsutils"
    )

    install_packages "${base_packages[@]}"
    print_success "Base packages installed"
}

install_development_tools() {
    print_header "Installing Development Tools"

    local dev_tools=(
        "build-essential"
        "rustc"
        "cargo"
        "libssl-dev"
        "libyaml-dev"
        "zlib1g-dev"
        "libgmp-dev"
        "git"
    )

    install_packages "${dev_tools[@]}"
    print_success "Development tools installed"
}

install_mise() {
    print_header "Installing Mise (Runtime Version Manager)"

    if command_exists "mise"; then
        print_warning "Mise already installed"
        return
    fi

    print_info "Downloading Mise..."
    curl https://mise.run | sh

    # Add mise to PATH
    export PATH="$HOME/.local/bin:$PATH"

    # Add to bashrc if not already there
    if ! grep -q "mise activate bash" ~/.bashrc; then
        echo 'eval "$(mise activate bash)"' >> ~/.bashrc
        print_success "Mise activation added to .bashrc"
    fi

    print_success "Mise installed"
}

install_ruby() {
    print_header "Installing Ruby (via Mise)"

    if ! command_exists "mise"; then
        print_error "Mise not found. Install Mise first."
        return
    fi

    if command_exists "ruby"; then
        print_warning "Ruby already installed"
        return
    fi

    print_info "Installing Ruby 3.x via Mise..."
    mise install ruby@3
    mise use --global ruby@3

    print_success "Ruby installed"
    ruby --version
}

install_nodejs() {
    print_header "Installing Node.js (via Mise)"

    if ! command_exists "mise"; then
        print_error "Mise not found. Install Mise first."
        return
    fi

    if command_exists "node"; then
        print_warning "Node.js already installed"
        return
    fi

    print_info "Installing Node.js LTS via Mise..."
    mise install node@lts
    mise use --global node@lts

    print_success "Node.js installed"
    node --version
}

install_yarn() {
    print_header "Installing Yarn"

    if command_exists "yarn"; then
        print_warning "Yarn already installed"
        return
    fi

    print_info "Adding Yarn repository..."
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/yarn-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/yarn-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

    update_packages
    install_packages "yarn"

    print_success "Yarn installed"
    yarn --version
}

install_postgres() {
    print_header "Installing PostgreSQL"

    if command_exists "psql"; then
        print_warning "PostgreSQL already installed"
        return
    fi

    update_packages
    install_packages "postgresql" "postgresql-client"

    print_info "Configuring PostgreSQL..."
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

    print_warning "PostgreSQL installed with default password 'postgres' - change this for production!"
    print_success "PostgreSQL installed and configured"
}

install_docker() {
    print_header "Installing Docker"

    if command_exists "docker"; then
        print_warning "Docker already installed"
        docker --version
        return
    fi

    detect_distribution

    case "$DISTRO_ID" in
        ubuntu)
            DOCKER_REPO="ubuntu"
            ;;
        debian)
            DOCKER_REPO="debian"
            ;;
        *)
            print_warning "Unknown distribution, using Ubuntu repository"
            DOCKER_REPO="ubuntu"
            ;;
    esac

    print_info "Adding Docker repository..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/$DOCKER_REPO/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DOCKER_REPO $DISTRO_VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    update_packages
    install_packages "docker-ce" "docker-ce-cli" "containerd.io" "docker-compose-plugin"

    print_info "Adding user to docker group..."
    sudo usermod -aG docker $USER

    print_warning "You may need to log out and back in for Docker group changes to take effect"
    print_success "Docker installed"
    docker --version
}

install_browsers() {
    print_header "Installing Web Browsers"

    # Brave Browser
    if command_exists "brave-browser"; then
        print_warning "Brave Browser already installed"
    else
        print_info "Installing Brave Browser..."
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        update_packages
        install_packages "brave-browser"
        print_success "Brave Browser installed"
    fi

    # Google Chrome
    if command_exists "google-chrome"; then
        print_warning "Google Chrome already installed"
    else
        print_info "Installing Google Chrome..."
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"

        wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        if [ -f "google-chrome-stable_current_amd64.deb" ]; then
            sudo apt install -y ./google-chrome-stable_current_amd64.deb
            print_success "Google Chrome installed"
        else
            print_error "Failed to download Google Chrome"
        fi

        cd - > /dev/null
        rm -rf "$TEMP_DIR"
    fi
}

install_screenshot_tool() {
    print_header "Installing Screenshot Tool"

    if command_exists "flameshot"; then
        print_warning "Flameshot already installed"
        return
    fi

    update_packages
    install_packages "flameshot"
    print_success "Flameshot installed"
}

install_ides_via_snap() {
    print_header "Installing IDEs (via Snap)"

    if ! command_exists "snap"; then
        print_warning "Snap not available, skipping IDE installation"
        print_info "Install VS Code manually from: https://code.visualstudio.com/"
        return
    fi

    # VS Code
    if sudo snap list code >/dev/null 2>&1; then
        print_warning "VS Code already installed"
    else
        print_info "Installing VS Code..."
        sudo snap install code --classic
        print_success "VS Code installed"
    fi

    # RubyMine
    if sudo snap list rubymine >/dev/null 2>&1; then
        print_warning "RubyMine already installed"
    else
        print_info "Installing RubyMine..."
        sudo snap install rubymine --classic
        print_success "RubyMine installed"
    fi

    # DataGrip
    if sudo snap list datagrip >/dev/null 2>&1; then
        print_warning "DataGrip already installed"
    else
        print_info "Installing DataGrip..."
        sudo snap install datagrip --classic
        print_success "DataGrip installed"
    fi
}

install_password_manager() {
    print_header "Installing Password Manager (1Password)"

    if command_exists "1password"; then
        print_warning "1Password already installed"
        return
    fi

    print_info "1Password installation requires manual download from: https://1password.com/downloads/"
    print_info "Or install CLI via: curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/1password-archive-keyring.gpg"
}

install_additional_python() {
    print_header "Installing Additional Python Packages"

    if ! command_exists "python3"; then
        print_error "Python 3 not found"
        return
    fi

    print_info "Installing common Python packages via pip..."
    pip3 install --user --upgrade pip

    local python_packages=(
        "beautifulsoup4"
        "requests"
        "cryptography"
        "boto3"
        "psycopg2-binary"
    )

    for package in "${python_packages[@]}"; do
        pip3 install --user "$package" 2>/dev/null && print_success "$package installed" || print_warning "$package failed"
    done
}

setup_directories() {
    print_header "Setting Up Directory Structure"

    if [ ! -d ~/software-projects ]; then
        mkdir -p ~/software-projects
        print_success "Created ~/software-projects directory"
    else
        print_warning "~/software-projects already exists"
    fi
}

setup_git_config() {
    print_header "Setting Up Git Configuration"

    print_info "Current Git configuration:"
    git config --list | grep user

    read -p "Configure git user.name (press Enter to skip): " git_name
    if [ -n "$git_name" ]; then
        git config --global user.name "$git_name"
        print_success "Git user.name set to: $git_name"
    fi

    read -p "Configure git user.email (press Enter to skip): " git_email
    if [ -n "$git_email" ]; then
        git config --global user.email "$git_email"
        print_success "Git user.email set to: $git_email"
    fi
}

# ============================================================================
# Main Menu
# ============================================================================

show_menu() {
    echo ""
    echo -e "${BLUE}=== Development Environment Installer ===${NC}"
    echo "1) Base Packages (curl, git, build-essential, etc)"
    echo "2) Development Tools (Rust, Cargo, etc)"
    echo "3) Mise (Runtime Version Manager)"
    echo "4) Ruby (via Mise)"
    echo "5) Node.js (via Mise)"
    echo "6) Yarn"
    echo "7) PostgreSQL"
    echo "8) Docker"
    echo "9) Browsers (Brave, Chrome)"
    echo "10) IDEs (VS Code, RubyMine, DataGrip)"
    echo "11) Screenshot Tool (Flameshot)"
    echo "12) Additional Python Packages"
    echo "13) Setup Directories"
    echo "14) Git Configuration"
    echo "15) Install Everything (Full Setup)"
    echo "16) Exit"
    echo ""
}

install_everything() {
    print_header "Starting Full Environment Setup"

    detect_distribution

    setup_directories
    install_base_packages
    install_development_tools
    install_mise
    install_ruby
    install_nodejs
    install_yarn
    install_postgres
    install_docker
    install_browsers
    install_screenshot_tool
    install_ides_via_snap
    install_additional_python
    setup_git_config

    print_header "Installation Complete!"
    print_success "All packages have been installed successfully"
    print_warning "Please log out and back in for Docker group changes to take effect"
}

# ============================================================================
# Main Loop
# ============================================================================

main() {
    detect_distribution

    while true; do
        show_menu
        read -p "Select an option (1-16): " choice

        case $choice in
            1) install_base_packages ;;
            2) install_development_tools ;;
            3) install_mise ;;
            4) install_ruby ;;
            5) install_nodejs ;;
            6) install_yarn ;;
            7) install_postgres ;;
            8) install_docker ;;
            9) install_browsers ;;
            10) install_ides_via_snap ;;
            11) install_screenshot_tool ;;
            12) install_additional_python ;;
            13) setup_directories ;;
            14) setup_git_config ;;
            15) install_everything ;;
            16) print_success "Exiting..."; exit 0 ;;
            *) print_error "Invalid option" ;;
        esac
    done
}

# Run main function
main "$@"
