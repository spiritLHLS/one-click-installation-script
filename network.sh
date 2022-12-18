#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2022.12.18

red(){ echo -e "\033[31m\033[01m$1$2\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }

head() {
  # 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
  ver="2022.12.18"
  changeLog="一键修复linux网络脚本"
  clear
  echo "#######################################################################"
  echo "#                     ${YELLOW}一键修复linux网络脚本${PLAIN}                           #"
  echo "# 版本：$ver                                                    #"
  echo "# 更新日志：$changeLog                                     #"
  echo "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
  echo "# ${GREEN}作仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script #"
  echo "#######################################################################"
  echo "支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+"
  echo "1.检测ping谷歌如果有问题修改nameserver为google源或cloudflare源"
  echo "2.检测ping谷歌还有问题尝试修复为IP类型对应的网络优先级(默认IPV4类型，纯V6类型再替换为IPV6类型)"
  # Display prompt asking whether to proceed with checking and changing
  reading "Do you want to proceed with checking and changing nameserver? [y/n] " confirm
  echo ""

  # Check user's input and exit if they do not want to proceed
  if [ "$confirm" != "y" ]; then
    exit 0
  fi
}


main() {
  # Backup /etc/resolv.conf and /etc/gai.conf
  cp /etc/resolv.conf /etc/resolv.conf.bak
  yellow "Backed up /etc/resolv.conf to /etc/resolv.conf.bak"
  cp /etc/gai.conf /etc/gai.conf.bak
  yellow "Backed up /etc/gai.conf to /etc/gai.conf.bak"

  # Check if ping to google.com is successful
  if ping -c 1 google.com; then
    green "Ping successful, no need modify"
  else
    yellow "Ping failed. Checking nameserver."
  
    # Check current nameserver
    nameserver=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
    yellow "Current nameserver: $nameserver"

    # Try using Google's nameserver
    green "Trying Google's nameserver: 8.8.8.8"
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    if ping -c 1 google.com; then
      green "Ping successful with Google's nameserver"
    else
      yellow "Ping failed with Google's nameserver. Trying Cloudflare's nameserver."

      # Try using Cloudflare's nameserver
      green "Trying Cloudflare's nameserver: 1.1.1.1"
      echo "nameserver 1.1.1.1" > /etc/resolv.conf
      if ping -c 1 google.com; then
        green "Ping successful with Cloudflare's nameserver"
      else
        yellow "Ping failed with Cloudflare's nameserver. Checking network configuration."

        # Display prompt asking whether to proceed with checking and changing priority
        read -p "Do you want to proceed with checking and changing network priority? [y/n] " priority
        echo ""

        # Check user's input and exit if they do not want to proceed
        if [ "$priority" != "y" ]; then
          exit 0
        fi

        # Set initial network priority to IPv4
        echo "precedence ::ffff:0:0/96 50" > /etc/gai.conf

        # Restart network interface
        sudo ifconfig eth0 down
        sudo ifconfig eth0 up

        # Try pinging with IPv4 network priority
        if ping -c 1 google.com; then
          green "Ping successful with IPv4 network priority"
        else
          # Set network priority to IPv6
          echo "precedence ::/0 100" > /etc/gai.conf

          # Restart network interface
          sudo ifconfig eth0 down
          sudo ifconfig eth0 up

          # Try pinging with IPv6 network priority
          if ping -c 1 google.com; then
            green "Ping successful with IPv6 network priority"
          else
            red "Still unable to ping Google after trying both network priorities. There may be other issues with the network."
          fi
        fi
      fi
    fi
  fi
}

head
main
