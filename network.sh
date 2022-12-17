#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2022.12.17


head() {
  # 支持系统：Ubuntu 12+，Debian 6+
  ver="2022.12.17"
  changeLog="一键修复linux网络脚本"
  clear
  echo "#######################################################################"
  echo "#                     ${YELLOW}一键修复linux网络脚本${PLAIN}                               #"
  echo "# 版本：$ver                                                    #"
  echo "# 更新日志：$changeLog                               #"
  echo "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
  echo "# ${GREEN}作仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script #"
  echo "#######################################################################"
  echo "支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+"
  echo "1.修复nameserver为google源或cloudflare源"
  echo "2.尝试修复为IP类型对应的网络优先级(默认IPV4类型，纯V6类型再替换为IPV6类型)"
  # Display prompt asking whether to proceed with checking and changing
  read -p "Do you want to proceed with checking and changing? [y/n] " -n 1 confirm
  echo ""

  # Check user's input and exit if they do not want to proceed
  if [ "$confirm" != "y" ]; then
    exit 0
  fi
}


main() {
  # Check if ping to google.com is successful
  if ping -c 1 google.com; then
    echo "Ping successful"
  else
    echo "Ping failed. Checking nameserver."

    # Check current nameserver
    nameserver=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
    echo "Current nameserver: $nameserver"

    # Try using Google's nameserver
    echo "Trying Google's nameserver: 8.8.8.8"
    sudo sed -i "s/$nameserver/8.8.8.8/g" /etc/resolv.conf
    if ping -c 1 google.com; then
      echo "Ping successful with Google's nameserver"
    else
      echo "Ping failed with Google's nameserver. Trying Cloudflare's nameserver."

      # Try using Cloudflare's nameserver
      echo "Trying Cloudflare's nameserver: 1.1.1.1"
      sudo sed -i "s/8.8.8.8/1.1.1.1/g" /etc/resolv.conf
      if ping -c 1 google.com; then
        echo "Ping successful with Cloudflare's nameserver"
      else
        echo "Ping failed with Cloudflare's nameserver. Checking network configuration."

        # Check IP type and network priority
        ip_type=$(curl -s ip.sb | grep -oP '(?<=is )(.+)(?=\.)')
        echo "IP type: $ip_type"
        if [ "$ip_type" = "IPv4" ]; then
          priority=$(cat /etc/gai.conf | grep -oP '(?<=precedence ::ffff:0:0\/96 )\d+')
        else
          priority=$(cat /etc/gai.conf | grep -oP '(?<=precedence ::/0 )\d+')
        fi
        echo "Network priority: $priority"

        # Modify network priority if necessary
        if [ "$ip_type" = "IPv4" ] && [ "$priority" -gt "100" ]; then
          sudo sed -i 's/precedence ::ffff:0:0\/96 100/precedence ::ffff:0:0\/96 50/' /etc/gai.conf
        elif [ "$ip_type" = "IPv6" ] && [ "$priority" -lt "100" ]; then
          sudo sed -i 's/precedence ::\/0 50/precedence ::\/0 100/' /etc/gai.conf
        else
          echo "Network configuration is correct."
        fi

        # Try to ping again after modifying network priority
        if ping -c 1 google.com; then
          echo "Ping successful after modifying network priority"
        else
          echo "Network problem is not related to nameserver or network priority."
        fi
      fi
    fi
  fi
}

head
main
