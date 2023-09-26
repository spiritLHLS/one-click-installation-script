#!/usr/bin/env bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2023.09.26

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
ver="2023.07.26"
changeLog="一键安装jupyter环境"
source ~/.bashrc
red() { echo -e "\033[31m\033[01m$1$2\033[0m"; }
green() { echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow() { echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading() { read -rp "$(green "$1")" "$2"; }
temp_file_apt_fix="apt_fix.txt"
REGEX=("debian|astra" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "fedora" "arch" "freebsd")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Fedora" "Arch" "FreeBSD")
PACKAGE_UPDATE=("! apt-get update && apt-get --fix-broken install -y && apt-get update" "apt-get update" "yum -y update" "yum -y update" "yum -y update" "pacman -Sy" "pkg update")
PACKAGE_INSTALL=("apt-get -y install" "apt-get -y install" "yum -y install" "yum -y install" "yum -y install" "pacman -Sy --noconfirm --needed" "pkg install -y")
PACKAGE_REMOVE=("apt-get -y remove" "apt-get -y remove" "yum -y remove" "yum -y remove" "yum -y remove" "pacman -Rsc --noconfirm" "pkg delete")
PACKAGE_UNINSTALL=("apt-get -y autoremove" "apt-get -y autoremove" "yum -y autoremove" "yum -y autoremove" "yum -y autoremove" "" "pkg autoremove")
CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')" "$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(uname -s)")
SYS="${CMD[0]}"
[[ -n $SYS ]] || exit 1
for ((int = 0; int < ${#REGEX[@]}; int++)); do
    if [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]]; then
        SYSTEM="${RELEASE[int]}"
        [[ -n $SYSTEM ]] && break
    fi
done

clear
echo "#######################################################################"
echo "#                     ${YELLOW}一键安装jupyter环境${PLAIN}                             #"
echo "# 版本：$ver                                                    #"
echo "# 更新日志：$changeLog                                       #"
echo "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
echo "# ${GREEN}仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script   #"
echo "#######################################################################"
echo "验证已支持的系统："
echo "Ubuntu 系 - 推荐，脚本自动挂起到后台"
echo "Debian 系 - 部分可能需要手动挂起到后台，详看脚本运行安装完毕的后续提示"
echo "可能支持的系统：centos 7+，Fedora，Almalinux 8.5+"
red "本脚本尝试使用Miniconda3安装虚拟环境jupyter-env再进行jupyter和jupyterlab的安装，如若安装机器不纯净勿要轻易使用本脚本！"
yellow "执行脚本，之前有用本脚本安装过则直接打印设置的登陆信息，没安装过则进行安装再打印信息，如果已安装但未启动则自动启动后再打印信息"
yellow "如果是初次安装无脑y无脑回车即可，按照提示进行操作即可，安装完毕将在后台常驻运行，自动添加常用的安装包通道源"

check_china() {
    yellow "IP area being detected ......"
    if [[ -z "${CN}" ]]; then
        if [[ $(curl -m 6 -s https://ipapi.co/json | grep 'China') != "" ]]; then
            yellow "根据ipapi.co提供的信息，当前IP可能在中国"
            read -e -r -p "是否选用中国镜像完成相关组件安装? ([y]/n) " input
            case $input in
            [yY][eE][sS] | [yY])
                echo "使用中国镜像"
                CN=true
                ;;
            [nN][oO] | [nN])
                echo "不使用中国镜像"
                ;;
            *)
                echo "使用中国镜像"
                CN=true
                ;;
            esac
        else
            if [[ $? -ne 0 ]]; then
                if [[ $(curl -m 6 -s cip.cc) =~ "中国" ]]; then
                    yellow "根据cip.cc提供的信息，当前IP可能在中国"
                    read -e -r -p "是否选用中国镜像完成相关组件安装? [Y/n] " input
                    case $input in
                    [yY][eE][sS] | [yY])
                        echo "使用中国镜像"
                        CN=true
                        ;;
                    [nN][oO] | [nN])
                        echo "不使用中国镜像"
                        ;;
                    *)
                        echo "不使用中国镜像"
                        ;;
                    esac
                fi
            fi
        fi
    fi
}

check_update() {
    yellow "Updating package management sources"
    if command -v apt-get >/dev/null 2>&1; then
        apt_update_output=$(apt-get update 2>&1)
        echo "$apt_update_output" >"$temp_file_apt_fix"
        if grep -q 'NO_PUBKEY' "$temp_file_apt_fix"; then
            public_keys=$(grep -oE 'NO_PUBKEY [0-9A-F]+' "$temp_file_apt_fix" | awk '{ print $2 }')
            joined_keys=$(echo "$public_keys" | paste -sd " ")
            yellow "No Public Keys: ${joined_keys}"
            apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ${joined_keys}
            apt-get update
            if [ $? -eq 0 ]; then
                green "Fixed"
            fi
        fi
        rm "$temp_file_apt_fix"
    else
        ${PACKAGE_UPDATE[int]}
    fi
    rm -rf $temp_file_apt_fix
}

check_sudo() {
    yellow "checking sudo"
    if ! command -v sudo >/dev/null 2>&1; then
        yellow "Installing sudo"
        ${PACKAGE_INSTALL[int]} sudo >/dev/null 2>&1
    fi
}

check_wget() {
    if ! which wget >/dev/null; then
        yellow "Installing wget"
        ${PACKAGE_INSTALL[int]} wget
    fi
}

check_curl() {
    if ! which curl >/dev/null; then
        yellow "Installing curl"
        ${PACKAGE_INSTALL[int]} curl
    fi
    if [ $? -ne 0 ]; then
        apt-get -f install >/dev/null 2>&1
        ${PACKAGE_INSTALL[int]} curl
    fi
}

check_ufw() {
    if ! which ufw >/dev/null; then
        yellow "Installing ufw"
        ${PACKAGE_INSTALL[int]} ufw
    fi
}

is_private_ipv4() {
    local ip_address=$1
    local ip_parts
    if [[ -z $ip_address ]]; then
        return 0 # 输入为空
    fi
    IFS='.' read -r -a ip_parts <<<"$ip_address"
    # 检查IP地址是否符合内网IP地址的范围
    # 去除 回环，REC 1918，多播 地址
    if [[ ${ip_parts[0]} -eq 10 ]] ||
        [[ ${ip_parts[0]} -eq 172 && ${ip_parts[1]} -ge 16 && ${ip_parts[1]} -le 31 ]] ||
        [[ ${ip_parts[0]} -eq 192 && ${ip_parts[1]} -eq 168 ]] ||
        [[ ${ip_parts[0]} -eq 127 ]] ||
        [[ ${ip_parts[0]} -eq 0 ]] ||
        [[ ${ip_parts[0]} -ge 224 ]]; then
        return 0 # 是内网IP地址
    else
        return 1 # 不是内网IP地址
    fi
}

check_ipv4() {
    IPV4=$(ip -4 addr show | grep global | awk '{print $2}' | cut -d '/' -f1 | head -n 1)
    if is_private_ipv4 "$IPV4"; then # 由于是内网IPV4地址，需要通过API获取外网地址
        IPV4=""
        local API_NET=("ipv4.ip.sb" "ipget.net" "ip.ping0.cc" "https://ip4.seeip.org" "https://api.my-ip.io/ip" "https://ipv4.icanhazip.com" "api.ipify.org")
        for p in "${API_NET[@]}"; do
            response=$(curl -s4m8 "$p")
            sleep 1
            if [ $? -eq 0 ] && ! echo "$response" | grep -q "error"; then
                IP_API="$p"
                IPV4="$response"
                break
            fi
        done
    fi
    export IPV4
}

install_jupyter() {
    rm -rf Miniconda3-latest-Linux-x86_64.sh*
    check_update
    check_sudo
    check_wget
    check_curl
    check_ufw
    if ! command -v conda &>/dev/null; then
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        bash Miniconda3-latest-Linux-x86_64.sh -b -u
        echo 'export PATH="$PATH:$HOME/miniconda3/bin:$HOME/miniconda3/condabin"' >>~/.bashrc
        echo 'export PATH="$PATH:$HOME/.local/share/jupyter"' >>~/.bashrc
        source ~/.bashrc
        sleep 1
        echo 'export PATH="/home/user/miniconda3/bin:$PATH"' >>~/.bashrc
        source ~/.bashrc
        sleep 1
        export PATH="/home/user/miniconda3/bin:$PATH"
        green "请关闭本窗口开一个新窗口再执行本脚本，否则无法加载一些预设的环境变量(或断开SSH连接后重新连接)" && exit 0
    fi
    green "加载预设的conda环境变量成功，准备安装jupyter，无脑输入y和回车即可"
    conda create -n jupyter-env python=3
    sleep 5
    source activate jupyter-env
    sleep 1
    conda install jupyter jupyterlab
    check_china
    if [[ -n "${CN}" && "${CN}" == true ]]; then
        conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
        conda config --set show_channel_urls yes
    fi
    echo 'export PATH="$PATH:~/.local/share/jupyter"' >>/etc/profile
    source /etc/profile
    # jupyter notebook --generate-config
    # cp ~/.jupyter/jupyter_notebook_config.py ~/.jupyter/jupyter_server_config.py
    jupyter server --generate-config
    # echo "c.ServerApp.password = 'spiritlhl'" >> ~/.jupyter/jupyter_server_config.py
    # echo "c.ServerApp.username = 'spiritlhl'" >> ~/.jupyter/jupyter_server_config.py
    if command -v ufw &>/dev/null; then
        sudo ufw allow 13692/tcp
    elif command -v firewall-cmd &>/dev/null; then
        sudo firewall-cmd --add-port=13692/tcp --permanent
        sudo firewall-cmd --reload
    fi
    ubuntu_version=$(lsb_release -rs)
    channels_to_add=(
        "dglteam"
        "pytorch"
        "conda-forge"
        "anaconda"
    )

    source activate jupyter-env
    sleep 1
    rm -rf nohup.out
    green "后台执行的pid的进程ID和输出日志文件名字如下"
    nohup jupyter lab --port 13692 --no-browser --ip=0.0.0.0 --allow-root &
    green $!
    sleep 5
    if grep -q 'token=' nohup.out >/dev/null 2>&1; then
        cat nohup.out
    else
        echo "你可能在不支持的系统是执行，运行的最后几行可能有如下提示"
        yellow "nohup: failed to run command 'jupyter': No such file or directory"
        echo "你需要手动执行下面的命令"
        yellow "source activate jupyter-env"
        yellow "nohup jupyter lab --port 13692 --no-browser --ip=0.0.0.0 --allow-root"
        green "等待5秒后关闭本窗口，开新窗口执行下面的命令查看登陆信息"
        yellow "cat nohup.out"
        echo "如若无成功输出，可尝试重新运行本脚本"
    fi
    current_channels=$(conda config --get channels)
    for channel in "${channels_to_add[@]}"; do
        if echo "$current_channels" | grep -q "$channel" >/dev/null 2>&1; then
            :
        else
            conda config --add channels "$channel" >/dev/null 2>&1
        fi
    done
    paths="./miniconda3/envs/jupyter-env/etc/jupyter:./miniconda3/envs/jupyter-env/bin/jupyter:./miniconda3/envs/jupyter-env/share/jupyter"
    export PATH="$paths:$PATH"
    new_path=$(echo "$PATH" | tr ':' '\n' | awk '!x[$0]++' | tr '\n' ':')
    export PATH="$new_path"
    source ~/.bashrc
    check_ipv4
    jpyurl="http://${IPV4}:13692/"
    green "已安装jupyter lab的web端到外网端口13692上，请打开你的 外网IP:13692"
    green "如果你是在云服务上运行，那么请打开 ${jpyurl} 如果是在本地安装的，请打开 http://127.0.0.1:13692/"
    green "初次安装会要求输入token设置密码，token详见上方打印信息或当前目录的nohup.out日志"
    green "同时已保存日志输出到当前目录的nohup.out中且已打印5秒日志如上"
    green "如果需要进一步查询，请关闭本窗口开一个新窗口再执行本脚本，否则无法加载一些预设的环境变量"
    green "如果想要手动查询，输入 source activate jupyter-env && jupyter server list && conda deactivate 即可查询"
    exit 0
}

query_jupyter_info() {
    source activate jupyter-env >/dev/null 2>&1
    if ! jupyter --version &>/dev/null; then
        echo "Error: Jupyter is not installed on this system."
        return 1
    fi
    check_ipv4
    jpyurl="http://${IPV4}:13692/"
    source activate jupyter-env && jupyter server list && conda deactivate
    cat nohup.out
    green "已查询登陆信息如上"
    green "如果你是在云服务上运行，那么请打开 ${jpyurl} 如果是在本地安装的，请打开 http://127.0.0.1:13692/"
    green "token详见上方打印信息或当前目录的nohup.out日志"
    green "如果想要手动查询，输入 source activate jupyter-env && jupyter server list && conda deactivate 即可查询"
}

main() {
    source activate jupyter-env >/dev/null 2>&1
    if jupyter --version &>/dev/null; then
        green "Jupyter is already installed on this system."
        if ! (nc -z localhost 13692) >/dev/null 2>&1; then
            source activate jupyter-env
            rm -rf nohup.out
            green "后台未启动jupyter，正在启动"
            nohup jupyter lab --port 13692 --no-browser --ip=0.0.0.0 --allow-root &
            green $!
            sleep 1
            jupyter lab
        fi
    else
        reading "Jupyter is not installed on this system. Do you want to install it? (y/n) " confirminstall
        echo ""
        if [ "$confirminstall" != "y" ]; then
            exit 0
        fi
        install_jupyter
    fi
    green "The current info for Jupyter:"
    query_jupyter_info
}

main
