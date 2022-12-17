#!/bin/bash

# Prompt the user for the desired size of the journal directory in MB
read -p "Enter the desired size of the journal directory in MB: " JOURNAL_SIZE_MB

# Convert the size from MB to bytes
JOURNAL_SIZE=$((JOURNAL_SIZE_MB * 1024 * 1024))

# Set the path to the journal directory
JOURNAL_DIR="/var/log/journal"

# Set the name of the log recording service
LOG_SERVICE="systemd-journald"

# Check if the journal directory exists
if [ -d "$JOURNAL_DIR" ]; then
  # Set the size of the journal directory
  systemd-journal-size --disk-space=$JOURNAL_SIZE

  # Restart the log recording service to force log rotation
  systemctl restart $LOG_SERVICE

  # Print the size of the journal directory
  du -sh $JOURNAL_DIR
else
  echo "Error: Journal directory does not exist at $JOURNAL_DIR"
  exit 1
fi
