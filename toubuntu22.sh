#!/bin/bash
#from https://github.com/spiritLHLS/one-click-installation-script

version=$(lsb_release -r | awk '{print $2}')
if [ "$version" != "22" ]; then
  apt-get update
  apt-get upgrade -y
  do-release-upgrade
  sed -i 's/Prompt=lts/Prompt=normal/g' /etc/update-manager/release-upgrades
  do-release-upgrade -d
fi
