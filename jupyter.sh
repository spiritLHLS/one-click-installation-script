#!/usr/bin/env bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2022.12.18

red(){ echo -e "\033[31m\033[01m$1$2\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }

ver="2022.12.18"
changeLog="一键安装jupyter环境"
clear
echo "#######################################################################"
echo "#                     ${YELLOW}一键安装jupyter环境${PLAIN}                             #"
echo "# 版本：$ver                                                    #"
echo "# 更新日志：$changeLog                                       #"
echo "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
echo "# ${GREEN}作仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script #"
echo "#######################################################################"
echo "支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+"
echo "有安装则提示是否需要修改用户名和密码，否则则自动安装，自动安装后默认用户名和密码都是spiritlhl，如果安装完毕需要修改，再次执行本脚本修改"
echo "最后都会打印jupyter的信息，如果本机最后有jupyter的话，无论是通过何种途径安装的"

install_jupyter() {
  # Update package manager and install required packages
  if command -v apt-get &> /dev/null; then
      sudo apt-get update
      sudo apt-get install -y python3 python3-pip python3-dev build-essential libssl-dev libffi-dev
  elif command -v dnf &> /dev/null; then
      sudo dnf update
      sudo dnf install -y python3 python3-pip python3-devel openssl-devel libffi-devel
  elif command -v yum &> /dev/null; then
      sudo yum update
      sudo yum install -y python3 python3-pip python3-devel openssl-devel libffi-devel
  elif command -v zypper &> /dev/null; then
      sudo zypper update
      sudo zypper install -y python3 python3-pip python3-devel openssl-devel libffi-devel
  fi

  # Install virtualenv
  pip3 install --upgrade virtualenv

  # Create virtual environment for Jupyter Notebook
  virtualenv jupyter-env

  # Activate the virtual environment
  source jupyter-env/bin/activate

  # Install Jupyter Notebook and Jupyter Lab
  pip3 install jupyter jupyterlab

  # Add Jupyter Notebook to PATH
  echo 'export PATH="$PATH:$(python3 -m site --user-base)/bin"' >> ~/.bashrc
  source ~/.bashrc

  # Generate a config file for Jupyter Notebook
  jupyter notebook --generate-config

  # Copy the config file to jupyter_server_config.py
  cp ~/.jupyter/jupyter_notebook_config.py ~/.jupyter/jupyter_server_config.py

  # Set username and password for Jupyter Notebook
  echo "c.NotebookApp.password = 'spiritlhl'" >> ~/.jupyter/jupyter_server_config.py
  echo "c.NotebookApp.username = 'spiritlhl'" >> ~/.jupyter/jupyter_server_config.py

  # Open port 13692 in firewall
  if command -v ufw &> /dev/null; then
      sudo ufw allow 13692/tcp
  elif command -v firewall-cmd &> /dev/null; then
      sudo firewall-cmd --add-port=13692/tcp --permanent
      sudo firewall-cmd --reload
  fi

  # Start Jupyter Notebook with port 13692
  jupyter lab --port 13692 --no-browser

}

change_username_and_password() {
  # Prompt the user for a new username and password
  reading "Enter a new username: " username
  reading "Enter a new password: " password

  # Check if Python 3 is available
  if command -v python3 &> /dev/null; then
    # Python 3 is installed, use it
    password_hash=$(python3 -c "from notebook.auth import passwd; print(passwd('$password'))")
  else
    # Python 3 is not installed, use Python 2
    password_hash=$(python -c "from notebook.auth import passwd; print(passwd('$password'))")
  fi

  # Find the jupyter configuration file
  config_file=$(jupyter --config-dir)/jupyter_notebook_config.py
  if [ ! -f "$config_file" ]; then
    jupyter notebook --generate-config
  fi

  # Update the jupyter configuration file with the new username and password hash
  sed -i "s/#c.NotebookApp.password = .*/c.NotebookApp.password = u'$password_hash'/" "$config_file"
  sed -i "s/#c.NotebookApp.username = .*/c.NotebookApp.username = u'$username'/" "$config_file"
}

query_jupyter_info() {
  # Check if jupyter is installed
  if jupyter --version &> /dev/null; then
    echo "Error: Jupyter is not installed on this system."
    return 1
  fi

  # Check if jupyter_notebook_config.py exists
  if [ ! -f ~/.jupyter/jupyter_notebook_config.py ]; then
    echo "Error: jupyter_notebook_config.py not found."
    return 1
  fi

  # Read jupyter_notebook_config.py
  config=$(cat ~/.jupyter/jupyter_notebook_config.py)

  # Extract username and password
  password_required=$(echo "$config" | grep "c.NotebookApp.password_required" | awk -F "=" '{print $2}' | tr -d ' ')
  if [ "$password_required" = "True" ]; then
    username=$(echo "$config" | grep "c.NotebookApp.password" | awk -F "=" '{print $2}' | tr -d ' ' | base64 --decode | awk -F ":" '{print $1}')
    password=$(echo "$config" | grep "c.NotebookApp.password" | awk -F "=" '{print $2}' | tr -d ' ' | base64 --decode | awk -F ":" '{print $2}')
    echo "Username: $username"
    echo "Password: $password"
  else
    echo "Jupyter Notebook server is not password protected."
  fi

  # Extract port
  port=$(echo "$config" | grep "c.NotebookApp.port" | awk -F "=" '{print $2}' | tr -d ' ')
  echo "Port: $port"
}



main() {
  # Check if jupyter is installed
  if jupyter --version &> /dev/null; then
    echo "Jupyter is already installed on this system."
    reading "Do you want to change the username and password for Jupyter? (y/n) " change
    echo ""

    # Check user's input and exit if they do not want to proceed
    if [ "$change" != "y" ]; then
      exit 0
    fi
    
    change_username_and_password
    
  else
    reading "Jupyter is not installed on this system. Do you want to install it? (y/n) " confirminstall
    echo ""

    # Check user's input and exit if they do not want to proceed
    if [ "$confirminstall" != "y" ]; then
      exit 0
    fi
    
    install_jupyter
    
  fi
  
  # Print the current info for Jupyter
  echo "The current info for Jupyter:"
  query_jupyter_info
}

main
