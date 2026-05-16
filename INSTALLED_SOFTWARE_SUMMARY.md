# Complete Software Inventory

Comprehensive list of all software, libraries, and tools installed on this development machine as of May 16, 2026.

## Quick Stats

- **Total Apt Packages**: 500+
- **Python Packages**: 20+
- **Ruby Gems**: 50+
- **Node.js Packages**: 3 (global)
- **Snap Packages**: 15+

---

## APT Packages (Debian/Ubuntu)

### System & Core
```
base-files, base-passwd, bash, bash-completion, systemd
adduser, sudo, shadow, coreutils, grep, sed, awk
util-linux, findutils, tar, gzip, bzip2, xz-utils
```

### Development Tools
```
git (version control)
curl (data transfer)
wget (download utility)
build-essential (compilers & build tools)
rustc (Rust compiler)
cargo (Rust package manager)
binutils (binary tools)
gcc, g++, make
```

### Libraries & Dependencies
```
libssl-dev (SSL/TLS support)
libyaml-dev (YAML parser)
zlib1g-dev (compression library)
libgmp-dev (arbitrary precision arithmetic)
libpq-dev (PostgreSQL client library)
libcurl4 (cURL library)
libffi-dev (Foreign Function Interface)
libreadline-dev (command-line editing)
```

### Editors & Development
```
vim (text editor)
nano (text editor)
gedit (GUI text editor)
```

### System Utilities
```
htop (process monitor)
net-tools (networking utilities)
dnsutils (DNS tools)
bind9-dnsutils (DNS query tools)
openssh-client (SSH client)
openssh-server (SSH server)
curl, wget (download tools)
7zip, zip, unzip (archive tools)
```

### Databases & Data Tools
```
postgresql (relational database)
postgresql-client (database client)
sqlite3 (lightweight database)
```

### Web Servers & Services
```
apache2 (web server)
apache2-bin
nginx (alternative web server)
```

### Multimedia & Audio
```
alsa-utils (audio utilities)
alsa-topology-conf, alsa-ucm-conf (audio configuration)
pulseaudio (sound server)
libpulse (PulseAudio libraries)
```

### Desktop & GUI
```
gnome-shell (desktop environment)
gtk+ (GUI toolkit)
adwaita-icon-theme (icon theme)
gtk-common-themes
```

### Bluetooth & Hardware
```
bluetooth
bluez (Bluetooth stack)
bluez-obexd (Bluetooth file transfer)
```

### Security & Cryptography
```
openssl (SSL/TLS toolkit)
gnupg, gnupg2 (encryption tools)
ssh (secure shell)
1password-cli (password manager CLI)
```

### Document Processing
```
aspell (spell checker)
aspell-en (English dictionary)
```

### Virtualization & Containers
```
docker-ce (container engine)
docker-ce-cli (Docker command-line)
containerd (container runtime)
docker-compose-plugin (container orchestration)
```

### Cloud & AWS
```
aws-cli (Amazon Web Services CLI)
```

### Package Managers
```
apt, apt-utils, apt-listchanges
dpkg, dpkg-dev
snap, snapd
npm, yarn (via separate installation)
bundler (Ruby package manager)
```

### Monitoring & System Info
```
lsb-release (OS identification)
sysstat (system performance tools)
acpi (ACPI client)
```

### Boot & Firmware
```
grub-common, grub-pc (bootloader)
efibootmgr (EFI boot manager)
amd64-microcode (processor microcode)
```

---

## Python Packages

### Network & Async
```
aiohttp (3.11.16) - Async HTTP client/server
aiodns (3.2.0) - Async DNS resolver
aiosignal (1.3.2) - Signal dispatching
async-timeout (5.0.1) - Async timeout context manager
```

### Web & Scraping
```
beautifulsoup4 (4.13.4) - HTML/XML parsing
cssselect (1.3.0) - CSS selector library
requests (via pip) - HTTP library
```

### Data & Serialization
```
attrs (25.3.0) - Class/attribute utilities
chardet (5.2.0) - Character encoding detection
charset-normalizer (3.4.2) - Encoding detection
```

### Security & Cryptography
```
cryptography (43.0.0) - Cryptographic recipes
bcrypt (4.2.0) - Password hashing
```

### AWS Integration
```
boto3 (via pip) - AWS SDK
botocore - AWS service client library
```

### System Tools
```
apt-listchanges (4.8) - APT changelog viewer
Brlapi (0.8.6) - Braille display support
```

### Core Utilities
```
certifi (2025.1.31) - Certificate bundle
babel (2.17.0) - Internationalization library
```

---

## Ruby Gems

### Rails Ecosystem
```
activesupport (7.2.1) - Rails utilities
rails (7.2.x) - Web framework
railties - Rails core utilities
```

### HTTP & Networking
```
addressable (2.9.0) - URI parser
faraday (2.x) - HTTP client library
httparty - HTTP client
rest-client - Simple HTTP client
typhoeus - HTTP client
```

### JSON/XML Processing
```
json (built-in)
nokogiri (1.15.x) - XML/HTML parser
crack (1.0.1) - XML/JSON parsing
```

### AWS SDK
```
aws-sdk-core (3.209.1) - AWS SDK core
aws-sdk-s3 (1.167.0) - AWS S3 client
aws-sdk-kms (1.94.0) - AWS KMS client
aws-sigv4 (1.10.0) - AWS signature generation
aws-eventstream (1.3.0) - Event stream support
aws-partitions (1.986.0) - AWS service partitions
```

### Database Adapters
```
activerecord (7.2.x) - Database ORM
pg (1.x) - PostgreSQL adapter
mysql2 - MySQL adapter
sqlite3 - SQLite adapter
```

### Concurrency & Utilities
```
concurrent-ruby (1.3.4) - Concurrency abstractions
connection_pool (2.4.1) - Connection pooling
```

### Code Quality & Development
```
rspec (4.x) - Testing framework
rubocop (1.x) - Code style checker
bundler (2.6.9) - Dependency manager
rake (13.x) - Task automation
```

### Code Analysis
```
ast (2.4.3) - Abstract syntax tree
coderay (1.1.3) - Syntax highlighting
parser (3.x) - Ruby parser
```

### Numeric & Scientific
```
bigdecimal (4.1.2) - Arbitrary precision decimal
benchmark (0.4.0) - Benchmarking tools
```

### APIs & AI
```
anthropic (1.36.0) - Anthropic Claude API SDK
```

---

## Node.js Packages (Global)

```
npm (11.14.1) - Node package manager
corepack (0.34.7) - Package manager switcher
@openai/codex (0.130.0) - OpenAI API integration
```

---

## Snap Packages

### Development IDEs
```
code (10c8e557) - VS Code editor
rubymine (2026.1.2) - Ruby IDE
datagrip (2026.1.3) - Database IDE
```

### System & Core
```
snapd (2.75.2) - Snap daemon
snapd-desktop-integration (0.9) - Desktop integration
```

### GNOME Desktop Support
```
gnome-3-38-2004
gnome-42-2204
gnome-46-2404
gtk-common-themes (0.1-81)
mesa-2404 (25.0.7) - GPU drivers
```

### Base Frameworks
```
bare (1.0) - Bare minimum runtime
core20, core22, core24 - Core runtimes
```

---

## Web Browsers

```
brave-browser - Privacy-focused Chromium browser
google-chrome - Chrome browser
firefox (if installed) - Mozilla Firefox
```

---

## System Applications

```
flameshot - Screenshot and annotation tool
1password - Password manager (installed)
1password-cli - Password manager CLI
```

---

## Language Runtimes (via Mise)

### Ruby
```
Version: 3.x (latest stable)
Managed by: Mise
Package Manager: Bundler (v2.6.9+)
```

### Node.js
```
Version: LTS (22.x)
Managed by: Mise
Package Managers: npm, yarn
```

### Python
```
Version: 3.x (system default)
Package Manager: pip3
```

---

## Database Engines

### PostgreSQL
- **Status**: Installed & configured
- **Default User**: postgres
- **Default Password**: postgres (change for production!)
- **Port**: 5432
- **Tools**: psql, pgAdmin

### SQLite
- **Status**: Included with system
- **Use**: Lightweight local databases

---

## Development Frameworks & Libraries

### Web Frameworks
- **Rails** (Ruby) - 7.2.x
- **Express** (Node.js) - 4.x+
- **FastAPI** (Python) - via pip
- **Django** (Python) - via pip

### Testing
- **RSpec** (Ruby) - test framework
- **Jest** (Node.js) - test framework
- **pytest** (Python) - test framework

### Code Quality
- **RuboCop** (Ruby) - style checker
- **ESLint** (JavaScript) - linter
- **Pylint** (Python) - code analysis

---

## Container & Orchestration

```
Docker CE - Container engine
Docker CLI - Command-line interface
Docker Compose - Multi-container orchestration
containerd - Container runtime
```

---

## Utility Applications

| Tool | Purpose | Version |
|------|---------|---------|
| git | Version control | Latest |
| curl | HTTP client | Latest |
| wget | Download tool | Latest |
| vim/nano | Text editors | Latest |
| htop | Process monitor | Latest |
| 7zip | Archive tool | Latest |
| SSH | Remote access | OpenSSH |

---

## Installation Scripts in Repo

```
basic-setup.sh - Core development environment
install_complete_environment.sh - Full featured setup
install_cursor.sh - Cursor editor installation
install_bambu_studio.sh - Bambu Studio (3D printing)
install_cura.sh - Cura slicer (3D printing)
install_rubymine.sh - RubyMine IDE setup
install_dock_from_dash.sh - Dash dock integration
```

---

## Usage

### Install Fresh Environment
```bash
cd ~/software-projects/ubuntu-scripts
chmod +x install_complete_environment.sh
./install_complete_environment.sh
```

### Select Specific Packages
The installation script provides an interactive menu to select which packages to install.

### Update All Packages
```bash
sudo apt update && sudo apt upgrade -y
sudo snap refresh
```

---

## Version Management

### For Ruby/Node.js
```bash
# List available versions
mise list

# Install specific version
mise install ruby@3.2.0
mise install node@20

# Set global version
mise use --global ruby@3
```

### For Python
```bash
pip install --upgrade pip
pip3 install --user <package>
```

### For Node.js
```bash
npm install -g <package>
yarn global add <package>
```

---

## Notes

1. **PostgreSQL**: Default credentials are `postgres:postgres` - change these in production
2. **Docker**: User added to docker group, may need logout/login to take effect
3. **Mise**: Automatically activated in new shell sessions
4. **Snap**: Some packages (IDE) use snap; ensure snap is enabled
5. **Git**: Configure with global user.name and user.email before using

---

**Last Updated**: May 16, 2026  
**System**: Ubuntu/Debian Linux  
**Total Size**: ~50GB (including IDEs and VMs)
