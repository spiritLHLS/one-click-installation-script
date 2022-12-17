#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2022.12.17


head() {
  # 支持系统：Ubuntu 12+，Debian 6+
  ver="2022.12.17"
  changeLog="一键修复apt源，加载对应的源"
  clear
  echo "#######################################################################"
  echo "#                     ${YELLOW}一键修复apt源脚本${PLAIN}                               #"
  echo "# 版本：$ver                                                    #"
  echo "# 更新日志：$changeLog                               #"
  echo "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
  echo "# ${GREEN}作仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script #"
  echo "#######################################################################"
  echo "支持系统：Ubuntu 12+，Debian 6+"
  echo "0.修复apt源broken损坏"
  echo "1.修复apt源锁死"
  echo "2.修复apt源公钥缺失"
  echo "3.修复替换系统可用的apt源列表，国内用阿里源，国外用官方源"
  # Display prompt asking whether to proceed with checking
  read -p "Do you want to proceed with checking? [y/n] " -n 1 confirm
  echo ""

  # Check user's input and exit if they do not want to proceed
  if [ "$confirm" != "y" ]; then
    exit 0
  fi
}


change_debian_apt_sources() {
  # Check if the IP is in China
  ip=$(curl -s https://ipapi.co/ip)
  location=$(curl -s https://ipapi.co/$ip/country_name)
  
  # Backup current sources list
  cp /etc/apt/sources.list /etc/apt/sources.list.bak
  # Determine Debian version
  DEBIAN_VERSION=$(lsb_release -sr)

  if [ "$location" = "China" ]; then
    # IP is in China, update apt sources
    echo "IP is in China, updating apt sources."
    if [ "$DEBIAN_VERSION" = "6.0" ]; then
      # Debian 6
      cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/debian/ squeeze main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ squeeze main non-free contrib
EOF
    elif [ "$DEBIAN_VERSION" = "7.0" ]; then
      # Debian 7
      cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/debian/ wheezy main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ wheezy main non-free contrib
EOF
    elif [ "$DEBIAN_VERSION" = "8.0" ]; then
      # Debian 8
      cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/debian/ jessie main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ jessie main non-free contrib
EOF
    elif [ "$DEBIAN_VERSION" = "9.0" ]; then
      # Debian 9
      cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ stretch main non-free contrib
EOF
    elif [ "$DEBIAN_VERSION" = "10.0" ]; then
      # Debian 10
      cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/debian/ buster main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster main non-free contrib
EOF
    elif [ "$DEBIAN_VERSION" = "11.0" ]; then
      # Debian 11
      cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/debian/ bullseye main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ bullseye main non-free contrib
EOF
    fi
  else
    # IP is not in China, update apt sources
    echo "IP is not in China, updating apt sources."
    # Use official sources list for Debian 6
    if [[ $DEBIAN_VERSION == 6 ]]; then
      cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian squeeze main contrib non-free
deb-src http://deb.debian.org/debian squeeze main contrib non-free

deb http://deb.debian.org/debian squeeze-updates main contrib non-free
deb-src http://deb.debian.org/debian squeeze-updates main contrib non-free

deb http://security.debian.org/ squeeze/updates main contrib non-free
deb-src http://security.debian.org/ squeeze/updates main contrib non-free
EOF
    # Use official sources list for Debian 7
    elif [[ $DEBIAN_VERSION == 7 ]]; then
      cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian wheezy main contrib non-free
deb-src http://deb.debian.org/debian wheezy main contrib non-free

deb http://deb.debian.org/debian wheezy-updates main contrib non-free
deb-src http://deb.debian.org/debian wheezy-updates main contrib non-free

deb http://security.debian.org/ wheezy/updates main contrib non-free
deb-src http://security.debian.org/ wheezy/updates main contrib non-free
EOF
   # Use official sources list for Debian 8
    elif [[ $DEBIAN_VERSION == 8 ]]; then
      cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian jessie main contrib non-free
deb-src http://deb.debian.org/debian jessie main contrib non-free

deb http://deb.debian.org/debian jessie-updates main contrib non-free
deb-src http://deb.debian.org/debian jessie-updates main contrib non-free

deb http://security.debian.org/ jessie/updates main contrib non-free
deb-src http://security.debian.org/ jessie/updates main contrib non-free
EOF
    # Use official sources list for Debian 9
    elif [[ $DEBIAN_VERSION == 9 ]]; then
      cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian stretch main contrib non-free
deb-src http://deb.debian.org/debian stretch main contrib non-free

deb http://deb.debian.org/debian stretch-updates main contrib non-free
deb-src http://deb.debian.org/debian stretch-updates main contrib non-free

deb http://security.debian.org/ stretch/updates main contrib non-free
deb-src http://security.debian.org/ stretch/updates main contrib non-free
EOF
    # Use official sources list for Debian 10
    elif [[ $DEBIAN_VERSION == 10 ]]; then
      cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian buster main contrib non-free
deb-src http://deb.debian.org/debian buster main contrib non-free

deb http://deb.debian.org/debian buster-updates main contrib non-free
deb-src http://deb.debian.org/debian buster-updates main contrib non-free

deb http://security.debian.org/ buster/updates main contrib non-free
deb-src http://security.debian.org/ buster/updates main contrib non-free
EOF
    # Use official sources list for Debian 11
    elif [[ $DEBIAN_VERSION == 11 ]]; then
      cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian bullseye main contrib non-free
deb-src http://deb.debian.org/debian bullseye main contrib non-free

deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb-src http://deb.debian.org/debian bullseye-updates main contrib non-free

deb http://security.debian.org/ bullseye/updates main contrib non-free
deb-src http://security.debian.org/ bullseye/updates main contrib non-free
EOF
    fi
  fi
}


change_ubuntu_apt_sources() {
  # Check if the IP is in China
  ip=$(curl -s https://ipapi.co/ip)
  location=$(curl -s https://ipapi.co/$ip/country_name)
  
  # Check the system's Ubuntu version
  ubuntu_version=$(lsb_release -r | awk '{print $2}')
  if [ "$location" = "China" ]; then
    # IP is in China, update apt sources
    echo "IP is in China, updating apt sources."
    # Backup the current sources.list
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    if [ "$ubuntu_version" = "12.04" ]; then
      # Write the AliYun Ubuntu 12.04 apt sources list to sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ precise main restricted universe multiverse" | sudo tee /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ precise-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ precise-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    elif [ "$ubuntu_version" = "14.04" ]; then
      # Write the AliYun Ubuntu 14.04 apt sources list to sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse" | sudo tee /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    elif [ "$ubuntu_version" = "16.04" ]; then
      # Write the AliYun Ubuntu 16.04 apt sources list to sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse" | sudo tee /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    elif [ "$ubuntu_version" = "18.04" ]; then
      # Write the AliYun Ubuntu 18.04 apt sources list to sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" | sudo tee /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    elif [ "$ubuntu_version" = "20.04" ]; then
      # Write the AliYun Ubuntu 20.04 apt sources list to sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse" | sudo tee /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    elif [ "$ubuntu_version" = "22.04" ]; then
      # Write the AliYun Ubuntu 22.04 apt sources list to sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ groovy main restricted universe multiverse" | sudo tee /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ groovy-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ groovy-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://mirrors.aliyun.com/ubuntu/ groovy-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    fi
  else:
    # Backup the current sources.list
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    if [ "$ubuntu_version" = "12.04" ]; then
      # Write the Ubuntu 12.04 apt sources list that can be used with apt to sources.list
      echo "deb http://old-releases.ubuntu.com/ubuntu precise main restricted universe multiverse" | sudo tee /etc/apt/sources.list
      echo "deb http://old-releases.ubuntu.com/ubuntu precise-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://old-releases.ubuntu.com/ubuntu precise-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    elif [ "$ubuntu_version" = "14.04" ]; then
      # Write the standard Ubuntu 14.04 apt sources list to sources.list
      echo "deb http://archive.ubuntu.com/ubuntu trusty main restricted universe multiverse" | sudo tee /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu trusty-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu trusty-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    elif [ "$ubuntu_version" = "16.04" ]; then
      # Write the standard Ubuntu 16.04 apt sources list to sources.list
      echo "deb http://archive.ubuntu.com/ubuntu xenial main restricted universe multiverse" | sudo tee /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu xenial-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu xenial-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    elif [ "$ubuntu_version" = "18.04" ]; then
      # Write the standard Ubuntu 18.04 apt sources list to sources.list
      echo "deb http://archive.ubuntu.com/ubuntu bionic main restricted universe multiverse" | sudo tee /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu bionic-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu bionic-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    elif [ "$ubuntu_version" = "20.04" ]; then
      # Write the standard Ubuntu 20.04 apt sources list to sources.list
      echo "deb http://archive.ubuntu.com/ubuntu focal main restricted universe multiverse" | sudo tee /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu focal-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu focal-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu focal-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    elif [ "$ubuntu_version" = "22.04" ]; then
      # Write the standard Ubuntu 22.04 apt sources list to sources.list
      echo "deb http://archive.ubuntu.com/ubuntu hirsute main restricted universe multiverse" | sudo tee /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu hirsute-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu hirsute-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
      echo "deb http://archive.ubuntu.com/ubuntu hirsute-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    else
      echo "The system is not Ubuntu 12/14/16/18/20/22 . No changes were made to the apt sources."
    fi
  fi
}

fix_broken() {
  # Check if the output of the update contains "--fix-broken install"
  if apt update | grep -q "--fix-broken install"; then
    # If it does, run apt --fix-broken install -y
    apt --fix-broken install -y
    apt update
  fi
}

fix_locked() {
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
}

fix_sources() {
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
        echo "debian source is wrong"
      fi
      # Display prompt asking whether to proceed with updating
      read -p "Do you want to proceed with updating? [y/n] " -n 1 updating
      echo ""

      # Check user's input and exit if they do not want to proceed
      if [ "$updating" != "y" ]; then
        exit 0
      else
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
        echo "ubuntu source is wrong"
      fi
      # Display prompt asking whether to proceed with updating
      read -p "Do you want to proceed with updating? [y/n] " -n 1 updating
      echo ""

      # Check user's input and exit if they do not want to proceed
      if [ "$updating" != "y" ]; then
        exit 0
      else
        change_ubuntu_apt_sources
      fi
    else
      # Print a message indicating that the system is not supported
      echo "This system is not supported. The apt sources will not be modified."
    fi
    # Update the package list again to pick up the new sources
    sudo apt update

    # Check the exit status of the update command
    if [ $? -eq 0 ]; then
      # Print a message indicating that the update was successful
      echo "The update was successful."
    else
      # Print a message indicating that the update failed and suggest other error resolution methods
      echo "The update failed. You may want to try the following error resolution methods:
        - Check your internet connection
        - Check the sources list for errors
        - Check for package dependencies
        - Check for disk space issues"
    fi
  fi
}


##############################################################################################################################################


head
fix_broken
fix_locked
fix_sources
