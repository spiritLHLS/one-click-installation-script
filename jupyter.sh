#!/usr/bin/env bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2022.12.18

source ~/.bashrc

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
red "本脚本尝试使用Miniconda3安装虚拟环境jupyter-env再进行jupyter和jupyterlab的安装，如若安装机器不纯洁勿要使用本脚本！"
echo "执行脚本，之前有安装过则打印设置的登陆信息，没安装过则进行安装再打印信息"
echo "如果是初次安装无脑输入yes或y回车即可"


install_jupyter() {
  rm -rf Miniconda3-latest-Linux-x86_64.sh*
  
  # Check if conda is already installed
  if ! command -v conda &> /dev/null; then
    # Install conda
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -u
    # added by Miniconda3 installer
    echo 'export PATH="$PATH:$HOME/miniconda3/bin:$HOME/miniconda3/condabin"' >> ~/.bashrc
    echo 'export PATH="$PATH:$HOME/.local/share/jupyter"' >> ~/.bashrc
    source ~/.bashrc
    sleep 1
    echo 'export PATH="/home/user/miniconda3/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    sleep 1
    # Add the necessary paths to your search path
    export PATH="/home/user/miniconda3/bin:$PATH"
    green "请关闭本窗口开一个新窗口再执行本脚本，否则无法加载一些预设的环境变量" && exit 0
  fi
  
  green "加载预设的conda环境变量成功，准备安装jupyter，无脑输入y和回车即可"
  
  # Create a new conda environment and install jupyter
  conda create -n jupyter-env python=3
  source activate jupyter-env
  conda install jupyter jupyterlab

  # Add the following line to /etc/profile
  echo 'export PATH="$PATH:~/.local/share/jupyter"' >> /etc/profile
  # Execute the configuration
  source /etc/profile

  # Set username and password for Jupyter Server
  # jupyter notebook --generate-config
  # cp ~/.jupyter/jupyter_notebook_config.py ~/.jupyter/jupyter_server_config.py
  jupyter server --generate-config
  # echo "c.ServerApp.password = 'spiritlhl'" >> ~/.jupyter/jupyter_server_config.py
  # echo "c.ServerApp.username = 'spiritlhl'" >> ~/.jupyter/jupyter_server_config.py

  # Open port 13692 in firewall
  if command -v ufw &> /dev/null; then
      sudo ufw allow 13692/tcp
  elif command -v firewall-cmd &> /dev/null; then
      sudo firewall-cmd --add-port=13692/tcp --permanent
      sudo firewall-cmd --reload
  fi

  # Start Jupyter Server with port 13692 and host 0.0.0.0
  nohup jupyter lab --port 13692 --no-browser --ip=0.0.0.0 --allow-root & echo $!
  sleep 5
  cat nohup.out
  
  # Add the specified paths to the PATH variable
  paths="./miniconda3/envs/jupyter-env/etc/jupyter:./miniconda3/envs/jupyter-env/bin/jupyter:./miniconda3/envs/jupyter-env/share/jupyter"
  export PATH="$paths:$PATH"

  # Remove duplicate paths from the PATH variable
  new_path=$(echo "$PATH" | tr ':' '\n' | awk '!x[$0]++' | tr '\n' ':')
  export PATH="$new_path"

  # Refresh the current shell
  source ~/.bashrc
  
  green "已安装jupyter lab的web端到外网端口13692上，请打开你的 外网IP:13692"
  green "同时已保存日志输出到当前目录的nohup.out中且已打印5秒日志如上"
  green "如果需要进一步查询，请关闭本窗口开一个新窗口再执行本脚本，否则无法加载一些预设的环境变量" && exit 0
}

query_jupyter_info() {
  source activate jupyter-env
  # Check if jupyter is installed
  if ! jupyter --version &> /dev/null; then
    echo "Error: Jupyter is not installed on this system."
    return 1
  fi

  # Find jupyter config directory
  config_dir=$(jupyter --config-dir)
  config_path="$config_dir/jupyter_server_config.py"

  # Check if jupyter_server_config.py exists
  if [ ! -f "$config_path" ]; then
    echo "Error: jupyter_server_config.py not found."
    return 1
  fi

  # Read jupyter_server_config.py
  config=$(cat "$config_path")

  # Extract token
  # token=$(echo "$config" | grep "c.ServerApp.token" | awk -F "=" '{print $2}' | tr -d ' ')
  token=$(echo "$config" | grep "c.IdentityProvider.token" | awk -F "=" '{print $2}' | tr -d ' ')
  if [ -z "$token" ]; then
    echo "Error: Token not found in jupyter_server_config.py."
    return 1
  fi
  echo "Token: $token"

  # Extract port
  port=$(echo "$config" | grep "c.ServerApp.port" | awk -F "=" '{print $2}' | tr -d ' ')
  echo "Port: $port"
}

main() {
  source activate jupyter-env
  # Check if jupyter is installed
  if jupyter --version &> /dev/null; then
    green "Jupyter is already installed on this system."
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
