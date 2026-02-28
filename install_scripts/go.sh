#!/bin/bash
# by spiritlhl
# from https://github.com/spiritLHLS/one-click-installation-script
# version: 2026.02.28

# 使用方法:
#   chmod +x go-install-fixed.sh
#   
#   # 安装最新版本
#   ./go-install-fixed.sh
#   
#   # 安装指定版本
#   ./go-install-fixed.sh -v 1.21.5
#   
#   # 强制重新安装
#   ./go-install-fixed.sh -f
#
#   # 组合使用
#   ./go-install-fixed.sh -v 1.20.10 -f
#
# 环境变量说明:
#   GOROOT: Go安装目录 (/usr/local/go)
#   GOPATH: Go工作空间目录 (默认: /home/go 或用户指定)
#   PATH: 添加 $GOROOT/bin 和 $GOPATH/bin
#
# 目录结构:
#   $GOPATH/
#   ├── src/     # 源代码目录
#   ├── pkg/     # 编译的包对象目录
#   └── bin/     # 编译的可执行文件目录

[[ -f /etc/redhat-release ]] && unalias -a

can_google=1
force_mode=0
sudo=""
os="Linux"
install_version=""
proxy_url="https://goproxy.cn"

red="31m"      
green="32m"  
yellow="33m" 
blue="36m"
fuchsia="35m"

color_echo(){
    echo -e "\033[$1${@:2}\033[0m"
}

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

get_profile_path(){
    if [[ $(id -u) -eq 0 ]]; then
        profile_path="/etc/profile"
    elif [[ $SHELL == *"zsh"* ]]; then
        profile_path="$HOME/.zshrc"
    elif [[ $SHELL == *"bash"* ]]; then
        profile_path="$HOME/.bashrc"
    else
        profile_path="$HOME/.profile"
    fi
}

setup_env(){
    get_profile_path
    
    # 设置GOROOT
    local GOROOT="/usr/local/go"
    if ! grep -q "export GOROOT=" "$profile_path" 2>/dev/null; then
        echo "export GOROOT=$GOROOT" >> $profile_path
    fi
    export GOROOT=$GOROOT
    
    # 设置GOPATH (仅root用户或GOPATH未设置时)
    if [[ $(id -u) -eq 0 || -z "$GOPATH" ]];then
        local default_gopath
        if [[ $(id -u) -eq 0 ]]; then
            default_gopath="/home/go"
        else
            default_gopath="$HOME/go"
        fi
        
        while :
        do
            read -p "设置GOPATH工作空间路径 (默认: `color_echo $blue $default_gopath`): " input_gopath
            if [[ $input_gopath ]];then
                if [[ ${input_gopath:0:1} != "/" ]];then
                    color_echo $yellow "请输入绝对路径!"
                    continue
                fi
                GOPATH="$input_gopath"
            else
                GOPATH="$default_gopath"
            fi
            break
        done
        
        echo "GOPATH工作空间: `color_echo $blue $GOPATH`"
        
        # 写入配置文件
        if ! grep -q "export GOPATH=" "$profile_path" 2>/dev/null; then
            echo "export GOPATH=$GOPATH" >> $profile_path
        fi
        if ! grep -q "export PATH=.*GOPATH/bin" "$profile_path" 2>/dev/null; then
            echo 'export PATH=$PATH:$GOPATH/bin' >> $profile_path
        fi
        
        # 创建Go工作空间目录结构
        mkdir -p "$GOPATH"/{src,pkg,bin}
        echo "已创建Go工作空间目录结构:"
        echo "  $GOPATH/src  (源代码目录)"
        echo "  $GOPATH/pkg  (编译包对象目录)"  
        echo "  $GOPATH/bin  (可执行文件目录)"
        
        export GOPATH=$GOPATH
        export PATH=$PATH:$GOPATH/bin
    fi
    
    # 添加GOROOT/bin到PATH
    if ! grep -q "/usr/local/go/bin" "$profile_path" 2>/dev/null; then
        echo 'export PATH=$PATH:/usr/local/go/bin' >> $profile_path
    fi
    
    export PATH=$PATH:/usr/local/go/bin
    
    echo "环境变量配置完成:"
    echo "  GOROOT: $GOROOT"
    echo "  GOPATH: ${GOPATH:-$HOME/go}"
    echo "  配置文件: $profile_path"
}

check_network(){
    ip_is_connect "golang.org"
    [[ ! $? -eq 0 ]] && can_google=0
}

setup_proxy(){
    if [[ $can_google == 0 && `go env 2>/dev/null|grep proxy.golang.org` ]]; then
        echo "配置Go模块代理..."
        go env -w GO111MODULE=on
        go env -w GOPROXY=$proxy_url,direct
        go env -w GOSUMDB=sum.golang.google.cn
        color_echo $green "✓ 已设置国内Go代理环境"
        echo "  GOPROXY: $proxy_url,direct"
        echo "  GOSUMDB: sum.golang.google.cn"
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
                install_version=`curl -s --connect-timeout 15 -H 'Cache-Control: no-cache' https://github.com/golang/go/tags|grep releases/tag|grep -v rc|grep -v beta|grep -oE '[0-9]+\.[0-9]+\.?[0-9]*'|head -n 1`
            else
                install_version=`curl -s --connect-timeout 15 -H 'Cache-Control: no-cache' https://go.dev/dl/|grep -w downloadBox|grep src|grep -oE '[0-9]+\.[0-9]+\.?[0-9]*'|head -n 1`
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
        current_version=`go version 2>/dev/null|awk '{print $3}'|grep -Eo "[0-9.]+"`
        if [[ "$current_version" == "$install_version" ]];then
            color_echo $green "golang $install_version 已安装，无需重复安装"
            return
        fi
    fi
    
    file_name="go${install_version}.$vdis.tar.gz"
    local temp_path=`mktemp -d`

    if [[ $can_google == 0 ]]; then
        dl_base="https://golang.google.cn/dl"
    else
        dl_base="https://dl.google.com/go"
    fi
    echo "正在下载 $file_name ..."
    if ! curl -H 'Cache-Control: no-cache' -L $dl_base/$file_name -o $file_name; then
        color_echo $red "下载失败!"
        rm -rf $temp_path $file_name
        exit 1
    fi
    
    echo "正在解压安装包..."
    if ! tar -C $temp_path -xzf $file_name; then
        color_echo $yellow "\n解压失败! 正在重新下载..."
        rm -rf $file_name
        if ! curl -H 'Cache-Control: no-cache' -L $dl_base/$file_name -o $file_name; then
            color_echo $red "重新下载失败!"
            rm -rf $temp_path
            exit 1
        fi
        if ! tar -C $temp_path -xzf $file_name; then
            color_echo $red "\n解压失败!"
            rm -rf $temp_path $file_name
            exit 1
        fi
    fi
    
    [[ -e /usr/local/go ]] && $sudo rm -rf /usr/local/go
    echo "正在安装到 /usr/local/go ..."
    $sudo mv $temp_path/go /usr/local/
    rm -rf $temp_path $file_name
    
    color_echo $green "✓ golang $install_version 安装完成"
    echo "安装目录: /usr/local/go"
}

install_updater(){
    local updater_content='#!/bin/bash
source <(curl -L https://go-install.netlify.app/install.sh) $@'
    
    if [[ $os == "Linux" ]];then
        if [[ ! -e /usr/local/bin/goupdate ]] || ! grep -q '$@' /usr/local/bin/goupdate 2>/dev/null; then
            echo "$updater_content" | $sudo tee /usr/local/bin/goupdate > /dev/null
            $sudo chmod +x /usr/local/bin/goupdate
        fi
    elif [[ $os == "Darwin" ]];then
        mkdir -p $HOME/go/bin
        if [[ ! -e $HOME/go/bin/goupdate ]] || ! grep -q '$@' $HOME/go/bin/goupdate 2>/dev/null; then
            echo "$updater_content" > $HOME/go/bin/goupdate
            chmod +x $HOME/go/bin/goupdate
        fi
    fi
}

verify_installation(){
    echo
    echo "========== 安装验证 =========="
    
    if command -v go >/dev/null 2>&1; then
        local version=$(go version 2>/dev/null)
        color_echo $green "✓ Go安装成功!"
        echo
        echo "版本信息: $version"
        echo "Go安装目录: $(go env GOROOT 2>/dev/null || echo '/usr/local/go')"
        echo "Go可执行文件: $(which go 2>/dev/null || echo '/usr/local/go/bin/go')"
        
        local gopath=$(go env GOPATH 2>/dev/null)
        if [[ -n "$gopath" ]]; then
            echo "Go工作空间: $gopath"
        fi
        echo
        echo "Go环境变量:"
        go env GOROOT GOPATH GOPROXY GOSUMDB 2>/dev/null | sed 's/^/  /'
        echo
        color_echo $green "========== 安装成功 =========="
        color_echo $yellow "当前如何使用Go环境 (选择其一):"
        echo "  1. 重新加载环境变量: source $profile_path"
        echo "  2. 重新打开终端窗口"
        echo "  3. 重新登录系统"
        echo "现在可以开始Go开发了!"
        return 0
    fi
}

main(){
    echo "========== Go语言安装脚本 =========="
    echo
    
    sys_arch
    echo "检测到系统: $os ($arch)"
    echo "目标架构: $vdis"
    echo
    
    check_network
    if [[ $can_google == 0 ]]; then
        color_echo $yellow "检测到国内网络环境，将使用国内镜像加速"
    fi
    echo
    
    install_go
    echo
    setup_env
    echo
    setup_proxy
    echo
    install_updater
    
    verify_installation
}

main
