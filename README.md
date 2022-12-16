# 一键脚本

一键安装rust环境

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/rust.sh -o rust.sh && chmod +x rust.sh && bash rust.sh 
```

一键尝试修复apt源

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/package.sh -o package.sh && chmod +x package.sh && bash package.sh
```

一键尝试修复网络(nameserver和网络优先级)

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/network.sh -o network.sh && chmod +x network.sh && bash network.sh
```

### 手动命令

ubuntu缺失公钥

```bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 公钥
```

ubuntu更新源被锁

```bash
sudo rm -rf /var/cache/apt/archives/lock
```

或

https://itsfoss.com/fix-ubuntu-install-error/

debian缺失公钥

```bash
apt-get install debian-keyring debian-archive-keyring
```

centos换源

```bash
sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
sudo sed -i 's/^mirrorlist=http/mirrorlist=https/' /etc/yum.repos.d/CentOS-Base.repo
```
