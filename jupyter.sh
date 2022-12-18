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
echo "如果是初次安装无脑输入yes或y回车即可"


install_jupyter() {
  rm -rf Miniconda3-latest-Linux-x86_64.sh*
  
  # Check if conda is already installed
  if ! command -v conda &> /dev/null; then
      # Install conda
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -u
    # bash Miniconda3-latest-Linux-x86_64.sh

    # Add conda to PATH
    echo 'export PATH="$PATH:$HOME/miniconda3/bin:$HOME/miniconda3/condabin"' >> ~/.bashrc
    echo 'export PATH="$PATH:$HOME/.local/share/jupyter"' >> ~/.bashrc
    source ~/.bashrc
  fi

  # Create a new conda environment and install jupyter
  conda create -n jupyter-env python=3
  source activate jupyter-env
  conda install jupyter jupyterlab
  
  # Add the following line to /etc/profile
  echo 'export PATH="$PATH:~/.local/share/jupyter"' >> /etc/profile
  # Execute the configuration
  source /etc/profile
  
  # Set username and password for Jupyter Notebook
  jupyter notebook --generate-config
  cp ~/.jupyter/jupyter_notebook_config.py ~/.jupyter/jupyter_server_config.py
  echo "c.NotebookApp.password = 'spiritlhl'" >> ~/.jupyter/jupyter_server_config.py
  echo "c.NotebookApp.username = 'spiritlhl'" >> ~/.jupyter/jupyter_server_config.py

  # Open port 13692 in firewall
  if command -v ufw &> /dev/null; then
      sudo ufw allow 13692/tcp
  elif command -v firewall-cmd &> /dev/null; then
      sudo firewall-cmd --add-port=13692/tcp --permanent
      sudo firewall-cmd --reload
  fi

  # Start Jupyter Notebook with port 13692 and host 0.0.0.0
  jupyter lab --port 13692 --no-browser --ip=0.0.0.0


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

uninstall_jupyter() {
  # Deactivate the virtual environment
  deactivate

  # Remove the virtual environment
  rm -rf jupyter-env

  # Uninstall Jupyter Notebook and Jupyter Lab
  pip3 uninstall jupyter jupyterlab

  # Remove Jupyter Notebook from PATH
  sed -i '/export PATH="$PATH:$(python3 -m site --user-base)\/bin"/d' ~/.bashrc
  source ~/.bashrc

  # Remove Jupyter Notebook config files
  rm -rf ~/.jupyter

  # Remove port 13692 from firewall
  if command -v ufw &> /dev/null; then
      sudo ufw delete allow 13692/tcp
  elif command -v firewall-cmd &> /dev/null; then
      sudo firewall-cmd --remove-port=13692/tcp --permanent
      sudo firewall-cmd --reload
  fi

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
