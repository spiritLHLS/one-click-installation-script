### 一键修复脚本

#### 一键尝试修复apt源 

- 支持系统：Ubuntu 12+，Debian 6+
- 修复apt源broken损坏
- 修复apt源锁死
- 修复apt源公钥缺失
- 修复替换系统可用的apt源列表，国内用阿里源，国外用官方源
- 修复本机的Ubuntu系统是EOL非长期维护的版本(奇数或陈旧的偶数版本)，将替换为Ubuntu官方的old-releases仓库以支持apt的使用

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/package.sh -o package.sh && chmod +x package.sh && bash package.sh
```

#### 一键尝试修复网络

- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
- 尝试修复nameserver为google源或cloudflare源
- 尝试修复为IP类型对应的网络优先级(默认IPV4类型，纯V6类型再替换为IPV6类型)

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/network.sh -o network.sh && chmod +x network.sh && bash network.sh
```

#### 一键尝试修复系统时间 

- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
- 检测修复本机系统时间，对应时区时间，如果相差超过300秒的合理范围则校准时间

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/modify_time.sh -o modify_time.sh && chmod +x modify_time.sh && bash modify_time.sh
```

#### 一键尝试修复```sudo: unable to resolve host xxx: Name or service not known```警告(爆错)

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/check_sudo.sh -o check_sudo.sh && chmod +x check_sudo.sh && bash check_sudo.sh
```

#### 一键修改系统自带的journal日志记录大小释放系统盘空间

- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
- 1.自定义修改大小，单位为MB，一般500或者1000即可，有的系统日志默认给了5000甚至更多，不是做站啥的没必要
- 请注意，修改journal目录大小会影响系统日志的记录，因此，在修改journal目录大小之前如果需要之前的日志，建议先备份系统日志到本地
- 2.自定义修改设置系统日志保留日期时长，超过日期时长的日志将被清除
- 3.默认修改日志只记录warning等级(无法自定义)
- 4.以后日志的产生将受到日志文件大小，日志保留时间，日志保留等级的限制

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/resize_journal.sh -o resize_journal.sh && chmod +x resize_journal.sh && bash resize_journal.sh
```

### 一键环境安装脚本

#### 一键安装rust环境 

- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/rust.sh -o rust.sh && chmod +x rust.sh && bash rust.sh 
```

### 部分手动命令

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
