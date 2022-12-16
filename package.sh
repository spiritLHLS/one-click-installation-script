#!/bin/bash


#!/bin/bash

change_debian_apt_sources() {
  # 获取系统版本
  release=$(lsb_release -cs)

  # 根据版本替换源列表
  case "$release" in
    "squeeze")
      # Debian 6 "Squeeze"
      # 替换源列表
      sed -i 's/deb http:\/\/deb.debian.org\/debian squeeze main/deb http:\/\/mirrors.aliyun.com\/debian squeeze main/g' /etc/apt/sources.list
      ;;
    "wheezy")
      # Debian 7 "Wheezy"
      # 替换源列表
      sed -i 's/deb http:\/\/deb.debian.org\/debian wheezy main/deb http:\/\/mirrors.aliyun.com\/debian wheezy main/g' /etc/apt/sources.list
      ;;
    "jessie")
      # Debian 8 "Jessie"
      # 替换源列表
      sed -i 's/deb http:\/\/deb.debian.org\/debian jessie main/deb http:\/\/mirrors.aliyun.com\/debian jessie main/g' /etc/apt/sources.list
      ;;
    "stretch")
      # Debian 9 "Stretch"
      # 替换源列表
      sed -i 's/deb http:\/\/deb.debian.org\/debian stretch main/deb http:\/\/mirrors.aliyun.com\/debian stretch main/g' /etc/apt/sources.list
      ;;
    "buster")
      # Debian 10 "Buster"
      # 替换源列表
      sed -i 's/deb http:\/\/deb.debian.org\/debian buster main/deb http:\/\/mirrors.aliyun.com\/debian buster main/g' /etc/apt/sources.list
      ;;
    "bullseye")
      # Debian 11 "Bullseye"
      # 替换源列表
      sed -i 's/deb http:\/\/deb.debian.org\/debian bullseye main/deb http:\/\/mirrors.aliyun.com\/debian bullseye main/g' /etc/apt/sources.list
      ;;
    *)
      # 其他版本
      # 不进行任何操作
      echo "The system is not Debian 6/7/8/9/10/11 . No changes were made to the apt sources."
      return
      ;;
  esac
}

change_ubuntu_apt_sources {
  # Check the system's Ubuntu version
  ubuntu_version=$(lsb_release -r | awk '{print $2}')
  
  if [ "$ubuntu_version" = "12.04" ]; then
    # Backup the current sources.list
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    # Write the Ubuntu 12.04 apt sources list that can be used with apt to sources.list
    echo "deb http://old-releases.ubuntu.com/ubuntu precise main restricted universe multiverse" | sudo tee /etc/apt/sources.list
    echo "deb http://old-releases.ubuntu.com/ubuntu precise-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    echo "deb http://old-releases.ubuntu.com/ubuntu precise-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
  elif [ "$ubuntu_version" = "14.04" ]; then
    # Backup the current sources.list
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    # Write the standard Ubuntu 14.04 apt sources list to sources.list
    echo "deb http://archive.ubuntu.com/ubuntu trusty main restricted universe multiverse" | sudo tee /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu trusty-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu trusty-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
  elif [ "$ubuntu_version" = "16.04" ]; then
    # Backup the current sources.list
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    # Write the standard Ubuntu 16.04 apt sources list to sources.list
    echo "deb http://archive.ubuntu.com/ubuntu xenial main restricted universe multiverse" | sudo tee /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu xenial-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu xenial-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
  elif [ "$ubuntu_version" = "18.04" ]; then
    # Backup the current sources.list
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    # Write the standard Ubuntu 18.04 apt sources list to sources.list
    echo "deb http://archive.ubuntu.com/ubuntu bionic main restricted universe multiverse" | sudo tee /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu bionic-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu bionic-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
  elif [ "$ubuntu_version" = "20.04" ]; then
    # Backup the current sources.list
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    # Write the standard Ubuntu 20.04 apt sources list to sources.list
    echo "deb http://archive.ubuntu.com/ubuntu focal main restricted universe multiverse" | sudo tee /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu focal-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu focal-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu focal-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
  elif [ "$ubuntu_version" = "22.04" ]; then
    # Backup the current sources.list
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    # Write the standard Ubuntu 22.04 apt sources list to sources.list
    echo "deb http://archive.ubuntu.com/ubuntu hirsute main restricted universe multiverse" | sudo tee /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu hirsute-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu hirsute-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu hirsute-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
  else
    echo "The system is not Ubuntu 12/14/16/18/20/22 . No changes were made to the apt sources."
  fi



##############################################################################################################################################


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
    #sudo curl -o /etc/apt/sources.list https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/debian.txt
    # 获取系统版本
    release=$(lsb_release -cs)

    # 获取源列表中的版本
    sources_release=$(grep "^deb" /etc/apt/sources.list | head -n1 | cut -d' ' -f3)

    # 如果版本不同，则执行 change_debian_apt_sources 函数
    if [ "$release" != "$sources_release" ]; then
      change_debian_apt_sources
    fi
  elif [ -f /etc/lsb-release ]; then
    # Replace the current apt sources list with the one at the specified URL
    # sudo curl -o /etc/apt/sources.list https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/ubuntu.txt
    # 获取系统版本
    release=$(lsb_release -cs)

    # 获取源列表中的版本
    sources_release=$(grep "^deb" /etc/apt/sources.list | head -n1 | cut -d' ' -f3)

    # 如果版本不同，则执行 change_apt_sources 函数
    if [ "$release" != "$sources_release" ]; then
      change_ubuntu_apt_sources
    fi
  else
    # Print a message indicating that the system is not supported
    echo "This system is not supported. The apt sources will not be modified."
  fi

  # Update the package list again to pick up the new sources
  sudo apt update
fi
