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

  # If systemd-journal-size is not available, try setting the size with journalctl
  elif command -v journalctl &> /dev/null; then
    journalctl --disk-space=$JOURNAL_SIZE

  # If neither systemd-journal-size nor journalctl is available, try setting the size in journald.conf
  else
    sed -i "s/^SystemMaxUse=.*/SystemMaxUse=$JOURNAL_SIZE/g" /etc/systemd/journald.conf
  fi

  # Restart the log recording service to force log rotation
  systemctl restart $LOG_SERVICE

  # Print the size of the journal directory
  du -sh $JOURNAL_DIR
}


head
main
