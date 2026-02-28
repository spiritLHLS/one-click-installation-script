#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2026.02.28

utf8_locale=$(locale -a 2>/dev/null | grep -i -m 1 -E "UTF-8|utf8")
if [[ -z "$utf8_locale" ]]; then
  echo "No UTF-8 locale found"
else
  export LC_ALL="$utf8_locale"
  export LANG="$utf8_locale"
  export LANGUAGE="$utf8_locale"
  echo "Locale set to $utf8_locale"
fi

red() { echo -e "\033[31m\033[01m$1$2\033[0m"; }
green() { echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow() { echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading() { read -rp "$(green "$1")" "$2"; }
YELLOW="\033[33m\033[01m"
GREEN="\033[32m\033[01m"
RED="\033[31m\033[01m"
PLAIN="\033[0m"

head() {
  # 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
  ver="2026.02.28"
  changeLog="一键修复linux网络脚本"
  clear
  echo -e "#######################################################################"
  echo -e "#                     ${YELLOW}一键修复linux网络脚本${PLAIN}                           #"
  echo -e "# 版本：$ver                                                    #"
  echo -e "# 更新日志：$changeLog                                     #"
  echo -e "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
  echo -e "# ${GREEN}仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script   #"
  echo -e "#######################################################################"
  echo "支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+"
  echo "1.检测ping谷歌和GitHub如果有问题修改nameserver为google源或cloudflare源"
  echo "2.检测ping谷歌和Github还有问题尝试修复为IP类型对应的网络优先级(默认IPV4类型，纯V6类型再替换为IPV6类型)"
  # Display prompt asking whether to proceed with checking and changing
  reading "Do you want to proceed with checking and changing nameserver? [y/n] " confirm
  echo ""

  # Check user's input and exit if they do not want to proceed
  if [ "$confirm" != "y" ]; then
    exit 0
  fi
}

main() {
  external_ip=$(host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}')
  # 判断 IP 类型并执行对应的函数
  if [[ $external_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    main_v4
  elif [[ $external_ip =~ ^[0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4}$ ]]; then
    main_v6
  else
    echo "无法识别外网 IP 地址类型"
  fi
}

main_v4() {
  # Check if /etc/resolv.conf and /etc/gai.conf exist before backing them up
  if [ -f /etc/resolv.conf ]; then
    cp /etc/resolv.conf /etc/resolv.conf.bak
  fi
  if [ -f /etc/gai.conf ]; then
    cp /etc/gai.conf /etc/gai.conf.bak
  fi

  # Check if ping to google.com is successful
  if ping -c 1 google.com; then
    return
  fi

  # Try using Google's nameserver
  echo "nameserver 8.8.8.8" >/etc/resolv.conf
  if ping -c 1 google.com; then
    return
  fi

  # Try using Cloudflare's nameserver
  echo "nameserver 1.1.1.1" >/etc/resolv.conf
  if ping -c 1 google.com; then
    return
  fi

  # Display prompt asking whether to proceed with checking and changing priority
  reading "Do you want to proceed with checking and changing network priority? [y/n] " priority
  echo ""

  # Check user's input and exit if they do not want to proceed
  if [ "$priority" != "y" ]; then
    exit 0
  fi

  # Check IP type and network priority
  ip_type=$(curl -s ip.sb | grep -oP '(?<=is )(.+)(?=\.)')
  if [ -z "$ip_type" ]; then
    echo "Error: curl request failed"
    exit 1
  fi

  if [ "$ip_type" = "IPv4" ]; then
    priority=$(grep precedence /etc/gai.conf 2>/dev/null | grep -oP '(?<=precedence ::ffff:0:0\/96 )\d+' | head -1)
    if [[ -z "$priority" ]]; then
      # 条目不存在，直接写入 IPv4 优先配置
      echo "precedence ::ffff:0:0/96 100" >>/etc/gai.conf
      priority=100
    fi
  else
    priority=$(grep precedence /etc/gai.conf 2>/dev/null | grep -oP '(?<=precedence ::\/0 )\d+' | head -1)
    if [[ -z "$priority" ]]; then
      # 条目不存在，直接写入 IPv6 优先配置
      echo "precedence ::/0 50" >>/etc/gai.conf
      priority=50
    fi
  fi

  # Modify network priority if necessary
  if [ "$ip_type" = "IPv4" ] && [ "$priority" -gt "100" ]; then
    echo "precedence ::ffff:0:0/96 50" >/etc/gai.conf
  elif [ "$ip_type" = "IPv6" ] && [ "$priority" -lt "100" ]; then
    echo "precedence ::/0 100" >/etc/gai.conf
  fi

  # Check if ping to google.com is successful after modifying network priority
  if ping -c 1 google.com; then
    green "Ping successful after modifying network priority"
    return
  else
    # Restore original configuration if ping fails after modifying network priority
    mv /etc/resolv.conf.bak /etc/resolv.conf
    mv /etc/gai.conf.bak /etc/gai.conf
    echo "Error: Network problem is not related to nameserver or network priority. Original configuration restored."
    exit 1
  fi
}

main_v6() {
  # 定义 nameserver 列表
  nameservers=(
    "2001:67c:2960:5353:5353:5353:5353:5353"
    "2001:67c:2960:6464:6464:6464:6464:6464"
    "2602:fc23:18::7"
    "2001:67c:27e4::60"
    "2001:67c:27e4:15::64"
    "2001:67c:27e4::64"
    "2001:67c:27e4:15::6411"
    "2a01:4f9:c010:3f02::1"
    "2a00:1098:2c::1"
    "2a00:1098:2b::1"
    "2a01:4f8:c2c:123f::1"
    "2001:67c:2960::64"
    "2001:67c:2960::6464"
    "2001:67c:2960::64"
    "2001:67c:2960::6464"
    "2001:67c:2b0::6"
    "2001:67c:2b0::4"
    "2a03:7900:2:0:31:3:104:161"
  )

  # 保存当前 nameserver 的值，以便之后恢复
  current_nameserver=$(cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}')

  # 循环尝试替换 nameserver 并测试网络
  for nameserver in "${nameservers[@]}"; do
    # 替换 nameserver
    echo "nameserver $nameserver" >/etc/resolv.conf

    # 让修改生效
    if command -v resolvconf >/dev/null 2>&1; then
      resolvconf -u
    elif command -v systemd-resolve >/dev/null 2>&1; then
      systemd-resolve --flush-caches 2>/dev/null
    fi

    # ping 测试
    if ping -c 3 google.com &>/dev/null && ping -c 3 github.com &>/dev/null; then
      green "网络恢复成功"
      return
    fi
  done

  # 如果所有 nameserver 都尝试过了仍然无法修复，则恢复为原来的 nameserver
  echo "nameserver $current_nameserver" >/etc/resolv.conf
  if command -v resolvconf >/dev/null 2>&1; then
    resolvconf -u
  elif command -v systemd-resolve >/dev/null 2>&1; then
    systemd-resolve --flush-caches 2>/dev/null
  fi
}

head
main
# ping 测试
if ping -c 3 google.com &>/dev/null && ping -c 3 github.com &>/dev/null; then
  green "V4网络恢复成功"
fi
