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
  changeLog="修复sudo: unable to resolve host警告"
  clear
  echo "#######################################################################"
  echo "#           ${YELLOW}修复sudo: unable to resolve host xxx: Name or service not known警告${PLAIN}                        #"
  echo "# 版本：$ver                                                    #"
  echo "# 更新日志：$changeLog                                      #"
  echo "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
  echo "# ${GREEN}作仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script #"
  echo "#######################################################################"
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
HOSTNAME=$(cat /etc/hostname)
HOSTS_LINE="$(grep $HOSTNAME /etc/hosts)"

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
    awk -v new_ip="127.0.0.1" -v hostname="$HOSTNAME" '{ if ($2 == hostname) { print new_ip " " $2 } else { print $0 } }' /etc/hosts > "$temp_file"
    cp "$temp_file" /etc/hosts
    rm "$temp_file"
  else
    # Hostname and IP address are correct. No changes needed.
    green "Hostname and IP address in /etc/hosts are correct."
  fi
fi


# Check if the sudo command works
sudo yellow "Testing sudo command..."
if [ $? -eq 0 ]; then
  # Sudo command works. Exit the script.
  green "Fix successful. Exiting script."
else
  # Sudo command failed. Try restarting the networking interface.
  yellow "Sudo command still failing. Restarting networking interface."
  sudo service networking restart

  # Check if the sudo command works after restarting the networking interface
  sudo echo "Testing sudo command after restarting networking interface..."
  if [ $? -eq 0 ]; then
    # Sudo command works. Exit the script.
    green "Fix successful. Exiting script."
  else
    # Sudo command failed. Try restarting the DNS server.
    yellow "Sudo command still failing. Restarting DNS server."
    sudo service bind9 restart

    # Check if the sudo command works after restarting the DNS server
    sudo echo "Testing sudo command after restarting DNS server..."
    if [ $? -eq 0 ]; then
      # Sudo command works. Exit the script.
      green "Fix successful. Exiting script."
    else
      # Sudo command still failing. Exiting script.
      red "Unable to fix problem. Exiting script."
    fi
  fi
fi
