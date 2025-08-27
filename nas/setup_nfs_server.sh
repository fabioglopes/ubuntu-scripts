#!/bin/bash

# NFS Server Setup Script for fabionas (192.168.15.53)
# This script sets up persistent NFS shares for sdc1 and sdc2 partitions

set -e  # Exit on any error

echo "=== NFS Server Setup Script ==="
echo "Setting up persistent NFS shares for sdc partitions..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# 1. Install required packages
echo "Installing NFS server packages..."
apt update
apt install -y nfs-kernel-server nfs-common

# 2. Create mount points for the partitions
echo "Creating mount points..."
mkdir -p /mnt/sdc1 /mnt/sdc2

# 3. Create NFS export directories
echo "Creating NFS export directories..."
mkdir -p /srv/nfs/sdc1 /srv/nfs/sdc2

# 4. Add entries to /etc/fstab for persistent mounting of partitions
echo "Adding persistent mounts to /etc/fstab..."

# Backup fstab
cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d_%H%M%S)

# Add sdc partition mounts if not already present
if ! grep -q "/dev/sdc1" /etc/fstab; then
    echo "/dev/sdc1 /mnt/sdc1 ntfs defaults,uid=1000,gid=1000,umask=0022 0 0" >> /etc/fstab
    echo "Added sdc1 mount to fstab"
fi

if ! grep -q "/dev/sdc2" /etc/fstab; then
    echo "/dev/sdc2 /mnt/sdc2 ext4 defaults 0 2" >> /etc/fstab
    echo "Added sdc2 mount to fstab"
fi

# Add bind mounts for NFS exports
if ! grep -q "/srv/nfs/sdc1" /etc/fstab; then
    echo "/mnt/sdc1 /srv/nfs/sdc1 none bind 0 0" >> /etc/fstab
    echo "Added sdc1 bind mount to fstab"
fi

if ! grep -q "/srv/nfs/sdc2" /etc/fstab; then
    echo "/mnt/sdc2 /srv/nfs/sdc2 none bind 0 0" >> /etc/fstab
    echo "Added sdc2 bind mount to fstab"
fi

# 5. Mount all filesystems
echo "Mounting filesystems..."
mount -a

