### 一键修复脚本

一键尝试修复apt源 

- 支持系统：Ubuntu 12+，Debian 6+
- 修复apt源broken损坏
- 修复apt源锁死
- 修复apt源公钥缺失
- 修复替换系统可用的apt源列表，国内用阿里源，国外用官方源

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/package.sh -o package.sh && chmod +x package.sh && bash package.sh
```

一键尝试修复网络(nameserver和网络优先级) 

- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/network.sh -o network.sh && chmod +x network.sh && bash network.sh
```

一键尝试修复系统时间 

- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+

```
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/modify_time.sh -o modify_time.sh && chmod +x modify_time.sh && bash modify_time.sh
```

### 一键环境安装脚本

一键安装rust环境 

- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/rust.sh -o rust.sh && chmod +x rust.sh && bash rust.sh 
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
