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
  # 支持系统：Ubuntu 12+，Debian 6+
  ver="2026.02.28"
  changeLog="修复sudo: unable to resolve host警告"
  clear
  echo -e "#######################################################################"
  echo -e "#           ${YELLOW}修复sudo: unable to resolve host xxx: Name or service not known警告${PLAIN}                        #"
  echo -e "# 版本：$ver                                                    #"
  echo -e "# 更新日志：$changeLog                                      #"
  echo -e "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
  echo -e "# ${GREEN}仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script   #"
  echo -e "#######################################################################"
  echo "支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+"
  echo "检测修复sudo: unable to resolve host xxx: Name or service not known爆错"
  # Display prompt asking whether to proceed with fixing
  reading "Do you want to proceed with fixing? [y/n] " confirm
  echo ""

  # Check user's input and exit if they do not want to proceed
  if [ "$confirm" != "y" ]; then
    exit 0
  fi
}

# Check if the hostname is set correctly in /etc/hosts
head
HOSTNAME=$(cat /etc/hostname)
HOSTS_LINE="$(grep -F "$HOSTNAME" /etc/hosts)"

if [ -z "$HOSTS_LINE" ]; then
  # Hostname not found in /etc/hosts. Add it.
  yellow "Updating /etc/hosts with hostname: $HOSTNAME"
  echo "127.0.0.1 $HOSTNAME" | sudo tee -a /etc/hosts
else
  # Hostname found in /etc/hosts. Check if the IP address is correct.
  HOSTS_IP="$(awk '{print $1}' <<<$HOSTS_LINE)"
  if [ "$HOSTS_IP" != "127.0.0.1" ]; then
    # IP address is incorrect. Update it.
    yellow "Updating IP address for $HOSTNAME in /etc/hosts"
    temp_file=$(mktemp)
    backup_file="/etc/hosts-$(date +%Y%m%d%H%M%S).bak"
    cp /etc/hosts "$backup_file"
    yellow "Backed up /etc/hosts to $backup_file"
    awk -v new_ip="127.0.0.1" -v hostname="$HOSTNAME" '{ if ($2 == hostname) { print new_ip " " $2 } else { print $0 } }' /etc/hosts >"$temp_file"
    cp "$temp_file" /etc/hosts
    rm "$temp_file"
  else
    # Hostname and IP address are correct. No changes needed.
    green "Hostname and IP address in /etc/hosts are correct."
  fi
fi

# Check if the sudo command works (use sudo -v to validate, not a shell function)
yellow "Testing sudo command..."
sudo -v >/dev/null 2>&1
if [ $? -eq 0 ]; then
  # Sudo command works. Exit the script.
  green "Fix successful. Exiting script."
else
  # Sudo command failed. Try restarting the networking interface.
  yellow "Sudo command still failing. Restarting networking interface."
  sudo service networking restart

  # Check if the sudo command works after restarting the networking interface
  yellow "Testing sudo command after restarting networking interface..."
  sudo -v >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    # Sudo command works. Exit the script.
    green "Fix successful. Exiting script."
  else
    # Sudo command failed. Try restarting the DNS server.
    yellow "Sudo command still failing. Restarting DNS server."
    sudo service bind9 restart

    # Check if the sudo command works after restarting the DNS server
    yellow "Testing sudo command after restarting DNS server..."
    sudo -v >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      # Sudo command works. Exit the script.
      green "Fix successful. Exiting script."
    else
      # Sudo command still failing. Exiting script.
      red "Unable to fix problem. Exiting script."
    fi
  fi
fi
