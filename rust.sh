#!/usr/bin/env bash
# 暂时只支持ubuntu
ver="2022.12.08"
changeLog="一键安装rust，加载官方脚本"
clear
echo "#############################################################"
echo -e "#                     ${YELLOW}融合怪测评脚本${PLAIN}                        #"
echo "# 版本：$ver                                          #"
echo "# 更新日志：$changeLog                    #"
echo -e "# ${GREEN}作者${PLAIN}: spiritlhl                                           #"
echo "#############################################################"
echo ""
sudo apt update -y
sudo apt upgrade -y
sudo apt install curl build-essential gcc make -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
source "$HOME/.profile"
echo "更新RUST"
rustup update
echo "打印编译管理器，编译器，文档工具版本，如果有误则安装失败"
cargo --version
rustc --version
rustdoc --version
