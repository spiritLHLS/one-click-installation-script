#!/bin/bash

sudo apt update

if [ $? -ne 0 ]; then
  echo "The update failed. Attempting to unlock the apt sources..."
  if [ -f /etc/debian_version ]; then
    sudo rm /var/lib/apt/lists/lock
    sudo rm /var/cache/apt/archives/lock
  elif [ -f /etc/lsb-release ]; then
    sudo rm /var/lib/dpkg/lock
    sudo rm /var/cache/apt/archives/lock
  fi
  sudo apt update
  if [ $? -ne 0 ]; then
    echo "The update still failed. Attempting to fix missing GPG keys..."
    if [ -f /etc/debian_version ]; then
      sudo apt-key update
    elif [ -f /etc/lsb-release ]; then
      echo "try sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys missing key"
    fi
  fi
fi

# Update the package list to pick up the new sources
sudo apt update

# Check the exit status of the update command
if [ $? -ne 0 ]; then
  # Print a message indicating that the update failed
  echo "The update failed. Attempting to replace the apt sources..."

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

  # Update the package list again to pick up the new sources
  sudo apt update
fi
