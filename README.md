# one-click-script

如果脚本有任何问题或者任何修复系统的需求，可在issues中提出，有空会解决或者回答

## 一键修复脚本

运行所有一键修复脚本前注意看说明，以及保证服务器无重要数据，运行后造成的一切后果作者不负任何责任，自行评判风险！

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

#### 一键尝试修复网络

**该脚本轻易勿要使用，请确保运行时服务器无重要文件或程序，出现运行bug后续可能需要重装系统**

**一定要在screen中执行该脚本，否则可能导致修改过程中ssh断链接而修改失败卡住最终SSH无法连接！不在screen中执行后果自负！**
- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
- 尝试修复nameserver为google源或cloudflare源
- 尝试修复为IP类型对应的网络优先级(默认IPV4类型，纯V6类型再替换为IPV6类型)

```bash
curl -L https://cdn.spiritlhl.workers.dev/https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/network.sh -o network.sh && chmod +x network.sh && bash network.sh
```

如果是纯V6的也可以不使用上面脚本的nat64，使用warp添加V4网络

比如：https://github.com/fscarmen/warp

```bash
wget -N https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh && bash menu.sh [option] [lisence]
```

## 一键环境安装脚本

只推荐在新服务器上安装，环境不纯净不保证不出bug

#### 一键安装jupyter环境 

- **本脚本尝试使用Miniconda3安装虚拟环境jupyter-env再进行jupyter和jupyterlab的安装，如若安装机器不纯净勿要轻易使用本脚本！**
- **本脚本为实验性脚本可能会有各种bug，勿要轻易尝试！**
- **安装前需要保证 sudo wget curl 已安装**
- 验证已支持的系统：
  - Ubuntu 18/20/22 - 推荐，脚本自动挂起到后台
  - Debian 9/10/11 - 还行，需要手动挂起到后台，详看脚本运行安装完毕的后续提示
- 可能支持的系统(未验证)：centos 7+，Fedora，Almalinux 8.5+
- 执行脚本，之前有用本脚本安装过则直接打印设置的登陆信息，没安装过则进行安装再打印信息，如果已安装但未启动则自动启动后再打印信息
- 如果是初次安装无脑输入y回车即可，按照提示进行操作即可，安装完毕将在后台常驻运行
- 安装完毕后，如果需要在lab中安装第三方库需要在lab中使用terminal并使用conda进行下载而不是pip下载，这是需要注意的

原始用途是方便快捷的在按小时计费的超大型服务器上部署python环境进行科学计算，充分利用时间别浪费在构建环境上。

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/jupyter.sh -o jupyter.sh && chmod +x jupyter.sh && bash jupyter.sh
```

安装后记得开放 13692 端口

```bash
apt install ufw -y
ufw allow 13692
```

#### 一键安装rust环境 

- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
- 加载官方脚本安装，前置条件适配系统以及后置条件判断安装的版本

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/rust.sh -o rust.sh && chmod +x rust.sh && bash rust.sh 
```

#### 一键安装C++环境 

- 支持系统：使用apt或者yum作为包管理器的系统
- 如果未安装则安装，如果有安装则提示升级

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/cplusplus.sh -o cplusplus.sh && chmod +x cplusplus.sh && bash cplusplus.sh 
```

#### 一键安装vnstat环境

- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
- 加载官方文件编译安装，前置条件适配系统以及后置条件判断安装的版本

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/vnstat.sh -o vnstat.sh && chmod +x vnstat.sh && bash vnstat.sh 
```

## 部分手动命令

### 一键屏蔽邮件端口避免被恶意程序使用

```bash
iptables -A INPUT -p tcp --dport 25 -j DROP
iptables -A OUTPUT -p tcp --dport 25 -j DROP
/sbin/iptables-save
```

### 设置语言包

```bash
sudo apt-get update
sudo apt-get install language-pack-en-base
sudo locale-gen en_US.UTF-8
```
下载UTF-8的环境，生成UTF-8的包，然后重启服务器
```bash
locale -a
export LC_ALL=en_US.UTF-8
```
查看并设置语言包(乌班图系统)

### ubuntu缺失公钥

```bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 公钥
```

### ubuntu更新源被锁

```bash
sudo rm -rf /var/cache/apt/archives/lock
```

或查看下文

https://itsfoss.com/fix-ubuntu-install-error/

### debian缺失公钥

```bash
apt-get install debian-keyring debian-archive-keyring
```

### centos换源

```bash
sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
sudo sed -i 's/^mirrorlist=http/mirrorlist=https/' /etc/yum.repos.d/CentOS-Base.repo
```

## 友链

#### 一键测试服务器的融合怪脚本

https://github.com/spiritLHLS/ecs

#### 一键批量开NAT服务器(LXC)

https://github.com/spiritLHLS/lxc

#### 朋友 fscarmen 的常用一键工具仓库

https://github.com/fscarmen/tools
