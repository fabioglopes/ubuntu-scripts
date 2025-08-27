#!/bin/bash

# NFS Client Setup Script
# This script sets up NFS client to connect to fabionas (192.168.15.53)

set -e  # Exit on any error

echo "=== NFS Client Setup Script ==="
echo "Setting up NFS client to connect to fabionas..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# 1. Install NFS client
echo "Installing NFS client..."
apt update
apt install -y nfs-common

# 2. Create mount points
echo "Creating mount points..."
mkdir -p /mnt/nfs/{sdc1,sdc2,wd1tb,home,general}

# 3. Backup fstab
echo "Backing up fstab..."
cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d_%H%M%S)

# 4. Add NFS mounts to fstab for persistence
echo "Adding NFS mounts to fstab..."

# Remove any existing entries for these mounts
sed -i '/192.168.15.53:/d' /etc/fstab

# Add new entries
cat >> /etc/fstab << 'EOL'

# NFS mounts to fabionas (192.168.15.53)
192.168.15.53:/srv/nfs/sdc1 /mnt/nfs/sdc1 nfs defaults,_netdev 0 0
192.168.15.53:/srv/nfs/sdc2 /mnt/nfs/sdc2 nfs defaults,_netdev 0 0
192.168.15.53:/mnt/wd1tb /mnt/nfs/wd1tb nfs defaults,_netdev 0 0
192.168.15.53:/home /mnt/nfs/home nfs defaults,_netdev 0 0
192.168.15.53:/var/nfs/general /mnt/nfs/general nfs defaults,_netdev 0 0
EOL

# 5. Mount all NFS shares
echo "Mounting NFS shares..."
mount -a

# 6. Show mounted filesystems
echo ""
echo "=== Mounted NFS Shares ==="
df -h | grep "192.168.15.53"

echo ""
echo "=== Client Setup Complete! ==="
echo "NFS shares are now mounted and will persist after reboot."
echo ""
echo "Access points:"
echo "- /mnt/nfs/sdc1 (NTFS partition)"
echo "- /mnt/nfs/sdc2 (Linux partition)"  
echo "- /mnt/nfs/wd1tb (1TB drive)"
echo "- /mnt/nfs/home (Home directories)"
echo "- /mnt/nfs/general (General storage)"
echo ""
echo "Open in Nautilus with: nautilus /mnt/nfs/"

