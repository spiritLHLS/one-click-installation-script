#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2024.12.25


# 颜色和提示函数
red() { echo -e "\033[31m\033[01m$1$2\033[0m"; }
green() { echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow() { echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading() { read -rp "$(green "$1")" "$2"; }

# 判断系统环境
REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "fedora" "arch")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Fedora" "Arch")
CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')")

SYS="${CMD[0]}"
[[ -n $SYS ]] || exit 1

for ((int = 0; int < ${#REGEX[@]}; int++)); do
    if [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]]; then
        SYSTEM="${RELEASE[int]}"
        [[ -n $SYSTEM ]] && break
    fi
done

# 检查 root 权限
[[ $EUID -ne 0 ]] && red "请在root用户下运行脚本" && exit 1

# 设置UTF-8
utf8_locale=$(locale -a 2>/dev/null | grep -i -m 1 -E "UTF-8|utf8")
if [[ -n "$utf8_locale" ]]; then
    export LC_ALL="$utf8_locale"
    export LANG="$utf8_locale"
    export LANGUAGE="$utf8_locale"
fi

# 临时文件
tmp_servers="/tmp/nat64_servers.txt"

# 清理函数
cleanup() {
    rm -f "$tmp_servers"
    stty sane
}
trap cleanup EXIT INT TERM

# 主逻辑
green "开始获取 NAT64 服务器列表..."

# 下载并解析服务器列表
curl -g -6 -s "https://raw.githubusercontent.com/level66network/nat64.xyz/refs/heads/main/content/_index.md" | \
awk -F'|' '
/\|.*\|.*\|/ {
    if ($0 !~ /Provider.*Country.*DNS64/) {
        provider = $2
        location = $3
        dns64 = $4
        prefix = $5
        
        while (match(dns64, /[0-9a-fA-F:]+::[0-9a-fA-F:]*[0-9a-fA-F]+/)) {
            ip = substr(dns64, RSTART, RLENGTH)
            dns64 = substr(dns64, RSTART + RLENGTH)
            
            if (match(prefix, /[0-9a-fA-F:]+::[0-9a-fA-F:]*\/[0-9]+/)) {
                nat64prefix = substr(prefix, RSTART, RLENGTH)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", ip)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", nat64prefix)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", provider)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", location)
                if (ip != "" && nat64prefix != "") {
                    print provider "|" location "|" ip "|" nat64prefix
                }
            }
        }
    }
}' > "$tmp_servers"

# 测试服务器
green "开始测试服务器延迟..."
best_latency=999999
best_config=""

while IFS='|' read -r provider location dns64 prefix; do
    [[ -z "$provider" ]] && continue
    
    yellow "测试 $provider ($location)"
    yellow "DNS64: $dns64"
    
    if latency=$(ping6 -c 4 -w 5 "$dns64" 2>/dev/null | grep 'rtt' | cut -d'/' -f5); then
        latency=${latency%.*}
        green "延迟: ${latency}ms"
        
        if [ "$latency" -lt "$best_latency" ]; then
            best_latency=$latency
            best_config="$provider|$location|$dns64|$prefix|$latency"
        fi
    else
        red "无法连接"
    fi
done < "$tmp_servers"

# 显示最佳结果
if [[ -n "$best_config" ]]; then
    IFS='|' read -r provider location dns64 prefix latency <<< "$best_config"
    green "\n最佳 NAT64 服务器配置："
    yellow "提供商: $provider"
    yellow "位置: $location"
    yellow "DNS64: $dns64"
    yellow "NAT64 前缀: $prefix"
    yellow "延迟: ${latency}ms"
    
    reading "是否要应用这些设置？(y/n) " yn
    case $yn in
        [Yy]*)
            # 备份当前设置
            cp /etc/resolv.conf "/etc/resolv.conf.backup.$(date +%Y%m%d_%H%M%S)"
            
            # 配置 DNS64
            echo "nameserver $dns64" > /etc/resolv.conf
            
            # systemd-resolved 配置
            if [[ -f /etc/systemd/resolved.conf ]]; then
                sed -i '/^DNS=/c\DNS='"$dns64" /etc/systemd/resolved.conf
                systemctl restart systemd-resolved
            fi
            
            green "配置完成！"
            yellow "NAT64 前缀: $prefix"
            ;;
        *)
            yellow "已取消配置"
            ;;
    esac
else
    red "未找到可用的 NAT64 服务器"
fi

exit 0