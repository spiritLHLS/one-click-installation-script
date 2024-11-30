#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2024.12.01

# 取消CentOS别名
[[ -f /etc/redhat-release ]] && unalias -a

can_google=1
force_mode=0
sudo=""
os="Linux"
install_version=""
proxy_url="https://goproxy.cn"

#######颜色代码########
red="31m"      
green="32m"  
yellow="33m" 
blue="36m"
fuchsia="35m"

color_echo(){
    echo -e "\033[$1${@:2}\033[0m"
}

#######获取参数#########
while [[ $# > 0 ]];do
    case "$1" in
        -v|--version)
        install_version="$2"
        echo -e "准备安装$(color_echo ${blue} $install_version)版本golang..\n"
        shift
        ;;
        -f)
        force_mode=1
        echo -e "强制更新golang..\n"
        ;;
        *)
        ;;
    esac
    shift
done

ip_is_connect(){
    ping -c2 -i0.3 -W1 $1 &>/dev/null
    if [ $? -eq 0 ];then
        return 0
    else
        return 1
    fi
}

setup_go_env() {
    local profile_paths=("/etc/profile" "$HOME/.bashrc" "$HOME/.zshrc")
    local default_gopath="/home/$(whoami)/go"
    local go_bin_path="/usr/local/go/bin"

    # 交互式设置GOPATH
    while :
    do
        read -p "默认GOPATH路径: $(color_echo $blue $default_gopath), 回车直接使用或输入自定义绝对路径: " GOPATH
        if [[ $GOPATH ]];then
            if [[ ${GOPATH:0:1} != "/" ]];then
                color_echo $yellow "请输入绝对路径!"
                continue
            fi
        else
            GOPATH="$default_gopath"
        fi
        break
    done

    # 确保GOPATH目录存在并有正确权限
    mkdir -p "$GOPATH/bin" "$GOPATH/src" "$GOPATH/pkg"
    chmod -R 755 "$GOPATH"

    # 为每个配置文件添加Go环境变量
    for path in "${profile_paths[@]}"; do
        if [[ -f "$path" ]]; then
            # 防止重复添加
            if ! grep -q "GOPATH=" "$path"; then
                echo "export GOPATH=$GOPATH" >> "$path"
                echo 'export PATH=$PATH:$GOPATH/bin:$GOPATH/bin:/usr/local/go/bin' >> "$path"
            fi
        fi
    done

    # 为root用户设置环境变量
    if [[ $EUID -eq 0 ]]; then
        echo "export GOPATH=$GOPATH" >> /etc/profile
        echo 'export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin' >> /etc/profile
    fi
}

check_network(){
    ip_is_connect "golang.org"
    [[ ! $? -eq 0 ]] && can_google=0
}

setup_proxy(){
    if [[ $can_google == 0 ]]; then
        go env -w GO111MODULE=on
        go env -w GOPROXY=$proxy_url,direct
        color_echo $green "当前网络环境为国内环境, 成功设置goproxy代理!"
    fi
}

sys_arch(){
    arch=$(uname -m)
    if [[ `uname -s` == "Darwin" ]];then
        os="Darwin"
        if [[ "$arch" == "arm64" ]];then
            vdis="darwin-arm64"
        else
            vdis="darwin-amd64"
        fi
    else
        if [[ "$arch" == "i686" ]] || [[ "$arch" == "i386" ]]; then
            vdis="linux-386"
        elif [[ "$arch" == *"armv7"* ]] || [[ "$arch" == "armv6l" ]]; then
            vdis="linux-armv6l"
        elif [[ "$arch" == *"armv8"* ]] || [[ "$arch" == "aarch64" ]]; then
            vdis="linux-arm64"
        elif [[ "$arch" == *"s390x"* ]]; then
            vdis="linux-s390x"
        elif [[ "$arch" == "ppc64le" ]]; then
            vdis="linux-ppc64le"
        elif [[ "$arch" == "x86_64" ]]; then
            vdis="linux-amd64"
        fi
    fi
    [ $(id -u) != "0" ] && sudo="sudo"
}

install_go(){
    if [[ -z $install_version ]];then
        echo "正在获取最新版golang..."
        count=0
        while :
        do
            install_version=""
            if [[ $can_google == 0 ]];then
                install_version=`curl -s --connect-timeout 15 -H 'Cache-Control: no-cache' https://go.dev/dl/|grep -w downloadBox|grep src|grep -oE '[0-9]+\.[0-9]+\.?[0-9]*'|head -n 1`
            else
                install_version=`curl -s --connect-timeout 15 -H 'Cache-Control: no-cache' https://github.com/golang/go/tags|grep releases/tag|grep -v rc|grep -v beta|grep -oE '[0-9]+\.[0-9]+\.?[0-9]*'|head -n 1`
            fi
            [[ ${install_version: -1} == '.' ]] && install_version=${install_version%?}
            if [[ -z $install_version ]];then
                if [[ $count < 3 ]];then
                    color_echo $yellow "获取go版本号超时, 正在重试..."
                else
                    color_echo $red "\n获取go版本号失败!"
                    exit 1
                fi
            else
                break
            fi
            count=$(($count+1))
        done
        echo "最新版golang: `color_echo $blue $install_version`"
    fi
    if [[ $force_mode == 0 && `command -v go` ]];then
        if [[ `go version|awk '{print $3}'|grep -Eo "[0-9.]+"` == $install_version ]];then
            return
        fi
    fi
    file_name="go${install_version}.$vdis.tar.gz"
    local temp_path=`mktemp -d`

    curl -H 'Cache-Control: no-cache' -L https://dl.google.com/go/$file_name -o $file_name
    tar -C $temp_path -xzf $file_name
    if [[ $? != 0 ]];then
        color_echo $yellow "\n解压失败! 正在重新下载..."
        rm -rf $file_name
        curl -H 'Cache-Control: no-cache' -L https://dl.google.com/go/$file_name -o $file_name
        tar -C $temp_path -xzf $file_name
        [[ $? != 0 ]] && { color_echo $yellow "\n解压失败!"; rm -rf $temp_path $file_name; exit 1; }

    fi
    [[ -e /usr/local/go ]] && $sudo rm -rf /usr/local/go
    $sudo mv $temp_path/go /usr/local/
    rm -rf $temp_path $file_name
}

install_updater(){
    if [[ $os == "Linux" ]];then
        if [[ ! -e /usr/local/bin/goupdate || -z `cat /usr/local/bin/goupdate|grep '$@'` ]];then
            echo 'source <(curl -L https://go-install.netlify.app/install.sh) $@' > /usr/local/bin/goupdate
            chmod +x /usr/local/bin/goupdate
        fi
    elif [[ $os == "Darwin" ]];then
        if [[ ! -e $HOME/go/bin/goupdate || -z `cat $HOME/go/bin/goupdate|grep '$@'` ]];then
            cat > $HOME/go/bin/goupdate << 'EOF'
#!/bin/zsh
source <(curl -L https://go-install.netlify.app/install.sh) $@
EOF
            chmod +x $HOME/go/bin/goupdate
        fi
    fi
}

main(){
    sys_arch
    check_network
    install_go
    setup_go_env
    setup_proxy
    install_updater
    echo -e "golang `color_echo $blue $install_version` 安装成功!"
}

main
source /etc/profile
source "$HOME/.bashrc" 2>/dev/null
source "$HOME/.zshrc" 2>/dev/null