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
  echo "支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
  echo "1.自定义修改大小，单位为MB，一般500或者1000即可，有的系统日志默认给了5000甚至更多，不是做站啥的没必要"
  echo "请注意，修改journal目录大小可能会影响系统日志的记录。因此，在修改 journal 目录大小之前，建议先备份系统日志到本地"
  echo "2.运行脚本同时设置系统日志保留日期时长，超过日期时长的日志将被清除"
  echo "3.同时修改日志只记录warning等级"
  echo "4.以后日志的产生将受到日志文件大小，日志保留时间，日志保留等级的限制"
  # Display prompt asking whether to proceed with changing
  reading "Do you want to proceed with changing? [y/n] " confirm
  echo ""

  # Check user's input and exit if they do not want to proceed
  if [ "$confirm" != "y" ]; then
    exit 0
  fi
  
  reading "Enter the desired day of the journal retention days(eg: 7): " retention_days
  reading "Enter the desired size of the journal directory in MB (eg: 500): " size
}

red(){ echo -e "\033[31m\033[01m$1$2\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }

main() {

  # Set default value for size
  size="$size"M

  sed -i "s/^\(#\)\{0,1\}SystemMaxUse=.*/SystemMaxUse=$size/" /etc/systemd/journald.conf

  # Restart journald service
  systemctl restart systemd-journald
}


level() {
  # Set default values for variables
  log_level=warning
  journald_log_dir="/var/log/journal"

  # Check if log directory exists
  if [ ! -d "$journald_log_dir" ]; then
    echo "Log directory not found, so not delete" >&2
    exit 1
  fi

  # Set log retention period
  find "$journald_log_dir" -mtime +$retention_days -exec rm {} \;

  # Check if config file exists
  if [ ! -f /etc/rsyslog.conf ]; then
    echo "Config file (/etc/rsyslog.conf) not found, so not modify" >&2
    exit 1
  fi

  # Set log level
  if grep -q "loglevel" /etc/rsyslog.conf; then  # Add this line
    sed -i "s/^\(#\)\{0,1\}loglevel = .*/loglevel = $log_level/" /etc/rsyslog.conf
  else  # Add this block
    echo "loglevel = $log_level" >> /etc/rsyslog.conf
  fi
}

check_again() {
  # Loop for 5 seconds, printing journald disk usage every second
  count=0
  while [ $count -lt 5 ]; do
    journalctl --disk-usage
    count=$((count+1))
    sleep 1
  done

}


head
main
level
check_again
