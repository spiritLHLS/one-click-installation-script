#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2023.02.25

# 判断是否为 Debian 系统
if [ ! -f /etc/debian_version ]; then
  echo "当前系统不是 Debian 系统"
  exit 1
fi

# 从文件中读取当前版本代号
CURRENT_VERSION=$(cat /etc/os-release | grep VERSION= | cut -d '"' -f2 | cut -d ' ' -f1)

# 判断当前版本是否为最新版本
if [ $CURRENT_VERSION == "bullseye" ]; then
  echo "当前系统版本为最新版本"
  exit 0
fi

# 检查脚本是否已经在执行
if [ -f /tmp/debian_upgrade_in_progress ]; then
  echo "升级正在进行中，请勿重复执行"
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

apt-get update
apt-get upgrade -y
apt-get full-upgrade -y

# 清理系统
apt-get autoremove -y
apt-get autoclean

# 备份系统配置文件
cp -r /etc $BACKUP_DIR

# 删除标记文件
rm /tmp/debian_upgrade_in_progress

echo "脚本执行完毕系统内核应当已升级到最新版本，执行 reboot 重启系统以完成内核升级"
