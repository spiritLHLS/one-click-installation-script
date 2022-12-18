#!/bin/bash

head() {
  # 支持系统：Ubuntu 12+，Debian 6+
  ver="2022.12.18"
  changeLog="一键修改journal日志记录大小，释放系统盘空间"
  clear
  echo "#######################################################################"
  echo "#                     ${YELLOW}一键修改journal大小脚本${PLAIN}                         #"
  echo "# 版本：$ver                                                    #"
  echo "# 更新日志：$changeLog               #"
  echo "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
  echo "# ${GREEN}作仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script #"
  echo "#######################################################################"
  echo "支持系统：Ubuntu 12+，Debian 6+"
  echo "自定义修改大小，单位为MB，一般500M或者1G即可，有的系统日志默认给了5G甚至更多，不是做站啥的没必要"
  echo "请注意，修改journal目录大小可能会影响系统日志的记录。因此，在修改 journal 目录大小之前，建议先备份系统日志到本地"
  # Display prompt asking whether to proceed with changing
  read -p "Do you want to proceed with changing? [y/n] " -n 1 confirm
  echo ""

  # Check user's input and exit if they do not want to proceed
  if [ "$confirm" != "y" ]; then
    exit 0
  fi
}

main() {
  # Prompt the user for the desired size of the journal directory in MB
  read -p "Enter the desired size of the journal directory in MB (eg: 500): " size

  # Set default value for size
  size="$size"M

  # Check system type
  if [ -f /etc/lsb-release ]; then
    # Ubuntu
    sed -i "s/SystemMaxUse=.*/SystemMaxUse=$size/" /etc/systemd/journald.conf
  elif [ -f /etc/redhat-release ]; then
    # CentOS
    sed -i "s/SystemMaxUse=.*/SystemMaxUse=$size/" /etc/systemd/journald.conf
  elif [ -f /etc/debian_version ]; then
    # Debian
    sed -i "s/SystemMaxUse=.*/SystemMaxUse=$size/" /etc/systemd/journald.conf
  else
    echo "Unsupported system type" >&2
    exit 1
  fi

  # Restart journald service
  systemctl restart systemd-journald
  
  
  # Loop for 10 seconds, printing journald disk usage every second
  count=0
  while [ $count -lt 10 ]; do
    journalctl --disk-usage
    count=$((count+1))
    sleep 1
  done
  
}

level() {
  # Set default values for variables
  retention_days=7
  log_level=warning

  # Check if log directory exists
  if [ ! -d /var/log ]; then
    echo "Log directory not found" >&2
    exit 1
  fi

  # Set log retention period
  find /var/log -mtime +$retention_days -exec rm {} \;

  # Check if config file exists
  if [ ! -f /etc/rsyslog.conf ]; then
    echo "Config file not found" >&2
    exit 1
  fi

  # Set log level
  sed -i "s/loglevel = .*/loglevel = $log_level/" /etc/rsyslog.conf


}


head
main
level
