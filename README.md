# 一键安装环境

一键安装rust

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/rust.sh -o rust.sh && chmod +x rust.sh && bash rust.sh 
```

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
