#!/bin/bash
# Author: spiritLHLS
# GitHub: https://github.com/spiritLHLS/one-click-installation-script
# Version: 2026.02.28

set -euo pipefail
HOME="${HOME:-/root}"
LOG_FILE="/tmp/golang_install_$(date +%Y%m%d_%H%M%S).log"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[36m"
RESET="\033[0m"

log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

color_echo() {
    local color="$1"
    local message="${@:2}"
    echo -e "\033[${color}${message}${RESET}" | tee -a "$LOG_FILE"
}

error_exit() {
    color_echo "$RED" "错误: $1"
    exit 1
}

network_check() {
    local host="$1"
    if ping -c 2 -W 2 "$host" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

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

get_latest_go_version() {
    local versions
    # 先探测是否能访问 golang.org，决定 URL 优先顺序
    local url_list
    if ping -c 2 -W 2 golang.org > /dev/null 2>&1; then
        url_list=("https://go.dev/dl/" "https://golang.google.cn/dl/" "https://github.com/golang/go/tags")
    else
        url_list=("https://golang.google.cn/dl/" "https://github.com/golang/go/tags" "https://go.dev/dl/")
    fi
    for url in "${url_list[@]}"; do
        versions=$(curl -s --connect-timeout 10 "$url" | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1)
        if [[ -n "$versions" ]]; then
            echo "${versions#go}"
            return 0
        fi
    done
    error_exit "无法获取Go版本"
}

setup_go_environment() {
    local gopath="${HOME}/go"
    local go_bin="/usr/local/go/bin"
    mkdir -p "${gopath}/"{src,pkg,bin}
    local profiles=("${HOME}/.bashrc" "${HOME}/.zshrc" "/etc/profile")
    for profile in "${profiles[@]}"; do
        if [[ -f "$profile" ]]; then
            if ! grep -q "GOPATH" "$profile"; then
                {
                    echo "export GOPATH=${gopath}"
                    echo "export GOMODCACHE=\${GOPATH}/pkg/mod"
                    echo "export PATH=\$PATH:${go_bin}:\${GOPATH}/bin"
                    echo "export GOCACHE=${gopath}/.cache/go-build"
                } >> "$profile"
            fi
        fi
    done
    export GOPATH="${gopath}"
    export GOMODCACHE="${gopath}/pkg/mod"
    export GOCACHE="${gopath}/.cache/go-build"
    mkdir -p $GOCACHE
    export PATH="${PATH}:${go_bin}:${gopath}/bin"
}

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
    tar -C "${temp_dir}" -xzf "${temp_dir}/${filename}"
    [[ -d "/usr/local/go" ]] && sudo rm -rf /usr/local/go
    sudo mv "${temp_dir}/go" /usr/local/
    rm -rf "${temp_dir}"
    color_echo "$GREEN" "Go ${version} 安装成功！"
}

main() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "此脚本需要root权限运行"
    fi
    if ! network_check "golang.org"; then
        color_echo "$YELLOW" "国外网络不通，将使用国内代理"
        export GOPROXY=https://goproxy.cn,direct
    fi
    local platform=$(get_system_arch)
    local version=$(get_latest_go_version)
    install_golang "$version" "$platform"
    setup_go_environment
    go version
    color_echo "$GREEN" "Golang 安装和配置完成！"
}

main
