#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2023.06.16

export DEBIAN_FRONTEND=noninteractive
/usr/local/qcloud/stargate/admin/uninstall.sh
/usr/local/qcloud/YunJing/uninst.sh
/usr/local/qcloud/monitor/barad/admin/uninstall.sh
killall -9 aegis_cli >/dev/null 2>&1
killall -9 aegis_update >/dev/null 2>&1
killall -9 aegis_cli >/dev/null 2>&1
killall -9 AliYunDun >/dev/null 2>&1
killall -9 AliHids >/dev/null 2>&1
killall -9 AliHips >/dev/null 2>&1
killall -9 AliYunDunUpdate >/dev/null 2>&1
if [ -d /usr/local/aegis/aegis_debug ]; then
    if [ -d /usr/local/aegis/aegis_debug/tracing/instances/aegis ]; then
        echo >/usr/local/aegis/aegis_debug/tracing/instances/aegis/set_event
    else
        echo >/usr/local/aegis/aegis_debug/tracing/set_event
    fi
fi

if [ -d /sys/kernel/debug ]; then
    if [ -d /sys/kernel/debug/tracing/instances/aegis ]; then
        echo >/sys/kernel/debug/tracing/instances/aegis/set_event
    else
        echo >/sys/kernel/debug/tracing/set_event
    fi
fi
if [ -d /usr/local/aegis ]; then
    rm -rf /usr/local/aegis/aegis_client
    rm -rf /usr/local/aegis/aegis_update
    rm -rf /usr/local/aegis/alihids
fi

if [ -d /usr/local/aegis/aegis_debug ]; then
    umount /usr/local/aegis/aegis_debug
    rm -rf /usr/local/aegis/aegis_debug
fi
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
/usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} stop &&
    /usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} uninstall &&
    rm -rf /usr/local/cloudmonitor
service aegis stop
chkconfig --del aegis
/usr/local/cloudmonitor/wrapper/bin/cloudmonitor.sh stop
/usr/local/cloudmonitor/wrapper/bin/cloudmonitor.sh remove &&
    rm -rf /usr/local/cloudmonitor
systemctl stop aliyun.service
pkill aliyun-service
pkill AliYunDun
pkill agetty
pkill AliYunDunUpdate
rm -rf /etc/init.d/aegis
rm -rf /etc/init.d/agentwatch
rm -rf /etc/systemd/system/aliyun.service
rm -rf /usr/sbin/aliyun_installer
rm -rf /usr/sbin/aliyun-service
rm -rf /usr/sbin/aliyun-service.backup
rm -rf /usr/sbin/agetty
rm -rf /usr/local/aegis
rm -rf /usr/local/share/aliyun-assist
rm -rf /usr/local/cloudmonitor
systemctl stop oracle-cloud-agent
systemctl disable oracle-cloud-agent
systemctl stop oracle-cloud-agent-updater
systemctl disable oracle-cloud-agent-updater
systemctl disable --now qemu-guest-agent
/etc/KsyunAgent/uninstall.py
service uma stop
systemctl disable --now uma
/usr/local/uniagent/extension/install/telescope/telescoped stop
systemctl stop --no-block jcs-agent-core
systemctl --no-reload disable jcs-agent-core
stop --no-wait jcs-agent-core
/etc/init.d/jcs-agent-core
if [[ -f "/etc/centos-release" && $(grep ' 6' /etc/centos-release) ]]; then
    echo "Disable expand-root at startup ..."
    chkconfig --level 2345 expand-root off

    echo "Remove dracut growroot module ..."
    rm -rf /usr/share/dracut/modules.d/50growroot

    echo "Update dracut ..."
    dracut --force

    echo "Remove sgdisk tool in /usr/bin ..."
    rm -f /usr/bin/sgdisk

    echo "Remove growpart tool in /usr/bin ..."
    rm -f /usr/bin/growpart
fi
systemctl stop --no-block jcs-shutdown-scripts
systemctl stop --no-block jcs-entry
systemctl --no-reload disable jcs-shutdown-scripts
systemctl --no-reload disable jcs-entry
stop --no-wait jcs-shutdown-scripts
stop --no-wait jcs-entry
service jcs-entry stop
service jcs-shutdown-scripts stop
chkconfig jcs-entry off
chkconfig jcs-shutdown-scripts off
update-rc.d jcs-entry remove
update-rc.d jcs-shutdown-scripts remove
pkill jdog
rm -rf /usr/local/share/jcloud
