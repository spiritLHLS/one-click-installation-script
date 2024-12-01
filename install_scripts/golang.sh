#!/bin/bash
# Author: spiritLHLS
# GitHub: https://github.com/spiritLHLS/one-click-installation-script
# Version: 2024.12.02

# 严格模式，提高脚本健壮性
set -euo pipefail

# 日志文件
LOG_FILE="/tmp/golang_install_$(date +%Y%m%d_%H%M%S).log"

# 颜色定义
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[36m"
RESET="\033[0m"

# 日志记录函数
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# 彩色输出函数
color_echo() {
    local color="$1"
    local message="${@:2}"
    echo -e "\033[${color}${message}${RESET}" | tee -a "$LOG_FILE"
}

# 错误处理函数
error_exit() {
    color_echo "$RED" "错误: $1"
    exit 1
}

# 网络连接检测函数
network_check() {
    local host="$1"
    if ping -c 2 -W 2 "$host" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 获取系统架构
get_system_arch() {
    local arch=$(uname -m)
    local os=$(uname -s)

    case "$os" in 
        "Darwin")
            os="darwin"
            ;;
        "Linux")
            os="linux"
            ;;
        *)
            error_exit "不支持的操作系统: $os"
            ;;
    esac

    case "$arch" in
        "x86_64")     arch="amd64" ;;
        "aarch64")    arch="arm64" ;;
        "armv7l")     arch="armv6l" ;;
        "i686"|"i386")arch="386" ;;
        *)            arch="amd64" ;;
    esac

    echo "${os}-${arch}"
}

# 获取最新Go版本
get_latest_go_version() {
    local versions
    local proxy_url="https://goproxy.cn"

    # 尝试获取版本，支持多种代理
    for url in "https://go.dev/dl/" "https://golang.google.cn/dl/" "https://github.com/golang/go/tags"; do
        versions=$(curl -s --connect-timeout 10 "$url" | grep -oE 'go[0-9]+\.[0-9]+(\.[0-9]+)?' | sort -V | tail -n 1)
        
        if [[ -n "$versions" ]]; then
            echo "${versions#go}"
            return 0
        fi
    done

    error_exit "无法获取Go版本"
}

# 设置Go环境变量
setup_go_environment() {
    local gopath="${HOME}/go"
    local go_bin="/usr/local/go/bin"

    mkdir -p "${gopath}/"{src,pkg,bin}

    # 更新多个配置文件
    local profiles=("${HOME}/.bashrc" "${HOME}/.zshrc" "/etc/profile")
    for profile in "${profiles[@]}"; do
        if [[ -f "$profile" ]]; then
            if ! grep -q "GOPATH" "$profile"; then
                {
                    echo "export GOPATH=${gopath}"
                    echo "export GOMODCACHE=\${GOPATH}/pkg/mod"
                    echo "export PATH=\$PATH:${go_bin}:\${GOPATH}/bin"
                } >> "$profile"
            fi
        fi
    done

    # 立即生效
    export GOPATH="${gopath}"
    export GOMODCACHE="${gopath}/pkg/mod"
    export PATH="${PATH}:${go_bin}:${gopath}/bin"
}

# 下载并安装Go
install_golang() {
    local version="$1"
    local platform="$2"
    local filename="go${version}.${platform}.tar.gz"
    local download_url="https://golang.google.cn/dl/${filename}"
    local temp_dir=$(mktemp -d)

    color_echo "$BLUE" "准备下载Go ${version}"
    
    if ! curl -L "${download_url}" -o "${temp_dir}/${filename}"; then
        error_exit "下载失败，请检查网络"
    fi

    # 解压并移动
    tar -C "${temp_dir}" -xzf "${temp_dir}/${filename}"
    
    # 删除旧版本（如果存在）
    [[ -d "/usr/local/go" ]] && sudo rm -rf /usr/local/go

    sudo mv "${temp_dir}/go" /usr/local/
    
    # 清理临时文件
    rm -rf "${temp_dir}"

    color_echo "$GREEN" "Go ${version} 安装成功！"
}

# 主安装流程
main() {
    # 检查是否为root或有sudo权限
    if [[ $EUID -ne 0 ]]; then
        error_exit "此脚本需要root权限运行"
    fi

    # 网络检查
    if ! network_check "golang.org"; then
        color_echo "$YELLOW" "国外网络不通，将使用国内代理"
        export GOPROXY=https://goproxy.cn,direct
    fi

    # 获取系统架构
    local platform=$(get_system_arch)
    
    # 获取最新版本
    local version=$(get_latest_go_version)

    # 安装Go
    install_golang "$version" "$platform"

    # 设置Go环境
    setup_go_environment

    # 验证安装
    go version

    color_echo "$GREEN" "Golang 安装和配置完成！"
}

# 运行主流程
main
