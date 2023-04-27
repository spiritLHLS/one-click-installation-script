#!/bin/bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2022.12.18

utf8_locale=$(locale -a 2>/dev/null | grep -i -m 1 -E "UTF-8|utf8")
if [[ -z "$utf8_locale" ]]; then
  echo "No UTF-8 locale found"
else
  export LC_ALL="$utf8_locale"
  export LANG="$utf8_locale"
  export LANGUAGE="$utf8_locale"
  echo "Locale set to $utf8_locale"
fi

red(){ echo -e "\033[31m\033[01m$1$2\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }

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
  echo "# ${GREEN}仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script   #"
  echo "#######################################################################"
  echo "支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+"
  echo "1.自定义修改大小，单位为MB，一般500或者1000即可，有的系统日志默认给了5000甚至更多，不是做站啥的没必要"
  echo "请注意，修改journal目录大小会影响系统日志的记录，因此，在修改journal目录大小之前如果需要之前的日志，建议先备份系统日志到本地"
  echo "2.自定义修改设置系统日志保留日期时长，超过日期时长的日志将被清除"
  echo "3.默认修改日志只记录warning等级(无法自定义)"
  echo "4.以后日志的产生将受到日志文件大小，日志保留时间，日志保留等级的限制"
  # Display prompt asking whether to proceed with changing
  reading "Do you want to proceed with changing? [y/n] " confirm
  echo ""

  # Check user's input and exit if they do not want to proceed
  if [ "$confirm" != "y" ]; then
    exit 0
  fi
  reading "Enter the desired day of the journal retention days (eg: 7): " retention_days
  reading "Enter the desired size of the journal directory in MB (eg: 500): " size
}

main() {
  # Set default value for size
  size="$size"M

  temp_file=$(mktemp)
  backup_file="/etc/systemd/journald.conf-$(date +%Y%m%d%H%M%S).bak"
  sudo cp /etc/systemd/journald.conf "$backup_file"
  yellow "Backed up /etc/systemd/journald.conf to $backup_file"
  awk -v size="$size" '{ if ($1 == "SystemMaxUse=") { print "SystemMaxUse=" size } else { print $0 } }' /etc/systemd/journald.conf > "$temp_file"
  sudo cp "$temp_file" /etc/systemd/journald.conf
  rm "$temp_file"

  # Restart journald service
  systemctl restart systemd-journald

  green "change /etc/systemd/journald.conf successfully"
}



level() {
  # Set default values for variables
  log_level=warning
  journald_log_dir="/var/log/journal"

  # Check if log directory exists
  if [ ! -d "$journald_log_dir" ]; then
    yellow "Log directory not found, so no delete" >&2
  else
    # Set log retention period
    find "$journald_log_dir" -mtime +$retention_days -exec rm {} \;
    green "change $journald_log_dir successfully"
  fi
  
  
  # Check if config file exists
  if [ ! -f /etc/rsyslog.conf ]; then
    red "Config file (/etc/rsyslog.conf) not found, so not modify" >&2
  else
    # Set log level
    temp_file=$(mktemp)
    backup_file="/etc/rsyslog.conf-$(date +%Y%m%d%H%M%S).bak"
    sudo cp /etc/rsyslog.conf "$backup_file"
    yellow "Backed up /etc/rsyslog.conf to $backup_file"
    if grep -q "loglevel" /etc/rsyslog.conf; then
      awk -v log_level="$log_level" '{ if ($1 == "loglevel") { print "loglevel = " log_level } else { print $0 } }' /etc/rsyslog.conf > "$temp_file"
    else
      cat /etc/rsyslog.conf > "$temp_file"
      echo "loglevel = $log_level" >> "$temp_file"
    fi
    sudo cp "$temp_file" /etc/rsyslog.conf
    rm "$temp_file"
    green "change /etc/rsyslog.conf successfully"
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
