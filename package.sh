#!/bin/bash

# Check if the system is Debian or Ubuntu
if [ -f /etc/debian_version ]; then
  # Replace the current apt sources list with the one at the specified URL
  sudo curl -o /etc/apt/sources.list https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/debian.txt
elif [ -f /etc/lsb-release ]; then
  # Replace the current apt sources list with the one at the specified URL
  sudo curl -o /etc/apt/sources.list https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/ubuntu.txt
else
  # Print a message indicating that the system is not supported
  echo "This system is not supported. The apt sources will not be modified."
fi

# Update the package list to pick up the new sources
sudo apt update
