#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2022.12.18

red(){ echo -e "\033[31m\033[01m$1$2\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }

head() {
  # 支持系统：Ubuntu 12+，Debian 6+
  ver="2022.12.18"
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
  echo "4.修复本机的Ubuntu系统是EOL非长期维护的版本，将替换为Ubuntu官方的old-releases仓库以支持apt的使用"
  # Display prompt asking whether to proceed with checking
  reading "Do you want to proceed with checking? [y/n] " confirm
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

  # Use official sources list if IP is not in China
  if [ "$location" != "China" ]; then
    URL="deb.debian.org/debian"
  else
    # Use mirrors.aliyun.com sources list if IP is in China
    URL="mirrors.aliyun.com/debian"
  fi

  # Set Debian release based on Debian version
  case $DEBIAN_VERSION in
    6.0) DEBIAN_RELEASE="squeeze";;
    7.0) DEBIAN_RELEASE="wheezy";;
    8.0) DEBIAN_RELEASE="jessie";;
    9.0) DEBIAN_RELEASE="stretch";;
    10.0) DEBIAN_RELEASE="buster";;
    11.0) DEBIAN_RELEASE="bullseye";;
    *) echo "The system is not Debian 6/7/8/9/10/11 . No changes were made to the apt-get sources." && return 1;;
  esac
  
  # Write sources list in the desired format
  cat > /etc/apt/sources.list <<EOF
deb ${URL} ${DEBIAN_RELEASE} main contrib non-free
deb ${URL} ${DEBIAN_RELEASE}-updates main contrib non-free
deb ${URL} ${DEBIAN_RELEASE}-backports main contrib non-free
deb http://security.debian.org/ ${DEBIAN_RELEASE}/updates main contrib non-free
deb-src ${URL} ${DEBIAN_RELEASE} main contrib non-free
deb-src ${URL} ${DEBIAN_RELEASE}-updates main contrib non-free
deb-src ${URL} ${DEBIAN_RELEASE}-backports main contrib non-free
deb-src http://security.debian.org/ ${DEBIAN_RELEASE}/updates main contrib non-free
EOF
}


change_ubuntu_apt_sources() {
  # Check if the IP is in China
  ip=$(curl -s https://ipapi.co/ip)
  location=$(curl -s https://ipapi.co/$ip/country_name)
  
  # Check the system's Ubuntu version
  UBUNTU_VERSION=$(lsb_release -r | awk '{print $2}')

  # Use official sources list if IP is not in China
  if [ "$location" != "China" ]; then
    URL="archive.ubuntu.com/ubuntu"
  else
    # Use mirrors.aliyun.com sources list if IP is in China
    URL="mirrors.aliyun.com/ubuntu"
  fi

  # Set Ubuntu release based on Ubuntu version
  case $UBUNTU_VERSION in
    # 14.04) UBUNTU_RELEASE="trusty";;
    16.04) UBUNTU_RELEASE="xenial";;
    18.04) UBUNTU_RELEASE="bionic";;
    20.04) UBUNTU_RELEASE="focal";;
    22.04) UBUNTU_RELEASE="groovy";;
    *) echo "The system is not Ubuntu 14/16/18/20/22 . No changes were made to the apt-get sources." && return 1;;
  esac
  
  # Backup current sources list
  sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
  # Write sources list in the desired format
  cat > /etc/apt/sources.list <<EOF
deb ${URL} ${UBUNTU_RELEASE} main restricted universe multiverse
deb ${URL} ${UBUNTU_RELEASE}-security main restricted universe multiverse
deb ${URL} ${UBUNTU_RELEASE}-updates main restricted universe multiverse
deb ${URL} ${UBUNTU_RELEASE}-backports main restricted universe multiverse
deb-src ${URL} ${UBUNTU_RELEASE} main restricted universe multiverse
deb-src ${URL} ${UBUNTU_RELEASE}-security main restricted universe multiverse
deb-src ${URL} ${UBUNTU_RELEASE}-updates main restricted universe multiverse
deb-src ${URL} ${UBUNTU_RELEASE}-backports main restricted universe multiverse
EOF
}



check_eol_and_switch_apt_source() {
  # 获取系统版本
  version=$(lsb_release -cs)

  # 检查系统版本是否已经过期
  eol=$(curl -s https://ubuntu.com/dists/${version}/Release | grep "EOL" | wc -l)
  if [ $eol -gt 0 ]; then
    # 版本已经过期
    reading "This version of Ubuntu is EOL. Do you want to switch to the old-releases repository? [y/n] " confirm
    if [ "$confirm" == "Y" ] || [ "$confirm" == "y" ]; then
      # 修改apt源
      sed -i -e "s/archive.ubuntu.com/old-releases.ubuntu.com/g" /etc/apt/sources.list
      apt-get update
    fi
  else
    # 版本未过期
    echo "This version of Ubuntu is not EOL. No need to switch repositories."
  fi
}


fix_broken() {
  # Check if the output of the update contains "--fix-broken install"
  if apt-get update | grep -F -- '--fix-broken' | grep -F -- 'install'; then
    # If it does, run apt-get --fix-broken install -y
    apt-get --fix-broken install -y
    apt-get update
    if [ $? -eq 0 ]; then
      # Print a message indicating that the update was successful
      green "The apt-get update was successful."
      exit 0
    fi
  fi
}

fix_locked() {
  if [ $? -ne 0 ]; then
    echo "The update failed. Attempting to unlock the apt-get sources..."
    if [ -f /etc/debian_version ]; then
      sudo rm /var/lib/apt/lists/lock
      sudo rm /var/cache/apt/archives/lock
    elif [ -f /etc/lsb-release ]; then
      sudo rm /var/lib/dpkg/lock
      sudo rm /var/cache/apt/archives/lock
    fi
    
    sudo apt-get update
    
    if [ $? -eq 0 ]; then
      # Print a message indicating that the update was successful
      green "The apt-get update was successful."
      exit 0
    fi
  
    if [ $? -ne 0 ]; then
      yellow "The update still failed. Attempting to fix missing GPG keys..."
      if [ -f /etc/debian_version ]; then
        sudo apt-key update
      elif [ -f /etc/lsb-release ]; then
        red "try sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys missing key"
      fi
    fi
  fi
}

fix_sources() {
  # Update the package list to pick up the new sources
  sudo apt-get update
  
  if [ $? -eq 0 ]; then
      # Print a message indicating that the update was successful
      green "The apt-get update was successful."
      exit 0
  fi

  # Check the exit status of the update command
  if [ $? -ne 0 ]; then
    # Print a message indicating that the update failed
    yellow "The update failed. Attempting to replace the apt-get sources..."

    # Check if the system is Debian or Ubuntu
    if [ -f /etc/debian_version ]; then
      # Replace the current apt-get sources list with the one at the specified URL
      #sudo curl -o /etc/apt/sources.list https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/debian.txt
      # Display prompt asking whether to proceed with updating
      reading "Do you want to proceed with updating? [y/n] " updating
      echo ""

      # Check user's input and exit if they do not want to proceed
      if [ "$updating" != "y" ]; then
        exit 0
      else
        change_debian_apt_sources
      fi
    elif [ -f /etc/lsb-release ]; then
      # Replace the current apt-get sources list with the one at the specified URL
      # sudo curl -o /etc/apt/sources.list https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/ubuntu.txt
      
      # Display prompt asking whether to proceed with updating
      reading "Do you want to proceed with updating? [y/n] " updating
      echo ""

      # Check user's input and exit if they do not want to proceed
      if [ "$updating" != "y" ]; then
        exit 0
      else
        check_eol_and_switch_apt_source
        change_ubuntu_apt_sources
      fi
    else
      # Print a message indicating that the system is not supported
      red "This system is not supported. The apt-get sources will not be modified."
    fi
    # Update the package list again to pick up the new sources
    sudo apt-get update

    # Check the exit status of the update command
    if [ $? -eq 0 ]; then
      # Print a message indicating that the update was successful
      green "The apt-get update was successful."
    else
      # Print a message indicating that the update failed and suggest other error resolution methods
      red "The update failed. You may want to try the following error resolution methods:
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
sleep 1
fix_locked
sleep 1
fix_sources
