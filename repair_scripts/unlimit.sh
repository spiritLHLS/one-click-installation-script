#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2024.06.20

# 更新 /etc/security/limits.conf 文件
echo "更新 /etc/security/limits.conf 文件..."
sed -i '/^root soft nofile /d' /etc/security/limits.conf
sed -i '/^root hard nofile /d' /etc/security/limits.conf
sed -i '/^\* soft nofile /d' /etc/security/limits.conf
sed -i '/^\* hard nofile /d' /etc/security/limits.conf
echo "root soft nofile 1000000" >> /etc/security/limits.conf
echo "root hard nofile 1000000" >> /etc/security/limits.conf
echo "* soft nofile 1000000" >> /etc/security/limits.conf
echo "* hard nofile 1000000" >> /etc/security/limits.conf

# 更新 /etc/pam.d/common-session 文件
echo "更新 /etc/pam.d/common-session 文件..."
if ! grep -q "session required pam_limits.so" /etc/pam.d/common-session; then
  echo "session required pam_limits.so" >> /etc/pam.d/common-session
fi

# 更新 /etc/pam.d/common-session-noninteractive 文件
echo "更新 /etc/pam.d/common-session-noninteractive 文件..."
if ! grep -q "session required pam_limits.so" /etc/pam.d/common-session-noninteractive; then
  echo "session required pam_limits.so" >> /etc/pam.d/common-session-noninteractive
fi

# 更新 /etc/systemd/system.conf 文件
echo "更新 /etc/systemd/system.conf 文件..."
sed -i '/^DefaultLimitNOFILE=/d' /etc/systemd/system.conf
echo "DefaultLimitNOFILE=1000000" >> /etc/systemd/system.conf

# 更新 /etc/systemd/user.conf 文件
echo "更新 /etc/systemd/user.conf 文件..."
sed -i '/^DefaultLimitNOFILE=/d' /etc/systemd/user.conf
echo "DefaultLimitNOFILE=1000000" >> /etc/systemd/user.conf

sleep 1

systemctl daemon-reload
echo "请重启服务器使得修改生效"
