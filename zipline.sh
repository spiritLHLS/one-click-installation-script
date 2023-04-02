#!/usr/bin/env bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2023.04.02


cd /root >/dev/null 2>&1
ver="2023.04.02"
changeLog="一键安装Zipline平台"
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
clear
echo "#######################################################################"
echo "#                     ${YELLOW}一键安装Zipline平台${PLAIN}                               #"
echo "# 版本：$ver                                                    #"
echo "# 更新日志：$changeLog                                         #"
echo "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
echo "# ${GREEN}仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script   #"
echo "#######################################################################"

# 判断宿主机的 IPv4 或双栈情况 没有拉取不了 docker
check_ipv4(){
  # 遍历本机可以使用的 IP API 服务商
  # 定义可能的 IP API 服务商
  API_NET=("ip.sb" "ipget.net" "ip.ping0.cc" "https://ip4.seeip.org" "https://api.my-ip.io/ip" "https://ipv4.icanhazip.com" "api.ipify.org")

  # 遍历每个 API 服务商，并检查它是否可用
  for p in "${API_NET[@]}"; do
    # 使用 curl 请求每个 API 服务商
    response=$(curl -s4m8 "$p")
    sleep 1
    # 检查请求是否失败，或者回传内容中是否包含 error
    if [ $? -eq 0 ] && ! echo "$response" | grep -q "error"; then
      # 如果请求成功且不包含 error，则设置 IP_API 并退出循环
      IP_API="$p"
      break
    fi
  done

  # 判断宿主机的 IPv4 、IPv6 和双栈情况
  ! curl -s4m8 $IP_API | grep -q '\.' && red " ERROR：The host must have IPv4. " && exit 1
}

build(){
  green "\n Install docker.\n "
  if ! systemctl is-active docker >/dev/null 2>&1; then
    echo -e " \n Install docker \n " 
    if [ $SYSTEM = "CentOS" ]; then
      ${PACKAGE_INSTALL[int]} yum-utils
      yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &&
      ${PACKAGE_INSTALL[int]} docker-ce docker-ce-cli containerd.io
      systemctl enable --now docker
    else
      ${PACKAGE_INSTALL[int]} docker.io
    fi
  fi
  
  if ! command -v docker-compose >/dev/null 2>&1; then
    green "\n Install Docker Compose \n"
    if [ $SYSTEM = "CentOS" ]; then
      ${PACKAGE_INSTALL[int]} docker-compose
    else
      ${PACKAGE_INSTALL[int]} docker-compose
    fi

    if ! command -v docker-compose >/dev/null 2>&1; then
      echo -e "\nPackage manager installation failed, trying binary installation...\n"
      COMPOSE_URL=""
      case $SYSTEM_ARCH in
        "x86_64") COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64" ;;
        "aarch64") COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-arm64" ;;
        "armv6l") COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-armhf" ;;
        "armv7l") COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-armhf" ;;
        *) echo -e "\nArchitecture not supported for binary installation of Docker Compose.\n"; exit 1 ;;
      esac

      curl -SL $COMPOSE_URL -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose
    fi
  fi

  green "\n Building \n "
  if ! docker ps --format '{{.Names}}' | grep -q -E 'postgres|zipline'; then
    git clone https://github.com/diced/zipline
    cd zipline
    docker compose up -d
    CORE_SECRET=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)
    sed -i "s/CORE_SECRET=changethis/CORE_SECRET=$CORE_SECRET/g" docker-compose.yml
    docker compose pull
    docker compose up -d
  else
    cd zipline
    docker compose pull
    docker compose up -d
  fi
  
  green "Checking http://yourip:80/ "
}

check_ipv4
build
