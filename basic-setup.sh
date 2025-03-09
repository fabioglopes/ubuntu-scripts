#!/bin/bash

install_base_setup() {
    echo "Creating software-projects directory..."
    if [ ! -d ~/software-projects ]; then
        mkdir -p ~/software-projects
        echo "software-projects directory created."
    else
        echo "software-projects directory already exists."
    fi

    echo "Installing base packages..."
    sudo apt update && sudo apt install -y curl git build-essential

    echo "Installing Flameshot..."
    sudo snap install flameshot

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
    echo "Installing Mise and latest Ruby..."
    sudo apt install -y build-essential rustc libssl-dev libyaml-dev zlib1g-dev libgmp-dev
    curl https://mise.run | sh
    echo 'eval "$(mise activate bash)"' >> ~/.bashrc
    source ~/.bashrc
    mise install ruby@3
    mise use --global ruby@3

    echo "Installing Node.js using Mise..."
    mise install node@lts
    mise use --global node@lts
}

install_postgres() {
    echo "Installing PostgreSQL..."
    sudo apt install -y postgresql postgresql-client
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
}

install_docker() {
    echo "Installing Docker..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

install_browsers() {
    echo "Installing Brave Browser and Google Chrome..."
    sudo apt install -y curl

    # Install Brave
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update && sudo apt install -y brave-browser

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
    if [ -f "lplinux.tar.bz2" ]; then
        tar xjvf lplinux.tar.bz2
        if [ -f "install_lastpass.sh" ]; then
            ./install_lastpass.sh
            rm -rf lplinux.tar.bz2 install_lastpass.sh
        else
            echo "Error: install_lastpass.sh not found!"
        fi
    else
        echo "Error: LastPass download failed!"
    fi
}

install_cura() {
    echo "Installing Cura..."
    if [ -f "install_cura.sh" ]; then
        chmod +x install_cura.sh
        ./install_cura.sh
    else
        echo "Error: install_cura.sh not found!"
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