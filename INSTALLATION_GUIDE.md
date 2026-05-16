# Ubuntu/Debian Development Environment Installation Guide

Complete documentation of all software, libraries, and tools installed on this development machine.

## Table of Contents

1. [System Information](#system-information)
2. [Development Tools](#development-tools)
3. [Package Managers & Runtimes](#package-managers--runtimes)
4. [Databases & Data Tools](#databases--data-tools)
5. [IDEs & Code Editors](#ides--code-editors)
6. [Browsers & Utilities](#browsers--utilities)
7. [Python Packages](#python-packages)
8. [Ruby Gems](#ruby-gems)
9. [Node.js Packages](#nodejs-packages)
10. [Snap Packages](#snap-packages)
11. [Quick Installation](#quick-installation)

---

## System Information

- **Distribution**: Ubuntu/Debian
- **Package Manager**: apt
- **Shell**: Bash
- **Architecture**: x86_64

---

## Development Tools

| Tool | Purpose |
|------|---------|
| `git` | Version control system |
| `curl` | Command-line data transfer tool |
| `wget` | Download utility |
| `build-essential` | Essential compiler and build tools |
| `rustc` | Rust compiler |
| `cargo` | Rust package manager |
| `docker` | Container platform |
| `7zip` | Archive utility |
| `ant` | Java build tool |
| `bind9-dnsutils` | DNS utilities |
| `apache2` | Web server |

---

## Package Managers & Runtimes

### Mise (Runtime Version Manager)
- **Purpose**: Manage multiple language versions (Ruby, Node.js, etc.)
- **Installation**: `curl https://mise.run | sh`
- **Status**: Installed

### Ruby
- **Version**: 3.x (via mise)
- **Package Manager**: Bundler (included)
- **Status**: Installed via mise

### Node.js
- **Version**: LTS (via mise)
- **Package Manager**: npm (included with Node.js)
- **Status**: Installed via mise

### Yarn
- **Version**: Latest stable
- **Purpose**: Alternative JavaScript package manager
- **Status**: Installed

---

## Databases & Data Tools

### PostgreSQL
- **Version**: Latest stable from apt
- **Default User**: postgres
- **Default Password**: postgres
- **Status**: Installed & configured
- **Access**: `sudo -u postgres psql`

---

## IDEs & Code Editors

| IDE/Editor | Version | Installation Method | Status |
|-----------|---------|-------------------|--------|
| VS Code | 10c8e557 | snap | Installed |
| RubyMine | 2026.1.2 | snap | Installed |
| DataGrip | 2026.1.3 | snap | Installed |
| Cursor | Latest | deb package | Installed via `install_cursor.sh` |

---

## Browsers & Utilities

| Tool | Purpose | Status |
|------|---------|--------|
| Brave Browser | Privacy-focused browser | Installed |
| Google Chrome | Chromium-based browser | Installed |
| Flameshot | Screenshot tool | Installed |
| 1Password | Password manager | Installed |
| 1Password CLI | Command-line password manager | Installed |

---

## Python Packages

### Core Libraries
```
aiodns (3.2.0)
aiohttp (3.11.16)
aiosignal (1.3.2)
async-timeout (5.0.1)
attrs (25.3.0)
beautifulsoup4 (4.13.4)
certifi (2025.1.31)
chardet (5.2.0)
charset-normalizer (3.4.2)
cryptography (43.0.0)
cssselect (1.3.0)
```

### Additional Python Tools
- `bcc` - BPF Compiler Collection
- `bcrypt` - Secure password hashing
- `Brlapi` - Braille display support
- `apt-listchanges` - APT changelog viewer

---

## Ruby Gems

### Core Gems
```
activesupport (7.2.1)
addressable (2.9.0)
anthropic (1.36.0) - Anthropic AI SDK
aws-sdk-core, aws-sdk-s3, aws-sdk-kms - AWS SDK
bundler (2.6.9) - Package manager
concurrent-ruby (1.3.4)
coderay (1.1.3) - Syntax highlighting
```

### API & Web Gems
- `connection_pool` - Connection pooling
- `crack` - XML/JSON parsing
- `faraday` - HTTP client library

---

## Node.js Packages

### Global Packages
```
npm (11.14.1)
corepack (0.34.7)
@openai/codex (0.130.0) - OpenAI Codex integration
```

---

## Snap Packages

| Package | Version | Category |
|---------|---------|----------|
| code | 10c8e557 | Editor |
| rubymine | 2026.1.2 | IDE |
| datagrip | 2026.1.3 | Database IDE |
| snapd | 2.75.2 | Package Manager |

### GNOME/Desktop Support
- gnome-3-38-2004
- gnome-42-2204
- gnome-46-2404
- gtk-common-themes
- mesa-2404

---

## Quick Installation

### For Fresh Ubuntu/Debian Installation

Run the automated setup script:

```bash
cd ~/software-projects/ubuntu-scripts
chmod +x basic-setup.sh
./basic-setup.sh
```

The script provides an interactive menu:
1. **Base Setup** - Essential tools, SSH, git configuration
2. **Mise & Ruby** - Runtime manager with Ruby and Node.js
3. **PostgreSQL** - Database server
4. **Docker** - Container platform
5. **Browsers** - Brave & Chrome
6. **IDEs** - VS Code & RubyMine
7. **LastPass** - Password manager
8. **Cura** - 3D printing slicer
9. **Install All** - Complete setup

### Additional Installation Scripts

Run specialized setup scripts as needed:

```bash
# Cursor Editor
./install_cursor.sh

# Bambu Studio (3D printing)
./install_bambu_studio.sh

# Cura (3D printing)
./install_cura.sh

# RubyMine
./install_rubymine.sh

# Dock from Dash integration
./install_dock_from_dash.sh
```

### Manual Installation Commands

```bash
# Update package lists
sudo apt update

# Install base tools
sudo apt install -y curl git build-essential

# Install Mise (runtime version manager)
curl https://mise.run | sh

# Install Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/yarn-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/yarn-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install -y yarn

# Install Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER

# Install Postgres
sudo apt install -y postgresql postgresql-client
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

# Install Snap packages
sudo snap install code --classic
sudo snap install rubymine --classic
sudo snap install datagrip --classic
```

---

## Configuration Files

### SSH Configuration
- Location: `~/.ssh/id_rsa`
- Permissions: 400 (read-only)
- Managed by: `basic-setup.sh`

### Bash Configuration
- Git aliases and functions in: `~/.bash_git`
- Sourced automatically from: `~/.bashrc`

### Mise Configuration
- Activation: Added to `~/.bashrc` as `eval "$(mise activate bash)"`
- Global versions: `.mise.toml` in home directory

---

## Environment Setup Notes

1. **Docker Group**: User added to docker group for permission-less Docker access (requires logout/login)
2. **Mise**: Automatically activated in new shell sessions
3. **PostgreSQL**: Default password is 'postgres' (should be changed for production)
4. **Git**: Configure with: `git config --global user.name "Your Name"` and `git config --global user.email "your@email.com"`

---

## Maintenance

### Update All Packages
```bash
sudo apt update && sudo apt upgrade -y
```

### Update Snap Packages
```bash
sudo snap refresh
```

### Update Ruby/Node.js
```bash
mise upgrade  # Updates runtime version manager
mise list     # Lists installed versions
```

### Clean Up
```bash
sudo apt autoremove -y
sudo apt autoclean -y
```

---

## Troubleshooting

### Docker Permission Denied
```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### Mise Not Found
```bash
export PATH="$HOME/.local/bin:$PATH"
# Or add to ~/.bashrc
```

### PostgreSQL Connection Issues
```bash
sudo service postgresql status
sudo service postgresql start
```

### Snap Installation Fails
Ensure snapd is installed:
```bash
sudo apt install snapd
sudo systemctl start snapd
```

---

## References

- [Mise Documentation](https://mise.jdx.dev/)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Yarn Documentation](https://yarnpkg.com/)
- [RubyGems Documentation](https://guides.rubygems.org/)

---

**Last Updated**: May 16, 2026  
**System**: Debian-based Linux (Ubuntu)  
**Repository**: ubuntu-scripts
