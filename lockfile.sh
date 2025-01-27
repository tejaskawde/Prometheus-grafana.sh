#!/bin/bash

PROMETHEUS_DATA_DIR="/var/lib/prometheus"
LOCK_FILE="$PROMETHEUS_DATA_DIR/LOCK"

# Check if Prometheus is running
if pgrep -x "prometheus" > /dev/null; then
    echo "Prometheus is running. Please stop it before cleaning the lock file."
    exit 1
fi

# Check if the lock file exists
if [ -f "$LOCK_FILE" ]; then
    echo "Lock file found. Removing it..."
    rm -f "$LOCK_FILE"
    echo "Lock file removed."
else
    echo "No lock file found."
fi

# Restart Prometheus
echo "Restarting Prometheus..."
sudo systemctl start prometheus
echo "Prometheus restarted successfully."
