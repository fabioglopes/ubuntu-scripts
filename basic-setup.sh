#!/bin/bash

install_base_packages() {
    echo "Installing base packages..."
    sudo apt install curl git build-essential -y 
}

install_mise_ruby() {
    echo "Installing Mise and latest Ruby..."
    sudo apt-get update
    sudo apt install build-essential rustc libssl-dev libyaml-dev zlib1g-dev libgmp-dev -y
    curl https://mise.run | sh
    echo 'eval "$(~/.local/bin/mise activate)"' >> ~/.bashrc
    source ~/.bashrc
    mise use --global ruby@3

    echo "Installing Node.js using Mise..."
    mise use --global node@lts
}

install_postgres() {
    echo "Installing PostgreSQL..."
    sudo apt install postgresql postgresql-client -y
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
}

install_docker() {
    echo "Installing Docker..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \n    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
}

install_browsers() {
    echo "Installing Brave Browser and Google Chrome..."
    sudo apt install -y curl
    
    # Install Brave
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install -y brave-browser
    
    # Install Google Chrome
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb
}

install_ides() {
    echo "Installing VS Code and RubyMine..."
    sudo snap install code --classic
    sudo snap install rubymine --classic
}

install_lastpass() {
    echo "Installing LastPass..."
    wget https://download.cloud.lastpass.com/linux/lplinux.tar.bz2
    tar xjvf lplinux.tar.bz2
    ./install_lastpass.sh
    rm -rf lplinux.tar.bz2 install_lastpass.sh
}

install_cura() {
    echo "Installing Cura..."
    chmod +x install_cura.sh
    ./install_cura.sh
}

copy_ssh_key() {
    echo "Copying SSH key..."
    mkdir -p ~/.ssh
    cp id_rsa ~/.ssh/id_rsa
    chmod 400 ~/.ssh/id_rsa
}

create_software_projects_dir() {
    echo "Creating software-projects directory..."
    mkdir -p ~/software-projects
}

install_all() {
    install_base_packages
    install_mise_ruby
    install_postgres
    install_docker
    install_browsers
    install_ides
    install_lastpass
    install_cura
    copy_ssh_key
    create_software_projects_dir
}

while true; do
    echo "Select options to install (comma-separated, e.g., 1,3,5):"
    echo "1) Base Packages"
    echo "2) Mise and Latest Ruby (Includes Node.js)"
    echo "3) PostgreSQL"
    echo "4) Docker"
    echo "5) Browsers (Brave & Chrome)"
    echo "6) VS Code & RubyMine"
    echo "7) LastPass"
    echo "8) Install Cura"
    echo "9) Copy SSH Key"
    echo "10) Create software-projects directory"
    echo "11) Install All"
    echo "12) Exit"
    read -p "Enter your choices: " choices

    IFS=',' read -ra options <<< "$choices"
    for choice in "${options[@]}"; do
        case $choice in
            1) install_base_packages ;;
            2) install_mise_ruby ;;
            3) install_postgres ;;
            4) install_docker ;;
            5) install_browsers ;;
            6) install_ides ;;
            7) install_lastpass ;;
            8) install_cura ;;
            9) copy_ssh_key ;;
            10) create_software_projects_dir ;;
            11) install_all ;;
            12) exit 0 ;;
            *) echo "Invalid option: $choice" ;;
        esac
    done
done

