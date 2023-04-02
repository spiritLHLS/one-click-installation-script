#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2022.12.24

red(){ echo -e "\033[31m\033[01m$1$2\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }

head() {
  ver="2022.12.24"
  changeLog="一键修复本机系统时间"
  clear
  echo "#######################################################################"
  echo "#                     ${YELLOW}一键修复本机系统时间脚本${PLAIN}                        #"
  echo "# 版本：$ver                                                    #"
  echo "# 更新日志：$changeLog                                      #"
  echo "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
  echo "# ${GREEN}作仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script #"
  echo "#######################################################################"
  echo "支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+"
  echo "检测修复本机系统时间，对应时区时间，如果相差超过300秒的合理范围则校准时间"
  # Display prompt asking whether to proceed with checking and changing
  reading "Do you want to proceed with checking and changing? [y/n] " confirm
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
    # 获取当前时区信息
    TIMEZONE=$(date +%z)
    # 获取当前时间和网络时间
    CURRENT_TIME=$(date -u +%s)
    NETWORK_TIME=$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)
    NETWORK_TIME_SECONDS=$(TZ=":UTC" date -d "$NETWORK_TIME" +%s)

    # 计算时间差
    DIFF=$(($NETWORK_TIME_SECONDS-$CURRENT_TIME))

    # 根据时区信息增加或减少时间差的允许范围
    HOUR_OFFSET=${TIMEZONE:0:3}
    MINUTE_OFFSET=${TIMEZONE:3:2}
    HOUR_OFFSET_SECONDS=$((HOUR_OFFSET * 3600))
    MINUTE_OFFSET_SECONDS=$((MINUTE_OFFSET * 60))
    ALLOWED_DIFF=$((300 + HOUR_OFFSET_SECONDS + MINUTE_OFFSET_SECONDS))

    # 判断时间差是否在允许范围内
    if [ "$DIFF" -lt "$ALLOWED_DIFF" ] && [ "$DIFF" -gt "-$ALLOWED_DIFF" ]; then
        # 在允许范围内，时间准确
        green "Time on $OS system is accurate."
        echo "Current time: $(date)"
        exit 0
    else
        # 不在允许范围内，时间不准确，调整时间
        yellow "Time on $OS system is NOT accurate. Adjusting system time to accurate time."
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
            red "Unable to adjust system time on unknown system."
        fi
    fi
}


check_again(){
    # 获取当前时间和网络时间
    CURRENT_TIME=$(date -u +%s)
    NETWORK_TIME=$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)
    NETWORK_TIME_SECONDS=$(TZ=":UTC" date -d "$NETWORK_TIME" +%s)

    # 获取当前时区信息
    TIMEZONE=$(date +%z)
    # 获取网络时间对应的时区信息
    NETWORK_TZ=$(echo "$NETWORK_TIME" | awk '{print $5}')
    # 计算时区差，单位是秒
    TZ_DIFF=$((($(TZ=":$NETWORK_TZ" date -d "now" +%s)-$(TZ=":$TIMEZONE" date -d "now" +%s))/3600*3600))

    # 计算时间差
    DIFF=$(($NETWORK_TIME_SECONDS-$CURRENT_TIME-$TZ_DIFF))
    
    # 根据时区信息增加或减少时间差的允许范围
    HOUR_OFFSET=${TIMEZONE:0:3}
    MINUTE_OFFSET=${TIMEZONE:3:2}
    HOUR_OFFSET_SECONDS=$((HOUR_OFFSET * 3600))
    MINUTE_OFFSET_SECONDS=$((MINUTE_OFFSET * 60))
    ALLOWED_DIFF=$((300 + HOUR_OFFSET_SECONDS + MINUTE_OFFSET_SECONDS))

    # 判断时间差是否在允许范围内
    if [ "$DIFF" -lt "$ALLOWED_DIFF" ] && [ "$DIFF" -gt "-$ALLOWED_DIFF" ]; then
        # 在允许范围内，时间准确
        green "Time on $OS system is accurate."
        echo "Current time: $(date)"
    else
        # 不在允许范围内，时间不准确
        red "Time on $OS system is NOT accurate. Please check your system time and time zone settings again!"
    fi
}

head
check_os
main
sleep 1
check_again
