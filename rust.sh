#!/usr/bin/env bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2022.12.17


# 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
ver="2022.12.17"
changeLog="一键安装rust，加载官方脚本"
clear
echo "#######################################################################"
echo "#                     ${YELLOW}一键安装rust脚本${PLAIN}                                #"
echo "# 版本：$ver                                                    #"
echo "# 更新日志：$changeLog                                #"
echo "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
echo "# ${GREEN}作仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script #"
echo "#######################################################################"
echo "支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+"
# Display prompt asking whether to proceed with installation
read -p "Do you want to proceed with the Rust installation? [y/n] " -n 1 confirm
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
