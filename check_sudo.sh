#!/bin/bash

# Check if the hostname is set correctly in /etc/hosts
HOSTNAME=$(cat /etc/hostname)
HOSTS_LINE="$(grep $HOSTNAME /etc/hosts)"

if [ -z "$HOSTS_LINE" ]; then
  # Hostname not found in /etc/hosts. Add it.
  echo "Updating /etc/hosts with hostname: $HOSTNAME"
  sudo bash -c "echo '127.0.0.1 $HOSTNAME' >> /etc/hosts"
else
  # Hostname found in /etc/hosts. Check if the IP address is correct.
  HOSTS_IP="$(awk '{print $1}' <<<$HOSTS_LINE)"
  if [ "$HOSTS_IP" != "127.0.0.1" ]; then
    # IP address is incorrect. Update it.
    echo "Updating IP address for $HOSTNAME in /etc/hosts"
    sudo sed -i "s/$HOSTS_IP/127.0.0.1/g" /etc/hosts
  else
    # Hostname and IP address are correct. No changes needed.
    echo "Hostname and IP address in /etc/hosts are correct."
  fi
fi

# Check if the sudo command works
sudo echo "Testing sudo command..."
if [ $? -eq 0 ]; then
  # Sudo command works. Exit the script.
  echo "Fix successful. Exiting script."
else
  # Sudo command failed. Try restarting the networking interface.
  echo "Sudo command still failing. Restarting networking interface."
  sudo service networking restart

  # Check if the sudo command works after restarting the networking interface
  sudo echo "Testing sudo command after restarting networking interface..."
  if [ $? -eq 0 ]; then
    # Sudo command works. Exit the script.
    echo "Fix successful. Exiting script."
  else
    # Sudo command failed. Try restarting the DNS server.
    echo "Sudo command still failing. Restarting DNS server."
    sudo service bind9 restart

    # Check if the sudo command works after restarting the DNS server
    sudo echo "Testing sudo command after restarting DNS server..."
    if [ $? -eq 0 ]; then
      # Sudo command works. Exit the script.
      echo "Fix successful. Exiting script."
    else
      # Sudo command still failing. Exiting script.
      echo "Unable to fix problem. Exiting script."
    fi
  fi
fi
