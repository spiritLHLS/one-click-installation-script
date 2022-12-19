#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2022.12.19

red(){ echo -e "\033[31m\033[01m$1$2\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }

head() {
  ver="2022.12.19"
  changeLog="一键安装vnstat脚本"
  clear
  echo "#######################################################################"
  echo "#                     ${YELLOW}一键安装vnstat脚本${PLAIN}                        #"
  echo "# 版本：$ver                                                    #"
  echo "# 更新日志：$changeLog                                      #"
  echo "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
  echo "# ${GREEN}作仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script #"
  echo "#######################################################################"
  echo "支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+"
  echo "加载官方文件编译安装，前置条件适配系统以及后置条件判断安装的版本"
  # Display prompt asking whether to proceed with installation
  reading "Do you want to proceed with installation? [y/n] " confirm
  echo ""

  # Check user's input and exit if they do not want to proceed
  if [ "$confirm" != "y" ]; then
    exit 0
  fi
}


check_os() {
    # 检测系统类型
    if [ -f /etc/lsb-release ]; then
        # Ubuntu/Debian/Almalinux
        OS="Ubuntu/Debian/Almalinux"
    elif [ -f /etc/redhat-release ]; then
        # CentOS/Fedora
        OS="CentOS/Fedora"
    else
        # 未知系统
        OS="Unknown"
    fi
}

main(){
  if [ "$OS" == "Ubuntu/Debian/Almalinux" ]; then
    # Update package repositories and install dependencies
    apt-get update
    apt-get install -y wget sudo curl build-essential libsqlite3-dev

    # Download and extract vnstat source code
    wget https://github.com/vergoh/vnstat/releases/download/v2.10/vnstat-2.10.tar.gz
    tar -xvf vnstat-2.10.tar.gz
    cd vnstat-2.10/

    # Compile and install vnstat
    ./configure --prefix=/usr --sysconfdir=/etc
    make
    make install

    # Enable and start the vnstat service
    systemctl enable vnstat
    systemctl start vnstat
    
    apt-get install chkconfig -y
    if [ $? -ne 0 ]; then
        apt-get install sysv-rc-conf -y
        if [ $? -ne 0 ]; then
            apt-get update && apt-get install sysv-rc-conf -y
        fi
    fi
    ! chkconfig vnstat on && echo "replace chkconfig with sysv-rc-conf" && sysv-rc-conf vnstat on 
    service vnstat start

    # Check if vnstat is installed and working properly
    vnstat -v
    vnstatd -v

    # Check if vnstati is installed and working properly
    if which vnstati >/dev/null; then
        vnstati -v
    else
        echo "vnstat was compiled and installed without the vnstati tool. If you need to use it, please run 'apt-get install vnstati -y' to install the version from the package repository."
    fi
  elif [ "$OS" == "CentOS/Fedora" ]; then
    yum update -y
    yum install -y wget sudo curl make gcc sqlite-devel

    # Download and extract vnstat source code
    wget https://github.com/vergoh/vnstat/releases/download/v2.10/vnstat-2.10.tar.gz
    tar -xvf vnstat-2.10.tar.gz
    cd vnstat-2.10/

    # Compile and install vnstat
    ./configure --prefix=/usr --sysconfdir=/etc
    make
    make install

    # Enable and start the vnstat service
    systemctl enable vnstat
    systemctl start vnstat

    # Check if vnstat is installed and working properly
    vnstat -v
    vnstatd -v

    # Check if vnstati is installed and working properly
    if which vnstati >/dev/null; then
        vnstati -v
    else
        echo "vnstat was compiled and installed without the vnstati tool. If you need to use it, please run 'yum install vnstati -y' or 'dnf install vnstati -y' to install the version from the package repository."
    fi
  fi
}

head
check_os
main
