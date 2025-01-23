#!/bin/bash

# Exit on any error
set -e

# Check if version is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <blackbox_exporter_version>"
  exit 1
fi

BLACKBOX_VERSION=$1
BLACKBOX_DIR="/usr/local/bin"
BACKUP_DIR="/etc/blackbox_exporter_backup"
DATA_BACKUP_DIR="/var/lib/blackbox_exporter_backup"
BLACKBOX_CONFIG="/etc/blackbox_exporter"
BLACKBOX_DATA="/var/lib/blackbox_exporter"
DOWNLOAD_URL="https://github.com/prometheus/blackbox_exporter/releases/download/v$BLACKBOX_VERSION/blackbox_exporter-$BLACKBOX_VERSION.linux-amd64.tar.gz"
TARBALL="blackbox_exporter-$BLACKBOX_VERSION.linux-amd64.tar.gz"
EXTRACT_DIR="blackbox_exporter-$BLACKBOX_VERSION.linux-amd64"

echo "Starting Blackbox Exporter upgrade to version $BLACKBOX_VERSION..."

# Step 1: Backup Configuration Files
echo "Backing up configuration and data directories..."
sudo mkdir -p $BACKUP_DIR
sudo mkdir -p $DATA_BACKUP_DIR
sudo cp -r $BLACKBOX_CONFIG $BACKUP_DIR
sudo cp -r $BLACKBOX_DATA $DATA_BACKUP_DIR
echo "Backup completed."

# Step 2: Download the Latest Blackbox Exporter Binary
echo "Downloading Blackbox Exporter version $BLACKBOX_VERSION..."
wget --no-clobber $DOWNLOAD_URL

# Verify the file is downloaded
if [ ! -f "$TARBALL" ]; then
  echo "Error: Failed to download $TARBALL."
  exit 1
fi

echo "Extracting Blackbox Exporter tarball..."
tar -xzf $TARBALL || { echo "Error: Failed to extract $TARBALL. Exiting."; exit 1; }

# Step 3: Stop Blackbox Exporter Service
echo "Stopping Blackbox Exporter service..."
sudo systemctl stop blackbox_exporter

# Step 4: Replace the Old Binary with the New Version
echo "Replacing old binaries with the new version..."
sudo mv $BLACKBOX_DIR/blackbox_exporter $BLACKBOX_DIR/blackbox_exporter_old
sudo cp $EXTRACT_DIR/blackbox_exporter $BLACKBOX_DIR/
sudo chmod +x $BLACKBOX_DIR/blackbox_exporter
echo "Binaries replaced successfully."

# Step 5: Restart Blackbox Exporter
echo "Restarting Blackbox Exporter service..."
sudo systemctl start blackbox_exporter
sudo systemctl status blackbox_exporter

# Cleanup
echo "Cleaning up downloaded files..."
rm -rf $TARBALL $EXTRACT_DIR

echo "Blackbox Exporter upgrade to version $BLACKBOX_VERSION completed successfully!"
