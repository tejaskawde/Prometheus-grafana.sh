#!/bin/bash

# Exit on any error
set -e

# Check if version is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <prometheus_version>"
  exit 1
fi

PROMETHEUS_VERSION=$1
PROMETHEUS_DIR="/usr/local/bin"
BACKUP_DIR="/etc/prometheus_backup"
DATA_BACKUP_DIR="/var/lib/prometheus_backup"
PROMETHEUS_CONFIG="/etc/prometheus"
PROMETHEUS_DATA="/var/lib/prometheus"
DOWNLOAD_URL="https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"
TARBALL="prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"
EXTRACT_DIR="prometheus-$PROMETHEUS_VERSION.linux-amd64"

echo "Starting Prometheus upgrade to version $PROMETHEUS_VERSION..."

# Step 1: Backup Configuration Files
echo "Backing up configuration and data directories..."
sudo cp -r $PROMETHEUS_CONFIG $BACKUP_DIR
sudo cp -r $PROMETHEUS_DATA $DATA_BACKUP_DIR
echo "Backup completed."

# Step 2: Download the Latest Prometheus Binary
echo "Downloading Prometheus version $PROMETHEUS_VERSION..."
wget $DOWNLOAD_URL
echo "Extracting Prometheus tarball..."
tar -xvf $TARBALL

# Step 3: Stop Prometheus Service
echo "Stopping Prometheus service..."
sudo systemctl stop prometheus

# Step 4: Replace the Old Binary with the New Version
echo "Replacing old binaries with the new version..."
sudo mv $PROMETHEUS_DIR/prometheus $PROMETHEUS_DIR/prometheus_old
sudo mv $PROMETHEUS_DIR/promtool $PROMETHEUS_DIR/promtool_old
sudo cp $EXTRACT_DIR/prometheus $PROMETHEUS_DIR/
sudo cp $EXTRACT_DIR/promtool $PROMETHEUS_DIR/
echo "Binaries replaced successfully."

# Step 5: Restart Prometheus
echo "Restarting Prometheus service..."
sudo systemctl start prometheus
sudo systemctl status prometheus

# Cleanup
echo "Cleaning up downloaded files..."
rm -rf $TARBALL $EXTRACT_DIR

echo "Prometheus upgrade to version $PROMETHEUS_VERSION completed successfully!
