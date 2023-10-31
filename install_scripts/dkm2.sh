#!/bin/bash
# by spiritlhl
# from https://github.com/spiritLHLS/one-click-installation-script
# version: 2023.10.31

export DEBIAN_FRONTEND=noninteractive

kill_processes() {
    local processes=("aegis_cli" "aegis_update" "AliYunDun" "AliHids" "AliHips" "AliYunDunUpdate")
    for process in "${processes[@]}"; do
        killall -9 "$process" >/dev/null 2>&1
    done
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
    /usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} stop
    /usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} uninstall
    rm -rf "/usr/local/cloudmonitor"

    service aegis stop
    chkconfig --del aegis

    /usr/local/cloudmonitor/wrapper/bin/cloudmonitor.sh stop
    /usr/local/cloudmonitor/wrapper/bin/cloudmonitor.sh remove
    rm -rf "/usr/local/cloudmonitor"

    systemctl stop aliyun.service
    pkill aliyun-service AliYunDunUpdate

    rm -rf "/etc/init.d/aegis" "/etc/init.d/agentwatch"
    rm -rf "/etc/systemd/system/aliyun.service"
    rm -rf "/usr/sbin/aliyun_installer" "/usr/sbin/aliyun-service" "/usr/sbin/aliyun-service.backup" "/usr/sbin/agetty"
}

uninstall_additional() {
    systemctl stop oracle-cloud-agent oracle-cloud-agent-updater
    systemctl disable oracle-cloud-agent oracle-cloud-agent-updater
    systemctl disable --now qemu-guest-agent
    /etc/KsyunAgent/uninstall.py
    service uma stop
    systemctl disable --now uma
    /usr/local/uniagent/extension/install/telescope/telescoped stop
    systemctl stop --no-block jcs-agent-core
    systemctl --no-reload disable jcs-agent-core
    stop --no-wait jcs-agent-core /etc/init.d/jcs-agent-core

    if [[ -f "/etc/centos-release" && $(grep ' 6' "/etc/centos-release") ]]; then
        echo "Disable expand-root at startup ..."
        chkconfig --level 2345 expand-root off
        echo "Remove dracut growroot module ..."
        rm -rf "/usr/share/dracut/modules.d/50growroot"
        echo "Update dracut ..."
        dracut --force
        echo "Remove sgdisk tool in /usr/bin ..."
        rm -f "/usr/bin/sgdisk"
        echo "Remove growpart tool in /usr/bin ..."
        rm -f "/usr/bin/growpart"
    fi

    systemctl stop --no-block jcs-shutdown-scripts jcs-entry
    systemctl --no-reload disable jcs-shutdown-scripts jcs-entry
    stop --no-wait jcs-shutdown-scripts jcs-entry /etc/init.d/jcs-shutdown-scripts /etc/init.d/jcs-entry
    service jcs-entry stop jcs-shutdown-scripts
    chkconfig jcs-entry off
    chkconfig jcs-shutdown-scripts off
    update-rc.d jcs-entry remove
    update-rc.d jcs-shutdown-scripts remove
    pkill jdog
    rm -rf "/usr/local/share/jcloud"
}

check_root() {
    [ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
}

stop_aegis_processes() {
    killall -9 aegis_cli aegis_update AliYunDun AliYunDunMonitor AliHids AliYunDunUpdate assist_daemon assist-daemon aliyun* AliYunDun* AliSecure* aegis*
    printf "%-40s %40s\n" "Stopping aegis processes" "[  OK  ]"
}

stop_quartz() {
    killall -9 aegis_quartz
    printf "%-40s %40s\n" "Stopping quartz" "[  OK  ]"
}

remove_aegis() {
    if [ -d /usr/local/aegis ]; then
        systemctl stop aegis.service
        systemctl disable aegis.service
        umount /usr/local/aegis/aegis_debug
        rm -rf /usr/local/aegis/*
        rm -rf /usr/local/share/assist-daemon/*
        rm -rf /usr/local/share/aliyun*
        rm -rf /sys/fs/cgroup/devices/system.slice/aegis.service
    fi
}

uninstall_service() {
    if [ -f "/etc/init.d/aegis" ]; then
        /etc/init.d/aegis stop >/dev/null 2>&1
        rm -f /etc/init.d/aegis
    fi
    if [ $LINUX_RELEASE = "GENTOO" ]; then
        rc-update del aegis default 2>/dev/null
        if [ -f "/etc/runlevels/default/aegis" ]; then
            rm -f "/etc/runlevels/default/aegis" >/dev/null 2>&1
        fi
    elif [ -f /etc/init.d/aegis ]; then
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
        rm -rf /etc/aliyun-util

        rm -rf /etc/systemd/system/multi-user.target.wants/ecs_mq.service
        rm -rf /etc/systemd/system/multi-user.target.wants/aliyun.service

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
    echo "" > /etc/hostname
    echo "localhost" > /etc/hostname
    sed -i "s/${hostname}/localhost/g" /etc/hosts
}


check_root
kill_processes
uninstall_aegis
uninstall_cloud_monitoring
uninstall_additional
stop_aegis_processes
umount /usr/local/aegis/aegis_debug
stop_quartz
remove_aegis
uninstall_service
remove_agentwatch
remove_all_aliyunfiles
remove_cloud_monitor
rescue_localhost_name
echo "Uninstallation complete."