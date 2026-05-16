# Development Environment Installation Documentation

Complete guide for setting up a Ubuntu/Debian development machine from scratch.

## 📋 What's Included

This repository contains complete documentation and automation scripts for setting up a professional development environment.

### Documentation Files

| File | Purpose |
|------|---------|
| **INSTALLATION_GUIDE.md** | Detailed guide to all installed software (table of contents based) |
| **INSTALLED_SOFTWARE_SUMMARY.md** | Complete inventory of 500+ packages, gems, and tools |
| **QUICK_REFERENCE.md** | Fast lookup for common commands and operations |
| **README_INSTALLATION.md** | This file - overview and quick start |

### Installation Scripts

| Script | Purpose |
|--------|---------|
| **install_complete_environment.sh** | NEW: Full-featured interactive environment setup |
| **basic-setup.sh** | Core development environment (existing) |
| **install_cursor.sh** | Cursor editor installation |
| **install_bambu_studio.sh** | Bambu Studio (3D printing) |
| **install_cura.sh** | Cura slicer (3D printing) |
| **install_rubymine.sh** | RubyMine IDE |
| **install_dock_from_dash.sh** | Dash dock integration |

---

## 🚀 Quick Start

### For a Fresh Ubuntu Installation

```bash
# Clone/navigate to repo
cd ~/software-projects/ubuntu-scripts

# Make script executable
chmod +x install_complete_environment.sh

# Run installation (interactive menu)
./install_complete_environment.sh
```

Choose from the interactive menu:
- **Option 1-14**: Install specific components
- **Option 15**: Install everything (full setup)
- **Option 16**: Exit

### For Existing System

Use the existing `basic-setup.sh` or select specific packages from `install_complete_environment.sh`.

---

## 📦 What Gets Installed

### Development Tools
- Git, curl, wget
- Build tools (GCC, Make, Rust)
- Docker & Docker Compose
- PostgreSQL & clients

### Languages & Runtimes
- **Ruby** 3.x (via Mise)
- **Node.js** LTS (via Mise)
- **Python** 3.x (system)
- Language-specific package managers (Bundler, npm, Yarn, pip)

### IDEs & Editors
- VS Code (snap)
- RubyMine (snap)
- DataGrip (snap)
- Cursor (deb)
- Vim, Nano

### Web Browsers
- Brave Browser
- Google Chrome

### Databases
- PostgreSQL (with client tools)
- SQLite (included)

### Additional Tools
- Mise (runtime version manager)
- Docker (containers)
- Flameshot (screenshots)
- 1Password (password manager)
- SSH client/server

### 500+ APT Packages
- System libraries
- Development dependencies
- Build tools
- Desktop environment support

### 50+ Ruby Gems
- Rails framework
- AWS SDKs
- Testing frameworks (RSpec)
- HTTP clients & parsers

### 20+ Python Packages
- HTTP clients (aiohttp, requests)
- Web scraping (BeautifulSoup4)
- AWS integration (boto3)
- Security libraries (cryptography, bcrypt)

### Node.js Tools
- npm (package manager)
- Yarn (alternative package manager)
- OpenAI integration

---

## 📖 Documentation Structure

### Quick Navigation

**First time?** → Start with **QUICK_REFERENCE.md** for common commands

**Need details?** → Check **INSTALLATION_GUIDE.md** by section

**Complete list?** → See **INSTALLED_SOFTWARE_SUMMARY.md** for full inventory

**Installing fresh?** → Follow **This file** (README_INSTALLATION.md)

---

## 🔧 Installation Methods

### Method 1: Full Automated (Recommended)
```bash
./install_complete_environment.sh
# Select option 15 for complete setup
```

### Method 2: Interactive Selection
```bash
./install_complete_environment.sh
# Select individual options (1-14) as needed
```

### Method 3: Manual Installation
```bash
# Install specific package
sudo apt install package-name

# For Snap packages
sudo snap install package-name --classic

# For Python packages
pip3 install --user package-name

# For Ruby gems
gem install gem-name
```

### Method 4: Specialized Scripts
```bash
# Cursor editor
./install_cursor.sh

# Bambu Studio
./install_bambu_studio.sh

# RubyMine
./install_rubymine.sh
```

---

## ⚙️ Key Features

### Smart Installation
- Checks if packages are already installed
- Skips redundant installations
- Color-coded output for clarity
- Error handling and validation

### Distribution Support
- Ubuntu (all versions)
- Debian (stable, testing)
- Automatic detection of distro

### Runtime Management
- **Mise** for managing Ruby, Node.js versions
- Multiple language versions supported
- Easy switching between versions

### Container Support
- Docker and Docker Compose
- Ready for containerized development
- Kubernetes-ready setup

### Database Support
- PostgreSQL configured and running
- SQLite built-in
- Database client tools included

---

## 🛠️ Post-Installation

### First-Time Setup

1. **Configure Git**
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```

2. **Docker Group (for non-sudo usage)**
   ```bash
   # User already added to docker group by installer
   # Log out and back in for changes to take effect
   ```

3. **Change PostgreSQL Password**
   ```bash
   sudo -u postgres psql
   \password postgres
   # Enter new password
   ```

4. **Generate SSH Key** (if needed)
   ```bash
   ssh-keygen -t rsa -b 4096 -C "your@email.com"
   ```

### Common Next Steps

- Copy SSH key to `~/.ssh/` (script can help)
- Install additional Python packages: `pip3 install package-name`
- Install additional Ruby gems: `gem install gem-name`
- Install additional Node packages: `npm install -g package-name`
- Clone your projects: `git clone https://github.com/user/repo.git`

---

## 📊 System Requirements

### Minimum
- **RAM**: 8GB
- **Storage**: 20GB (without IDEs)
- **CPU**: Dual-core processor
- **OS**: Ubuntu 20.04+ or Debian 11+

### Recommended
- **RAM**: 16GB+
- **Storage**: 50GB+ (with IDEs and containers)
- **CPU**: Quad-core processor
- **OS**: Ubuntu 22.04+ or Debian 12+

---

## 🐛 Troubleshooting

### Docker Permission Denied
```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### Mise Not Found
```bash
# Add to PATH
export PATH="$HOME/.local/bin:$PATH"
# Or restart shell
exec bash
```

### PostgreSQL Connection Failed
```bash
sudo systemctl restart postgresql
sudo systemctl status postgresql
```

### Snap Installation Fails
```bash
sudo apt install snapd
sudo systemctl start snapd
```

### APT Lock File Busy
```bash
# Wait for other apt processes to finish
sudo lsof /var/lib/apt/lists/lock
# Or restart
sudo reboot
```

---

## 📚 Additional Resources

### Documentation
- [Mise Documentation](https://mise.jdx.dev/)
- [Docker Docs](https://docs.docker.com/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Rails Guides](https://guides.rubyonrails.org/)
- [Node.js Docs](https://nodejs.org/docs/)

### Useful Links
- [VS Code Extensions Marketplace](https://marketplace.visualstudio.com/)
- [RubyGems](https://rubygems.org/)
- [NPM Registry](https://www.npmjs.com/)
- [PyPI](https://pypi.org/)

---

## 💡 Tips & Best Practices

### Package Management
- Keep system updated: `sudo apt update && sudo apt upgrade -y`
- Use `mise` for managing multiple Ruby/Node versions
- Use virtual environments for Python projects

### Git Workflow
- Always create feature branches
- Write meaningful commit messages
- Pull before pushing
- Review changes before committing

### Docker Usage
- Keep images lightweight
- Use .dockerignore files
- Tag images consistently
- Remove unused images/containers

### Database
- Always backup before migrations
- Use separate databases for environments
- Configure PostgreSQL password in production
- Use connection pooling for web apps

### Development
- Use `.env` files for configuration
- Never commit sensitive data
- Keep dependencies updated
- Monitor security advisories

---

## 🔄 Updating & Maintenance

### Weekly
```bash
sudo apt update && sudo apt upgrade -y
```

### Monthly
```bash
# Update snap packages
sudo snap refresh

# Update system packages fully
sudo apt full-upgrade -y

# Clean up
sudo apt autoremove -y && sudo apt autoclean -y
```

### Quarterly
```bash
# Update language runtime versions
mise upgrade

# Update global npm packages
npm update -g

# Update bundled gems
bundle update
```

---

## 📝 File Locations

### Configuration Files
- **Bash**: `~/.bashrc`
- **Git**: `~/.gitconfig`
- **SSH**: `~/.ssh/` (config, keys)
- **Mise**: `~/.config/mise/`
- **PostgreSQL**: `/etc/postgresql/`

### Data Directories
- **Projects**: `~/software-projects/`
- **Repositories**: `~/software-projects/[project-name]/`
- **Databases**: `/var/lib/postgresql/`
- **Docker**: `/var/lib/docker/`

---

## 🚨 Important Notes

⚠️ **Security**
- Change default PostgreSQL password
- Don't commit `.env` files with secrets
- Keep SSH keys secure (chmod 400)
- Use strong Git credentials/tokens

⚠️ **Docker**
- Building images requires free disk space
- Remove old images/containers regularly
- Use non-root user in containers

⚠️ **PostgreSQL**
- Default password is 'postgres' - CHANGE IT
- Backup important databases
- Monitor disk space for data directory

---

## ✅ Verification Checklist

After installation, verify everything works:

- [ ] `git --version` returns version
- [ ] `ruby --version` shows Ruby 3.x
- [ ] `node --version` shows Node LTS
- [ ] `docker --version` works
- [ ] `psql --version` shows PostgreSQL
- [ ] `code --version` opens VS Code
- [ ] `psql -U postgres -c "SELECT 1"` connects to DB
- [ ] `docker ps` lists containers (empty is OK)

---

## 🤝 Support & Issues

### Getting Help
1. Check the **QUICK_REFERENCE.md** for commands
2. Review **INSTALLATION_GUIDE.md** for details
3. Check script output for error messages
4. Google the error message
5. Check GitHub issues in this repo

### Reporting Issues
If you find problems:
1. Note the error message
2. Share your OS version (`lsb_release -a`)
3. Include script output
4. Create issue with reproduction steps

---

## 📈 What's Next

After installation, consider:

1. **Create Development Project**
   ```bash
   cd ~/software-projects
   git init my-project
   cd my-project
   ```

2. **Setup a Rails App**
   ```bash
   rails new myapp
   cd myapp
   bundle install
   rails server
   ```

3. **Setup a Node.js Project**
   ```bash
   mkdir my-app && cd my-app
   npm init -y
   npm install express
   ```

4. **Create PostgreSQL Database**
   ```bash
   sudo -u postgres createdb myapp-dev
   ```

5. **Setup Docker Container**
   ```bash
   docker run -it ubuntu:latest /bin/bash
   ```

---

## 📄 File Listing

```
ubuntu-scripts/
├── README_INSTALLATION.md (this file)
├── INSTALLATION_GUIDE.md
├── INSTALLED_SOFTWARE_SUMMARY.md
├── QUICK_REFERENCE.md
├── install_complete_environment.sh (NEW)
├── basic-setup.sh
├── install_cursor.sh
├── install_bambu_studio.sh
├── install_cura.sh
├── install_rubymine.sh
└── install_dock_from_dash.sh
```

---

**Last Updated**: May 16, 2026  
**Compatible**: Ubuntu 20.04+, Debian 11+  
**Maintained by**: ubuntu-scripts repository  
**Repository**: https://github.com/fabioglopes/ubuntu-scripts
