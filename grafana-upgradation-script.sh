#!/bin/bash

# Exit on any error
set -e

# Check if version is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <grafana_version>"
  exit 1
fi

GRAFANA_VERSION=$1
GRAFANA_DIR="/usr/sbin"
BACKUP_DIR="/etc/grafana_backup"
DATA_BACKUP_DIR="/var/lib/grafana_backup"
GRAFANA_CONFIG="/etc/grafana"
GRAFANA_DATA="/var/lib/grafana"
DOWNLOAD_URL="https://dl.grafana.com/oss/release/grafana-$GRAFANA_VERSION.linux-amd64.tar.gz"
TARBALL="grafana-$GRAFANA_VERSION.linux-amd64.tar.gz"
EXTRACT_DIR="grafana-$GRAFANA_VERSION"

echo "Starting Grafana upgrade to version $GRAFANA_VERSION..."

# Step 1: Backup Configuration Files
echo "Backing up configuration and data directories..."
sudo mkdir -p $BACKUP_DIR
sudo mkdir -p $DATA_BACKUP_DIR
sudo cp -r $GRAFANA_CONFIG $BACKUP_DIR
sudo cp -r $GRAFANA_DATA $DATA_BACKUP_DIR
echo "Backup completed."

# Step 2: Download the Latest Grafana Binary
echo "Downloading Grafana version $GRAFANA_VERSION..."
wget $DOWNLOAD_URL
echo "Extracting Grafana tarball..."
tar -xvf $TARBALL

# Step 3: Stop Grafana Service
echo "Stopping Grafana service..."
sudo systemctl stop grafana-server

# Step 4: Replace the Old Binary with the New Version
echo "Replacing old binaries with the new version..."
sudo mv $GRAFANA_DIR/grafana-server $GRAFANA_DIR/grafana-server_old
sudo cp $EXTRACT_DIR/bin/* $GRAFANA_DIR/
echo "Binaries replaced successfully."

# Step 5: Restart Grafana
echo "Restarting Grafana service..."
sudo systemctl start grafana-server
sudo systemctl status grafana-server

# Cleanup
echo "Cleaning up downloaded files..."
rm -rf $TARBALL $EXTRACT_DIR

echo "Grafana upgrade to version $GRAFANA_VERSION completed successfully!"
