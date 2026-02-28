#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2026.02.28

red() { echo -e "\033[31m\033[01m$1$2\033[0m"; }
green() { echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow() { echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading() { read -rp "$(green "$1")" "$2"; }
YELLOW="\033[33m\033[01m"
GREEN="\033[32m\033[01m"
RED="\033[31m\033[01m"
PLAIN="\033[0m"
REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "fedora" "arch")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Fedora" "Arch")
PACKAGE_UPDATE=("! apt-get update && apt-get --fix-broken install -y && apt-get update" "apt-get update" "yum -y update" "yum -y update" "yum -y update" "pacman -Sy")
PACKAGE_INSTALL=("apt-get -y install" "apt-get -y install" "yum -y install" "yum -y install" "yum -y install" "pacman -Sy --noconfirm --needed")
PACKAGE_REMOVE=("apt-get -y remove" "apt-get -y remove" "yum -y remove" "yum -y remove" "yum -y remove" "pacman -Rsc --noconfirm")
PACKAGE_UNINSTALL=("apt-get -y autoremove" "apt-get -y autoremove" "yum -y autoremove" "yum -y autoremove" "yum -y autoremove" "")
CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')" "$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)")
SYS="${CMD[0]}"
[[ -n $SYS ]] || exit 1
for ((int = 0; int < ${#REGEX[@]}; int++)); do
  if [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]]; then
    SYSTEM="${RELEASE[int]}"
    [[ -n $SYSTEM ]] && break
  fi
done
utf8_locale=$(locale -a 2>/dev/null | grep -i -m 1 -E "UTF-8|utf8")
if [[ -z "$utf8_locale" ]]; then
  yellow "No UTF-8 locale found"
else
  export LC_ALL="$utf8_locale"
  export LANG="$utf8_locale"
  export LANGUAGE="$utf8_locale"
  green "Locale set to $utf8_locale"
fi
apt-get --fix-broken install -y >/dev/null 2>&1
rm -rf test_result.txt >/dev/null 2>&1

head() {
  ver="2026.02.28"
  changeLog="一键修复本机系统时间"
  clear
  echo -e "#######################################################################"
  echo -e "#                     ${YELLOW}一键修复本机系统时间脚本${PLAIN}                        #"
  echo -e "# 版本：$ver                                                    #"
  echo -e "# 更新日志：$changeLog                                      #"
  echo -e "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
  echo -e "# ${GREEN}作仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script #"
  echo -e "#######################################################################"
  echo "支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+"
  echo "由于系统时间不准确都是未进行时区时间同步造成的，使用chronyd进行时区时间同步后应当解决了问题"
  # Display prompt asking whether to proceed with checking and changing
  reading "Do you want to proceed with checking and changing? [y/n] " confirm
  echo ""

  # Check user's input and exit if they do not want to proceed
  if [ "$confirm" != "y" ]; then
    exit 0
  fi
}

check_time_zone() {
  yellow "adjusting the time"
  if ! command -v chronyd >/dev/null 2>&1; then
    ${PACKAGE_INSTALL[int]} chrony >/dev/null 2>&1
  fi
  systemctl stop chronyd
  chronyd -q
  systemctl start chronyd
  sleep 0.5
}

head
check_time_zone
sleep 1
