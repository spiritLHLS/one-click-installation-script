#!/usr/bin/env bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2023.04.18

utf8_locale=$(locale -a 2>/dev/null | grep -i -m 1 -E "UTF-8|utf8")
if [[ -z "$utf8_locale" ]]; then
  echo "No UTF-8 locale found"
else
  export LC_ALL="$utf8_locale"
  export LANG="$utf8_locale"
  export LANGUAGE="$utf8_locale"
  echo "Locale set to $utf8_locale"
fi
cd /root >/dev/null 2>&1
ver="2023.04.18"
changeLog="一键安装filebrowser平台"
source ~/.bashrc
red(){ echo -e "\033[31m\033[01m$1$2\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1$2\033[0m"; }
blue() { echo -e "\033[36m\033[01m$@\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }
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
apt-get --fix-broken install -y > /dev/null 2>&1

check_ipv4(){
  API_NET=("ip.sb" "ipget.net" "ip.ping0.cc" "https://ip4.seeip.org" "https://api.my-ip.io/ip" "https://ipv4.icanhazip.com" "api.ipify.org")
  for p in "${API_NET[@]}"; do
    response=$(curl -s4m8 "$p")
    sleep 1
    if [ $? -eq 0 ] && ! echo "$response" | grep -q "error"; then
      IP_API="$p"
      break
    fi
  done
  ! curl -s4m8 $IP_API | grep -q '\.' && red " ERROR：The host must have IPv4. " && exit 1
  IPV4=$(curl -s4m8 "$IP_API")
}

checkwget() {
	if  [ ! -e '/usr/bin/wget' ]; then
            yellow "Installing wget"
	        ${PACKAGE_INSTALL[int]} wget
	fi
}

checktar() {
    yellow "checking tar"
	if  [ ! -e '/usr/bin/tar' ]; then
            yellow "Installing tar"
	        ${PACKAGE_INSTALL[int]} tar 
	fi
    if [ $? -ne 0 ]; then
        apt-get -f install > /dev/null 2>&1
        ${PACKAGE_INSTALL[int]} tar > /dev/null 2>&1
    fi
}

build(){
  cd /root >/dev/null 2>&1
  local sysarch="$(uname -m)"
  case "${sysarch}" in
      "x86_64"|"x86"|"amd64"|"x64") sys_bit="amd64";;
      "i386"|"i686") sys_bit="386";;
      "aarch64"|"armv8"|"armv8l") sys_bit="arm64";;
      "armv5l") sys_bit="armv5";;
      "armv6l") sys_bit="armv6";;
      "armv7l") sys_bit="armv7";;
      *) sys_bit="amd64";;
  esac
  wget https://github.com/filebrowser/filebrowser/releases/download/v2.23.0/linux-${sys_bit}-filebrowser.tar.gz
  tar -xzvf linux-${sys_bit}-filebrowser.tar.gz
  rm -rf linux-${sys_bit}-filebrowser.tar.gz*
}

run(){
  nohup ./filebrowser -a $IPV4 -p 3030 >/dev/null 2>&1 &
}

check_ipv4
checkwget
checktar
build
run
green "Checking http://$IPV4:3030/ "
green "You may login to the dashboard with:"
green "Username: admin" 
green "Password: admin"
green "Remember to change this password in the manage user page"
rm -rf CHANGELOG.md LICENSE README.md
