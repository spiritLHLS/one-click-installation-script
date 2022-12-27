#!/usr/bin/env bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2022.12.27

# Check if C++ is installed
if ! type "g++" > /dev/null; then
  # Install C++ if it is not installed
  echo "C++ is not installed. Installing C++..."
  # Check OS and install C++ using appropriate package manager
  if type "apt-get" > /dev/null; then
    # Ubuntu, Debian
    sudo apt-get update
    sudo apt-get install g++
  elif type "yum" > /dev/null; then
    # CentOS, Fedora, AlmaLinux
    sudo yum update
    sudo yum install gcc-c++
  else
    echo "Error: unknown operating system. C++ installation failed."
    exit 1
  fi
else
  # Get C++ version
  g++ --version
  # Ask if the user wants to update C++
  read -p "Do you want to update C++? (y/n) " -n 1 -r
  echo
  # Update C++ if the user chose to update
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Updating C++..."
    # Check OS and update C++ using appropriate package manager
    if type "apt-get" > /dev/null; then
      # Ubuntu, Debian
      sudo apt-get update
      sudo apt-get install g++
    elif type "yum" > /dev/null; then
      # CentOS, Fedora, AlmaLinux
      sudo yum update
      sudo yum install gcc-c++
    else
      echo "Error: unknown operating system. C++ update failed."
      exit 1
    fi
  fi
fi
