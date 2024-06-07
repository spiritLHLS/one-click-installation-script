#!/bin/bash
# by spiritlhl
# from https://github.com/spiritLHLS/one-click-installation-script
# version: 2023.11.01

export DEBIAN_FRONTEND=noninteractive
AEGIS_INSTALL_DIR="/usr/local/aegis"
#check linux Gentoo os
var=$(lsb_release -a | grep Gentoo)
if [ -z "${var}" ]; then
    var=$(cat /etc/issue | grep Gentoo)
fi
checkCoreos=$(cat /etc/os-release 2>/dev/null | grep coreos)
if [ -d "/etc/runlevels/default" -a -n "${var}" ]; then
    LINUX_RELEASE="GENTOO"
elif [ -f "/etc/os-release" -a -n "${checkCoreos}" ]; then
    LINUX_RELEASE="COREOS"
    AEGIS_INSTALL_DIR="/opt/aegis"
else
    LINUX_RELEASE="OTHER"
fi

_red() { echo -e "\033[31m\033[01m$@\033[0m"; }
_green() { echo -e "\033[32m\033[01m$@\033[0m"; }
_yellow() { echo -e "\033[33m\033[01m$@\033[0m"; }
_blue() { echo -e "\033[36m\033[01m$@\033[0m"; }
reading() { read -rp "$(_green "$1")" "$2"; }

uninstall_qcloud() {
    # 腾讯云
    /usr/local/qcloud/stargate/admin/uninstall.sh
    /usr/local/qcloud/YunJing/uninst.sh
    /usr/local/qcloud/monitor/barad/admin/uninstall.sh
    rm -f /etc/cron.d/sgagenttask
    crontab -l | grep -v '/usr/local/qcloud/stargate/admin' | crontab -
    rm -rf /usr/local/qcloud
}

uninstall_oralce() {
    # 甲骨文云
    systemctl stop oracle-cloud-agent
    systemctl disable oracle-cloud-agent
    systemctl stop oracle-cloud-agent-updater
    systemctl disable oracle-cloud-agent-updater
    systemctl disable --now qemu-guest-agent
    if command -v snap >/dev/null 2>&1; then
        snap remove oracle-cloud-agent
    fi
}

uninstall_jdcloud() {
    # 其他云
    /etc/KsyunAgent/uninstall.py
    service uma stop
    systemctl disable --now uma
    /usr/local/uniagent/extension/install/telescope/telescoped stop
    # 京东云
    systemctl stop --no-block jcs-agent-core
    systemctl --no-reload disable jcs-agent-core
    if command -v stop >/dev/null 2>&1; then
        stop --no-wait jcs-agent-core /etc/init.d/jcs-agent-core
    fi

    if [[ -f "/etc/centos-release" && $(grep ' 6' "/etc/centos-release") ]]; then
        chkconfig --level 2345 expand-root off >/dev/null 2>&1
        sysv-rc-conf --level 2345 expand-root off >/dev/null 2>&1
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
    chkconfig jcs-entry off >/dev/null 2>&1
    chkconfig jcs-shutdown-scripts off >/dev/null 2>&1
    sysv-rc-conf jcs-entry off >/dev/null 2>&1
    sysv-rc-conf jcs-shutdown-scripts off >/dev/null 2>&1
    update-rc.d jcs-entry remove
    update-rc.d jcs-shutdown-scripts remove
    pkill jdog
    rm -rf "/usr/local/share/jcloud"
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
    if [ -d "$AEGIS_INSTALL_DIR" ]; then
        rm -rf "$AEGIS_INSTALL_DIR/aegis_client"
        rm -rf "$AEGIS_INSTALL_DIR/aegis_update"
        rm -rf "$AEGIS_INSTALL_DIR/alihids"
    fi

    if [ -d "$AEGIS_INSTALL_DIR/aegis_debug" ]; then
        umount "$AEGIS_INSTALL_DIR/aegis_debug"
        rm -rf "$AEGIS_INSTALL_DIR/aegis_debug"
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

wait_aegis_exit() {
    var=1
    limit=10
    echo "wait aegis exit"

    while [[ $var -lt $limit ]]; do
        if [ -n "$(ps -ef | grep aegis_client | grep -v grep)" ]; then
            sleep 1
        else
            return
        fi

        ((var++))
    done

    _red "wait AliYunDun process exit fail, possibly due to self-protection, please uninstall aegis or disable self-protection from the aegis console."
}

uninstall_cloud_monitoring() {
    # 阿里云
    ARCH=$(arch)
    /usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} stop
    /usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} uninstall
    rm -rf "/usr/local/cloudmonitor"

    service aegis stop
    update-rc.d aegis disable
    chkconfig --del aegis >/dev/null 2>&1
    sysv-rc-conf --del aegis >/dev/null 2>&1

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
    rm -rf "$AEGIS_INSTALL_DIR"
    rm -rf "/usr/local/share/aliyun-assist"
    rm -rf "/usr/local/cloudmonitor"
}

check_root() {
    [ $(id -u) != "0" ] && {
        echo "Error: You must be root to run this script"
        exit 1
    }
}

remove_aegis() {
    if [ -d $AEGIS_INSTALL_DIR ]; then
        systemctl stop aegis.service 2>/dev/null
        systemctl disable aegis.service 2>/dev/null
        rm -rf "/etc/systemd/system/aegis.service"
        umount "$AEGIS_INSTALL_DIR/aegis_debug"
        rm -rf $AEGIS_INSTALL_DIR/* >/dev/null 2>&1
        rm -rf /usr/local/share/assist-daemon/* >/dev/null 2>&1
        rm -rf /usr/local/share/aliyun* >/dev/null 2>&1
        rm -rf /sys/fs/cgroup/devices/system.slice/aegis.service >/dev/null 2>&1
    fi

    kprobeArr=(
        "/sys/kernel/debug/tracing/instances/aegis_do_sys_open/set_event"
        "/sys/kernel/debug/tracing/instances/aegis_inet_csk_accept/set_event"
        "/sys/kernel/debug/tracing/instances/aegis_tcp_connect/set_event"
        "/sys/kernel/debug/tracing/instances/aegis/set_event"
        "/sys/kernel/debug/tracing/instances/aegis_/set_event"
        "/sys/kernel/debug/tracing/instances/aegis_accept/set_event"
        "/sys/kernel/debug/tracing/kprobe_events"
        "$AEGIS_INSTALL_DIR/aegis_debug/tracing/set_event"
        "$AEGIS_INSTALL_DIR/aegis_debug/tracing/kprobe_events"
    )
    for value in ${kprobeArr[@]}; do
        if [ -f "$value" ]; then
            echo >$value
        fi
    done

    if [ -d "${AEGIS_INSTALL_DIR}" ]; then
        umount ${AEGIS_INSTALL_DIR}/aegis_debug
        if [ -d "${AEGIS_INSTALL_DIR}/cgroup/cpu" ]; then
            umount ${AEGIS_INSTALL_DIR}/cgroup/cpu
        fi
        if [ -d "${AEGIS_INSTALL_DIR}/cgroup" ]; then
            umount ${AEGIS_INSTALL_DIR}/cgroup
        fi
        rm -rf ${AEGIS_INSTALL_DIR}/aegis_client
        rm -rf ${AEGIS_INSTALL_DIR}/aegis_update
        rm -rf ${AEGIS_INSTALL_DIR}/alihids
        rm -f ${AEGIS_INSTALL_DIR}/globalcfg/domaincfg.ini >/dev/null 2>&1
    fi
    if [ -d $AEGIS_INSTALL_DIR/aegis_debug ]; then
        if [ -d $AEGIS_INSTALL_DIR/aegis_debug/tracing/instances/aegis ]; then
            echo >$AEGIS_INSTALL_DIR/aegis_debug/tracing/instances/aegis/set_event
        else
            echo >$AEGIS_INSTALL_DIR/aegis_debug/tracing/set_event
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
        # find . -iname "*aegis*" -type f -print -exec rm -rf {} \;
        # find . -iname "*aegis*" | xargs rm -rf
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
uninstall_oralce
uninstall_jdcloud
kill_processes
pkill_processes
wait_aegis_exit
uninstall_aegis
remove_aegis
uninstall_cloud_monitoring
remove_aegis
if [ -d "$AEGIS_INSTALL_DIR/aegis_debug" ]; then
    umount "$AEGIS_INSTALL_DIR/aegis_debug"
    rm -rf "$AEGIS_INSTALL_DIR/aegis_debug"
fi
remove_agentwatch
remove_all_aliyunfiles
remove_cloud_monitor
rescue_localhost_name
_green "Uninstallation complete, please reboot to change completely."
