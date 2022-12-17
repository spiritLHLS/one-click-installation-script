#!/bin/bash

head() {
  # 支持系统：Ubuntu 12+，Debian 6+
  ver="2022.12.17"
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
  read -p "Enter the desired size of the journal directory in MB: " JOURNAL_SIZE_MB

  # Convert the size from MB to bytes
  JOURNAL_SIZE=$((JOURNAL_SIZE_MB * 1024 * 1024))

  # Set the path to the journal directory
  JOURNAL_DIR="/var/log/journal"

  # Set the name of the log recording service
  LOG_SERVICE="systemd-journald"

  # Try setting the size of the journal directory with systemd-journal-size
  if command -v systemd-journal-size &> /dev/null; then
    systemd-journal-size --disk-space=$JOURNAL_SIZE
    if [ $? -ne 0 ]; then
      echo "Failed to set journal size using systemd-journal-size"
    else
      success=true
    fi
  fi

  # If the previous method failed, try setting the size with journalctl
  if ! $success && command -v journalctl &> /dev/null; then
    journalctl --disk-space=$JOURNAL_SIZE
    if [ $? -ne 0 ]; then
      echo "Failed to set journal size using journalctl"
    else
      success=true
    fi
  fi
  
  
  # If the previous methods failed, try setting the size in journald.conf
  if ! $success && [ -f /etc/systemd/journald.conf ]; then
    # Check if the file is writable
    if [ ! -w /etc/systemd/journald.conf ]; then
      # If the file is not writable, try changing its permissions
      chmod +w /etc/systemd/journald.conf
      if [ $? -ne 0 ]; then
        echo "Failed to change permissions of journald.conf"
        continue
      fi
    fi

    # Check if the line containing SystemMaxUse is commented out
    if grep -q '^#\s*SystemMaxUse=' /etc/systemd/journald.conf; then
      # If it is commented out, uncomment it
      sed -i "s/^#\s*SystemMaxUse=.*/SystemMaxUse=$JOURNAL_SIZE/g" /etc/systemd/journald.conf
    else
      # If it is not commented out, just update the value
      sed -i "s/^SystemMaxUse=.*/SystemMaxUse=$JOURNAL_SIZE/g" /etc/systemd/journald.conf
    fi
    if [ $? -ne 0 ]; then
      echo "Failed to set journal size using journald.conf"
    else
      success=true
    fi

    # Restore the original permissions of the file
    chmod -w /etc/systemd/journald.conf
    if [ $? -ne 0 ]; then
      echo "Failed to restore permissions of journald.conf"
    fi
  fi

  # Restart the log recording service to force log rotation
  systemctl restart systemd-journald
  if [ $? -ne 0 ]; then
      systemctl restart rsyslog
  fi
  
  
  # Loop for 10 seconds, printing journald disk usage every second
  count=0
  while [ $count -lt 10 ]; do
    journalctl --disk-usage
    count=$((count+1))
    sleep 1
  done
  
}


head
main
