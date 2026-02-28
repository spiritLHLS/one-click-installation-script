#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2023.02.25

utf8_locale=$(locale -a 2>/dev/null | grep -i -m 1 -E "UTF-8|utf8")
if [[ -z "$utf8_locale" ]]; then
  echo "No UTF-8 locale found"
else
  export LC_ALL="$utf8_locale"
  export LANG="$utf8_locale"
  export LANGUAGE="$utf8_locale"
  echo "Locale set to $utf8_locale"
fi

# 打印信息
_red() { echo -e "\033[31m\033[01m$@\033[0m"; }
_green() { echo -e "\033[32m\033[01m$@\033[0m"; }
_yellow() { echo -e "\033[33m\033[01m$@\033[0m"; }
_blue() { echo -e "\033[36m\033[01m$@\033[0m"; }

# 检查是否为 root 用户
if [ "$(id -u)" != "0" ]; then
  _red "请使用 root 用户执行脚本"
  exit 1
fi

# 判断是否为 Debian 系统
if [ ! -f /etc/debian_version ]; then
  _red "当前系统不是 Debian 系统"
  exit 1
fi

# 从文件中读取当前版本代号
CURRENT_VERSION=$(lsb_release -cs)

# 判断当前版本是否为最新版本
version=$(cat /etc/debian_version)
if [ $CURRENT_VERSION == "bullseye" ] || [ $CURRENT_VERSION == "bookworm" ]; then
  _blue "当前系统版本为最新版本，Debian version: $version , 代号 $CURRENT_VERSION"
  exit 0
else
  _blue "当前 Debian version: $version , 代号 $CURRENT_VERSION ，开始升级"
fi

# 检查脚本是否已经在执行
if [ -f /tmp/debian_upgrade_in_progress ]; then
  _yellow "升级正在进行中，请勿重复执行，如若已停止执行请重启服务器并删除文件 /tmp/debian_upgrade_in_progress "
  exit 1
fi

# 标记脚本已经在执行
touch /tmp/debian_upgrade_in_progress

# 设置升级前备份的文件夹路径
BACKUP_DIR="/root/debian_upgrade_backup"

# 创建备份文件夹
mkdir -p $BACKUP_DIR

# 更新软件包列表
apt update

# 升级已安装的软件包
apt upgrade -y

# 升级系统到最新版本
if [ $CURRENT_VERSION == "squeeze" ]; then
  sed -i 's/squeeze/wheezy/g' /etc/apt/sources.list
elif [ $CURRENT_VERSION == "wheezy" ]; then
  sed -i 's/wheezy/jessie/g' /etc/apt/sources.list
elif [ $CURRENT_VERSION == "jessie" ]; then
  sed -i 's/jessie/stretch/g' /etc/apt/sources.list
elif [ $CURRENT_VERSION == "stretch" ]; then
  sed -i 's/stretch/buster/g' /etc/apt/sources.list
elif [ $CURRENT_VERSION == "buster" ]; then
  sed -i 's/buster/bullseye/g' /etc/apt/sources.list
fi

replace() {
  sed -i 's/^deb http:\/\/security.debian.org\/debian-security wheezy\/updates main/# &/' /etc/apt/sources.list
  sed -i 's/^deb-src http:\/\/security.debian.org\/debian-security wheezy\/updates main/# &/' /etc/apt/sources.list
  sed -i 's/^deb http:\/\/security.debian.org\/debian-security jessie\/updates main/# &/' /etc/apt/sources.list
  sed -i 's/^deb-src http:\/\/security.debian.org\/debian-security jessie\/updates main/# &/' /etc/apt/sources.list
  sed -i 's/^deb http:\/\/security.debian.org\/debian-security stretch\/updates main/# &/' /etc/apt/sources.list
  sed -i 's/^deb-src http:\/\/security.debian.org\/debian-security stretch\/updates main/# &/' /etc/apt/sources.list
  sed -i 's/^deb http:\/\/security.debian.org\/debian-security buster\/updates main/# &/' /etc/apt/sources.list
  sed -i 's/^deb-src http:\/\/security.debian.org\/debian-security buster\/updates main/# &/' /etc/apt/sources.list
  sed -i 's/^deb http:\/\/security.debian.org\/debian-security bullseye\/updates main/# &/' /etc/apt/sources.list
  sed -i 's/^deb-src http:\/\/security.debian.org\/debian-security bullseye\/updates main/# &/' /etc/apt/sources.list
}

apt-get update
if [ $? -ne 0 ]; then
  # 去除漏洞修补源避免更新异常
  replace >/dev/null 2>&1
  apt-get update
fi
apt-get upgrade -y
apt-get full-upgrade -y

# 清理系统
apt-get autoremove -y
apt-get autoclean

# 备份系统配置文件
cp -r /etc $BACKUP_DIR

# 删除标记文件
rm /tmp/debian_upgrade_in_progress

_green "脚本执行完毕系统内核应当已升级到最新版本，执行 reboot 重启系统以完成内核升级"
