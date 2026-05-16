# Quick Reference Guide

Fast lookup for common commands and operations on your Ubuntu development machine.

## Table of Contents
1. [Package Management](#package-management)
2. [Runtime Management (Mise)](#runtime-management-mise)
3. [Docker](#docker)
4. [PostgreSQL](#postgresql)
5. [Git](#git)
6. [Ruby](#ruby)
7. [Node.js/JavaScript](#nodejsjavascript)
8. [Python](#python)

---

## Package Management

### System Updates
```bash
# Update package lists
sudo apt update

# Upgrade all packages
sudo apt upgrade -y

# Full upgrade (can upgrade/remove packages)
sudo apt full-upgrade -y

# Auto-remove unused packages
sudo apt autoremove -y

# Clean cache
sudo apt autoclean -y
```

### Install/Remove Packages
```bash
# Install package
sudo apt install package-name

# Install multiple packages
sudo apt install package1 package2 package3

# Remove package (keep config)
sudo apt remove package-name

# Remove package (remove config too)
sudo apt purge package-name

# Search for package
apt search package-name

# Show package info
apt show package-name
```

### Snap Package Management
```bash
# List installed snaps
snap list

# Install snap package
sudo snap install package-name

# Remove snap
sudo snap remove package-name

# Update all snaps
sudo snap refresh
```

---

## Runtime Management (Mise)

### Basic Commands
```bash
# Check mise version
mise --version

# List installed versions
mise list

# List available versions
mise list --all ruby

# Install version
mise install ruby@3.2.0

# Set global version
mise use --global ruby@3

# Set project version
mise use ruby@3.1.0

# Activate mise in shell
eval "$(mise activate bash)"
```

### Ruby Via Mise
```bash
# Install latest Ruby 3
mise install ruby@3

# Set as global
mise use --global ruby@3

# Check Ruby version
ruby --version
```

### Node.js Via Mise
```bash
# Install Node LTS
mise install node@lts

# Set as global
mise use --global node@lts

# Check Node version
node --version
npm --version
```

---

## Docker

### Container Management
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Start container
docker start container-id

# Stop container
docker stop container-id

# Remove container
docker rm container-id

# View container logs
docker logs container-id

# Execute command in container
docker exec -it container-id bash
```

### Image Management
```bash
# List images
docker images

# Pull image
docker pull image-name:tag

# Build image
docker build -t image-name:tag .

# Remove image
docker rmi image-name:tag
```

### Docker Compose
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild images
docker-compose build
```

### Troubleshooting
```bash
# Fix permission denied errors
sudo usermod -aG docker $USER
# Then log out and back in

# Check Docker status
docker --version
sudo systemctl status docker
```

---

## PostgreSQL

### Database Operations
```bash
# Connect as postgres user
sudo -u postgres psql

# Connect to specific database
psql -U postgres -d database-name

# Connect from remote
psql -h hostname -U postgres -d database-name
```

### User Management
```bash
# Change postgres password (in psql)
\password postgres

# Create new user
CREATE USER username WITH PASSWORD 'password';

# List users
\du

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE dbname TO username;
```

### Database Management
```bash
# Create database
CREATE DATABASE database-name;

# List databases
\l

# Delete database
DROP DATABASE database-name;

# Backup database
pg_dump -U postgres database-name > backup.sql

# Restore database
psql -U postgres database-name < backup.sql
```

### Service Management
```bash
# Start PostgreSQL
sudo systemctl start postgresql

# Stop PostgreSQL
sudo systemctl stop postgresql

# Check status
sudo systemctl status postgresql

# Restart
sudo systemctl restart postgresql
```

---

## Git

### Basic Operations
```bash
# Clone repository
git clone https://github.com/user/repo.git

# Check status
git status

# Add changes
git add file-name
git add .  # Add all

# Commit changes
git commit -m "Commit message"

# Push changes
git push origin branch-name

# Pull changes
git pull origin branch-name
```

### Branch Management
```bash
# List branches
git branch

# Create branch
git checkout -b new-branch

# Switch branch
git checkout branch-name

# Delete branch
git branch -d branch-name

# Merge branch
git merge branch-name
```

### Configuration
```bash
# Set global name
git config --global user.name "Your Name"

# Set global email
git config --global user.email "your@email.com"

# Show config
git config --list
```

### Viewing History
```bash
# View commit history
git log

# View with graph
git log --graph --oneline --all

# View changes in file
git log -p file-name

# View differences
git diff
git diff branch1 branch2
```

---

## Ruby

### Version Management
```bash
# Check Ruby version
ruby --version

# List installed Ruby versions (with mise)
mise list ruby

# Install Ruby version
mise install ruby@3.2.0

# Set global Ruby version
mise use --global ruby@3
```

### Package Management
```bash
# Install gem
gem install gem-name

# Install from Gemfile
bundle install

# Update gems
bundle update

# List installed gems
gem list

# Uninstall gem
gem uninstall gem-name
```

### Rails Development
```bash
# Create new Rails app
rails new app-name

# Start Rails server
rails server      # or rails s

# Generate migration
rails generate migration migration-name

# Run migrations
rails db:migrate

# Create database
rails db:create

# Drop database
rails db:drop

# Rails console
rails console    # or rails c
```

---

## Node.js/JavaScript

### Version Management
```bash
# Check Node version
node --version

# Check npm version
npm --version

# Install Node (via mise)
mise install node@lts

# Install Yarn
yarn --version
```

### Package Management
```bash
# Initialize project
npm init -y

# Install dependencies
npm install

# Install package
npm install package-name

# Install globally
npm install -g package-name

# Update packages
npm update

# Uninstall package
npm uninstall package-name

# Install from package.json
npm ci  # (cleaner than npm install)
```

### Yarn (Alternative)
```bash
# Install dependencies
yarn install

# Install package
yarn add package-name

# Install globally
yarn global add package-name

# Upgrade package
yarn upgrade package-name
```

### Development
```bash
# Run script defined in package.json
npm run script-name

# Start development server
npm start

# Build project
npm run build

# Test
npm test

# Dev mode with watch
npm run dev
```

---

## Python

### Version Management
```bash
# Check Python version
python3 --version

# Check pip version
pip3 --version

# Upgrade pip
pip3 install --upgrade pip
```

### Package Management
```bash
# Install package
pip3 install package-name

# Install with requirements.txt
pip3 install -r requirements.txt

# List installed packages
pip3 list

# Uninstall package
pip3 uninstall package-name

# Create requirements.txt
pip3 freeze > requirements.txt
```

### Virtual Environments
```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Deactivate
deactivate

# Install packages in venv
pip install -r requirements.txt
```

---

## System Administration

### User & Permissions
```bash
# Add user to group
sudo usermod -aG group-name username

# Change file permissions
chmod 755 file-name

# Change owner
sudo chown user:group file-name

# Set SUDO no password for command
sudo visudo  # Edit sudoers file safely
```

### System Information
```bash
# System info
uname -a

# CPU info
lscpu

# Memory info
free -h

# Disk usage
df -h

# Directory size
du -sh directory/

# Process monitoring
htop
```

### System Services
```bash
# List services
sudo systemctl list-units --type=service

# Start service
sudo systemctl start service-name

# Stop service
sudo systemctl stop service-name

# Restart service
sudo systemctl restart service-name

# Enable at boot
sudo systemctl enable service-name

# Check status
sudo systemctl status service-name
```

---

## File & Directory Operations

### Navigation
```bash
# Print current directory
pwd

# List files
ls -la

# Change directory
cd path/to/directory

# Go to home
cd ~

# Go to previous directory
cd -
```

### File Operations
```bash
# Copy file
cp source destination

# Copy directory
cp -r source destination

# Move/rename
mv source destination

# Remove file
rm file-name

# Remove directory
rm -rf directory-name

# Create directory
mkdir directory-name

# Create nested directories
mkdir -p parent/child/grandchild
```

### Search & Find
```bash
# Find files by name
find . -name "filename"

# Find files by type
find . -type f -name "*.js"

# Search in files
grep -r "search-term" .

# Count matches
grep -r "search-term" . | wc -l
```

---

## Text Editors

### Vim
```bash
# Open file
vim filename

# Save and quit
:wq

# Quit without saving
:q!

# Save without quit
:w

# Go to line
:10  # Go to line 10

# Search
/search-term
```

### Nano
```bash
# Open file
nano filename

# Save
Ctrl + O

# Quit
Ctrl + X
```

---

## IDE Shortcuts

### VS Code
```
Ctrl + P       Open file
Ctrl + Shift + P  Command palette
Ctrl + `       Toggle terminal
Ctrl + B       Toggle sidebar
Ctrl + /       Comment line
Ctrl + Shift + F Find in files
Ctrl + K, V    Split editor
```

### RubyMine
```
Ctrl + P       Find class
Ctrl + Shift + A  Find action
Ctrl + H       Find and replace
Alt + Enter    Show intentions
Ctrl + Alt + T  Open terminal
```

---

## Useful Shortcuts

```bash
# Clear screen
clear
# or
Ctrl + L

# Interrupt program
Ctrl + C

# Suspend program
Ctrl + Z

# Stop output (press any key to resume)
Ctrl + S
Ctrl + Q

# Search command history
Ctrl + R

# Autocomplete
Tab
```

---

## Common Commands Checklist

- [ ] `sudo apt update && sudo apt upgrade -y` - Keep system updated
- [ ] `git config --global user.email "you@example.com"` - Configure Git
- [ ] `mise use --global ruby@3` - Set global Ruby
- [ ] `mise use --global node@lts` - Set global Node.js
- [ ] `docker --version` - Verify Docker
- [ ] `psql --version` - Verify PostgreSQL
- [ ] `ssh-keygen -t rsa` - Generate SSH key
- [ ] `bundle install` - Install Ruby dependencies
- [ ] `npm install` - Install Node dependencies
- [ ] `pip3 install -r requirements.txt` - Install Python dependencies

---

**Last Updated**: May 16, 2026
