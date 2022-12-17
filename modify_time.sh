#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2022.12.17

# 检测本机时间是否准确，如果不准确则修复的脚本

head() {
  # 支持系统：Ubuntu 12+，Debian 6+
  ver="2022.12.17"
  changeLog="一键修复本机系统时间"
  clear
  echo "#######################################################################"
  echo "#                     ${YELLOW}一键修复本机系统时间脚本${PLAIN}                               #"
  echo "# 版本：$ver                                                    #"
  echo "# 更新日志：$changeLog                               #"
  echo "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
  echo "# ${GREEN}作仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script #"
  echo "#######################################################################"
  echo "支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+"
  echo "检测修复本机系统时间，如果相差超过300秒的合理范围则校准时间"
  # Display prompt asking whether to proceed with checking and changing
  read -p "Do you want to proceed with checking and changing? [y/n] " -n 1 confirm
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
    # 获取当前时间和网络时间
    CURRENT_TIME=$(date +%s)
    NETWORK_TIME=$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)
    NETWORK_TIME_SECONDS=$(date -d "$NETWORK_TIME" +%s)

    # 计算时间差
    DIFF=$(($NETWORK_TIME_SECONDS-$CURRENT_TIME))

    # 判断时间差是否在允许范围内
    if [ "$DIFF" -lt 300 ] && [ "$DIFF" -gt -300 ]; then
        # 在允许范围内，时间准确
        echo "Time on $OS system is accurate."
    else
        # 不在允许范围内，时间不准确，调整时间
        echo "Time on $OS system is NOT accurate. Adjusting system time to accurate time."
        if [ "$OS" == "Ubuntu/Debian/Almalinux" ]; then
            # Ubuntu/Debian/Almalinux 系统使用 ntpdate 命令
            if [ ! -x "$(command -v ntpdate)" ]; then
                # ntpdate 命令不存在，安装 ntpdate
                sudo apt-get update
                sudo apt-get install ntpdate -y
            fi
            sudo ntpdate -u time.nist.gov || sudo ntpdate pool.ntp.org || sudo ntpdate cn.pool.ntp.org
        elif [ "$OS" == "CentOS/Fedora" ]; then
            # CentOS/Fedora 系统使用 ntpdate 命令
            if [ ! -x "$(command -v ntpdate)" ]; then
                # ntpdate 命令不存在，安装 ntpdate
                sudo yum update
                sudo yum install ntpdate -y
            fi
            sudo ntpdate time.nist.gov || sudo ntpdate pool.ntp.org || sudo ntpdate cn.pool.ntp.org
        else
            # 未知系统
            echo "Unable to adjust system time on unknown system."
        fi
    fi
}

check_again(){
    # 获取当前时间和网络时间
    CURRENT_TIME=$(date +%s)
    NETWORK_TIME=$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)
    NETWORK_TIME_SECONDS=$(date -d "$NETWORK_TIME" +%s)

    # 计算时间差
    DIFF=$(($NETWORK_TIME_SECONDS-$CURRENT_TIME))

    # 判断时间差是否在允许范围内
    if [ "$DIFF" -lt 300 ] && [ "$DIFF" -gt -300 ]; then
        # 在允许范围内，时间准确
        echo "Time on $OS system is accurate."
    else
        # 不在允许范围内，时间不准确
        echo "Time on $OS system is NOT accurate. Please check your system time and time zone settings."
    fi
}



head
check_os
main
check_again
