#!/bin/bash
# by spiritlhl
# from https://github.com/spiritLHLS/one-click-installation-script
# version: 2023.11.01

export DEBIAN_FRONTEND=noninteractive
var=$(lsb_release -a | grep Gentoo)
if [ -z "${var}" ]; then
    var=$(cat /etc/issue | grep Gentoo)
fi
if [ -d "/etc/runlevels/default" -a -n "${var}" ]; then
    LINUX_RELEASE="GENTOO"
else
    LINUX_RELEASE="OTHER"
fi

uninstall_qcloud() {
    /usr/local/qcloud/stargate/admin/uninstall.sh
    /usr/local/qcloud/YunJing/uninst.sh
    /usr/local/qcloud/monitor/barad/admin/uninstall.sh
}

kill_processes() {
    local process
    local killall_processes=("aegis_cli" "aegis_update" "AliYunDun" "AliYunDunMonitor" "AliHids" "AliHips" "AliYunDunUpdate")
    for process in "${killall_processes[@]}"; do
        killall -9 "$process" >/dev/null 2>&1
        printf "%-40s %40s\n" "Killall $process" "[  OK  ]"
    done
}

pkill_processes() {
    local process
    local pkill_processes=("assist_daemon" "assist-daemon" "aliyun*" "AliYunDun*" "AliSecure*" "aegis*")
    for process in "${pkill_processes[@]}"; do
        pkill "$process" >/dev/null 2>&1
        printf "%-40s %40s\n" "Pkill $process" "[  OK  ]"
    done
    killall -9 aegis_quartz >/dev/null 2>&1
    printf "%-40s %40s\n" "Killall aegis_quartz" "[  OK  ]"
}

uninstall_aegis() {
    if [ -d "/usr/local/aegis" ]; then
        rm -rf "/usr/local/aegis/aegis_client" "/usr/local/aegis/aegis_update" "/usr/local/aegis/alihids"
    fi

    if [ -d "/usr/local/aegis/aegis_debug" ]; then
        umount "/usr/local/aegis/aegis_debug"
        rm -rf "/usr/local/aegis/aegis_debug"
    fi

    if [ -f "/etc/init.d/aegis" ]; then
        /etc/init.d/aegis stop >/dev/null 2>&1
        rm -f "/etc/init.d/aegis"
    fi

    if [ "$LINUX_RELEASE" = "GENTOO" ]; then
        rc-update del aegis default 2>/dev/null
        rm -f "/etc/runlevels/default/aegis" >/dev/null 2>&1
    elif [ -f "/etc/init.d/aegis" ]; then
        /etc/init.d/aegis uninstall
        for ((var = 2; var <= 5; var++)); do
            if [ -d "/etc/rc${var}.d/" ]; then
                rm -f "/etc/rc${var}.d/S80aegis"
            elif [ -d "/etc/rc.d/rc${var}.d" ]; then
                rm -f "/etc/rc.d/rc${var}.d/S80aegis"
            fi
        done
    fi
}

uninstall_cloud_monitoring() {
    # 阿里云
    ARCH=$(arch)
    /usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} stop
    /usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} uninstall
    rm -rf "/usr/local/cloudmonitor"

    service aegis stop
    update-rc.d aegis disable
    chkconfig --del aegis
    sysv-rc-conf --del aegis

    /usr/local/cloudmonitor/wrapper/bin/cloudmonitor.sh stop
    /usr/local/cloudmonitor/wrapper/bin/cloudmonitor.sh remove
    rm -rf "/usr/local/cloudmonitor"

    systemctl stop aliyun.service
    pkill aliyun-service
    pkill AliYunDun
    pkill agetty
    pkill AliYunDunUpdate

    rm -rf "/etc/init.d/aegis"
    rm -rf "/etc/init.d/agentwatch"
    rm -rf "/etc/systemd/system/aliyun.service"
    rm -rf "/usr/sbin/aliyun_installer"
    rm -rf "/usr/sbin/aliyun-service"
    rm -rf "/usr/sbin/aliyun-service.backup"
    rm -rf "/usr/sbin/agetty"
    rm -rf "/usr/local/aegis"
    rm -rf "/usr/local/share/aliyun-assist"
    rm -rf "/usr/local/cloudmonitor"

    # 甲骨文云
    systemctl stop oracle-cloud-agent
    systemctl disable oracle-cloud-agent
    systemctl stop oracle-cloud-agent-updater
    systemctl disable oracle-cloud-agent-updater
    systemctl disable --now qemu-guest-agent

    # 其他云的卸载
    /etc/KsyunAgent/uninstall.py
    service uma stop
    systemctl disable --now uma
    /usr/local/uniagent/extension/install/telescope/telescoped stop
    systemctl stop --no-block jcs-agent-core
    systemctl --no-reload disable jcs-agent-core
    if command -v stop >/dev/null 2>&1; then
        stop --no-wait jcs-agent-core /etc/init.d/jcs-agent-core
    fi

    if [[ -f "/etc/centos-release" && $(grep ' 6' "/etc/centos-release") ]]; then
        chkconfig --level 2345 expand-root off
        rm -rf "/usr/share/dracut/modules.d/50growroot"
        dracut --force
        rm -f "/usr/bin/sgdisk"
        rm -f "/usr/bin/growpart"
    fi

    systemctl stop --no-block jcs-shutdown-scripts
    systemctl stop --no-block jcs-entry
    systemctl --no-reload disable jcs-shutdown-scripts
    systemctl --no-reload disable jcs-entry
    if command -v stop >/dev/null 2>&1; then
        stop --no-wait jcs-shutdown-scripts
        stop --no-wait jcs-entry
        stop --no-wait /etc/init.d/jcs-shutdown-scripts
        stop --no-wait /etc/init.d/jcs-entry
    fi
    service jcs-entry stop
    service jcs-shutdown-scripts stop
    chkconfig jcs-entry off
    chkconfig jcs-shutdown-scripts off
    update-rc.d jcs-entry remove
    update-rc.d jcs-shutdown-scripts remove
    pkill jdog
    rm -rf "/usr/local/share/jcloud"

}

check_root() {
    [ $(id -u) != "0" ] && {
        echo "Error: You must be root to run this script"
        exit 1
    }
}

remove_aegis() {
    if [ -d /usr/local/aegis ]; then
        systemctl stop aegis.service
        systemctl disable aegis.service
        umount /usr/local/aegis/aegis_debug
        rm -rf /usr/local/aegis/* >/dev/null 2>&1
        rm -rf /usr/local/share/assist-daemon/* >/dev/null 2>&1
        rm -rf /usr/local/share/aliyun* >/dev/null 2>&1
        rm -rf /sys/fs/cgroup/devices/system.slice/aegis.service >/dev/null 2>&1
    fi
    if [ -d /usr/local/aegis/aegis_debug ]; then
        if [ -d /usr/local/aegis/aegis_debug/tracing/instances/aegis ]; then
            echo >/usr/local/aegis/aegis_debug/tracing/instances/aegis/set_event
        else
            echo >/usr/local/aegis/aegis_debug/tracing/set_event
        fi
    fi
}

remove_agentwatch() {
    agentwatch=$(ps aux | grep 'agentwatch')
    if [[ -n $agentwatch ]]; then
        systemctl stop agentwatch.service
        systemctl disable agentwatch.service
        cd /
        find . -name 'agentwatch*' -type d -exec rm -rf {} \;
        find . -name 'agentwatch*' -type f -exec rm -rf {} \;
    fi
}

remove_all_aliyunfiles() {
    aliyunsrv=$(ps aux | grep 'aliyun')
    if [[ -n $aliyunsrv ]]; then
        cd /
        systemctl stop aliyun-util.service
        systemctl disable aliyun-util.service
        systemctl stop aliyun.service
        systemctl disable aliyun.service

        rm -fr /usr/sbin/aliyun-service /usr/sbin/aliyun_installer
        rm /etc/systemd/system/aliyun-util.service
        rm -rf /etc/aliyun-util >/dev/null 2>&1

        rm -rf /etc/systemd/system/multi-user.target.wants/ecs_mq.service >/dev/null 2>&1
        rm -rf /etc/systemd/system/multi-user.target.wants/aliyun.service >/dev/null 2>&1

        find . -iname "*aliyu*" -type f -print -exec rm -rf {} \;
        find . -iname "*aliyu*" | xargs rm -rf
        find . -iname "*aegis*" -type f -print -exec rm -rf {} \;
        find . -iname "*aegis*" | xargs rm -rf
        find . -iname "*AliVulfix*" -type f -print -exec rm -rf {} \;
        find . -iname "*AliVulfix*" | xargs rm -rf
    fi
}

remove_cloud_monitor() {
    CloudMonitorSrv=$(ps aux | grep 'cloudmonitor')
    if [[ -n $CloudMonitorSrv ]]; then
        cd /
        rm -rf /usr/local/cloudmonitor
    fi
}

rescue_localhost_name() {
    hostname=$(cat /etc/hostname)
    echo "" >/etc/hostname
    echo "localhost" >/etc/hostname
    sed -i "s/${hostname}/localhost/g" /etc/hosts
}

check_root
touch /etc/cloud/cloud-init.disabled
uninstall_qcloud
kill_processes
pkill_processes
remove_aegis
uninstall_aegis
uninstall_cloud_monitoring
remove_aegis
remove_agentwatch
remove_all_aliyunfiles
remove_cloud_monitor
rescue_localhost_name
echo "Uninstallation complete, please reboot to change completely."
