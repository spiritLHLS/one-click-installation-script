#!/usr/bin/env bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2022.12.17

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

# 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
ver="2022.12.18"
changeLog="一键安装rust，加载官方脚本"
clear
echo -e "#######################################################################"
echo -e "#                     ${YELLOW}一键安装rust脚本${PLAIN}                                #"
echo -e "# 版本：$ver                                                    #"
echo -e "# 更新日志：$changeLog                                #"
echo -e "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
echo -e "# ${GREEN}仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script   #"
echo -e "#######################################################################"
echo "支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+"
# Display prompt asking whether to proceed with installation
reading "Do you want to proceed with the Rust installation? [y/n] " confirm
echo ""

# Check user's input and exit if they do not want to proceed
if [ "$confirm" != "y" ]; then
  exit 0
fi

# Update package manager's package list
if [ -x "$(command -v apt-get)" ]; then
  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt-get install curl build-essential gcc make -y
elif [ -x "$(command -v yum)" ]; then
  sudo yum update -y
  sudo yum install curl make gcc-c++ -y
elif [ -x "$(command -v dnf)" ]; then
  sudo dnf update -y
  sudo dnf install curl make gcc-c++ -y
elif [ -x "$(command -v pacman)" ]; then
  sudo pacman -Syu
  sudo pacman -S curl make gcc -y
else
  echo "Error: This script requires a package manager (apt, yum, dnf, pacman) to be installed on the system."
  exit 1
fi

# Install Rust
echo "Loading official installation script and selecting option 1 for installation"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Source Rust environment variables
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi
if [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile"
fi

# Update Rust
echo "Updating Rust"
rustup update

# Print version information for cargo, rustc, and rustdoc
echo "Printing version information for cargo, rustc, and rustdoc. If any of these tools are not found or have incorrect versions, the installation may have failed."
cargo --version
rustc --version
rustdoc --version
