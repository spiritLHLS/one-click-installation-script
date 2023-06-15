# 前言

如果脚本有任何问题或者任何修复系统的需求，可在issues中提出，有空会解决或者回答

所有脚本如需在国内服务器使用，请在链接前加上```https://ghproxy.com/```确保命令可以下载本仓库的shell脚本执行

# 目录

* [一键修复脚本](#一键修复脚本)
  * [一键尝试修复apt源](#一键尝试修复apt源)
  * [一键尝试修复系统时间](#一键尝试修复系统时间)
  * [一键尝试修复sudo警告](#一键尝试修复sudo警告)
  * [一键修改系统自带的journal日志记录大小释放系统盘空间](#一键修改系统自带的journal日志记录大小释放系统盘空间)
  * [一键尝试修复网络](#一键尝试修复网络)
* [一键环境安装脚本](#一键环境安装脚本)
  * [一键安装jupyter环境](#一键安装jupyter环境)
  * [一键安装R语言环境](#一键安装R语言环境)
  * [一键安装rust环境](#一键安装rust环境)
  * [一键安装C++环境](#一键安装C环境)
  * [一键安装vnstat环境](#一键安装vnstat环境)
  * [一键升级低版本debian为debian11](#一键升级低版本debian为debian11)
  * [一键升级低版本ubuntu为ubuntu22](#一键升级低版本ubuntu为ubuntu22)
  * [一键安装zipline平台](#一键安装zipline平台)
  * [一键安装filebrowser平台](#一键安装filebrowser平台)
  * [一键删除平台监控](#一键删除平台监控)
* [部分手动命令](#部分手动命令)
  * [一键开启root登陆并替换密码](#一键开启root登陆并替换密码)
  * [一键屏蔽邮件端口避免被恶意程序使用](#一键屏蔽邮件端口避免被恶意程序使用)
  * [设置语言包](#设置语言包)
  * [ubuntu更新源被锁](#ubuntu更新源被锁)
  * [debian缺失公钥](#debian缺失公钥)
  * [ubuntu或debian缺失公钥](#ubuntu或debian缺失公钥)
  * [centos换源](#centos换源)
  * [安装gitea](#安装gitea)
  * [卸载aapanel](#卸载aapanel)
  * [安装docker和docker-compose](#安装docker和docker-compose)
* [友链](#友链)
  * [一键测试服务器的融合怪脚本](#一键测试服务器的融合怪脚本)
  * [一键批量开NAT服务器LXC](#一键批量开NAT服务器LXC)
  * [一键安装PVE](#一键安装PVE)
  * [朋友fscarmen的常用一键工具仓库](#朋友fscarmen的常用一键工具仓库)
  
## 一键修复脚本

运行所有一键修复脚本前注意看说明，以及保证服务器无重要数据，运行后造成的一切后果作者不负任何责任，自行评判风险！

#### 一键尝试修复apt源 

- 支持系统：Ubuntu 12+，Debian 6+
- 修复apt下载包进程意外退出导致的源锁死
- 修复apt源broken损坏
- 修复apt源多进程占用锁死
- 修复apt源公钥缺失
- 修复替换系统可用的apt源列表，国内用阿里源，国外用官方源
- 修复本机的Ubuntu系统是EOL非长期维护的版本(奇数或陈旧的偶数版本)，将替换为Ubuntu官方的old-releases仓库以支持apt的使用
- 修复只保证```apt update```不会报错，其他命令报错未修复
- 如若修复后install还有问题，重启服务器解决问题

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/repair_scripts/package.sh -o package.sh && chmod +x package.sh && bash package.sh
```

#### 一键尝试修复系统时间 

- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
- 由于系统时间不准确都是未进行时区时间同步造成的，使用chronyd进行时区时间同步后应当解决了问题

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/repair_scripts/modify_time.sh -o modify_time.sh && chmod +x modify_time.sh && bash modify_time.sh
```

#### 一键尝试修复sudo警告

- 一键尝试修复```sudo: unable to resolve host xxx: Name or service not known```警告(爆错)

不要在生产环境上使用该脚本，否则容易造成网络hosts配置错误，配置的host名字不在外网IP上反而在内网IP(127.0.0.1)上

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/repair_scripts/check_sudo.sh -o check_sudo.sh && chmod +x check_sudo.sh && bash check_sudo.sh
```

#### 一键修改系统自带的journal日志记录大小释放系统盘空间

- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
- 1.自定义修改大小，单位为MB，一般500或者1000即可，有的系统日志默认给了5000甚至更多，不是做站啥的没必要
  - 请注意，修改journal目录大小会影响系统日志的记录，因此，在修改journal目录大小之前如果需要之前的日志，建议先备份系统日志到本地
- 2.自定义修改设置系统日志保留日期时长，超过日期时长的日志将被清除
- 3.默认修改日志只记录warning等级(无法自定义)
- 4.以后日志的产生将受到日志文件大小，日志保留时间，日志保留等级的限制

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/repair_scripts/resize_journal.sh -o resize_journal.sh && chmod +x resize_journal.sh && bash resize_journal.sh
```

#### 一键尝试修复网络

**该脚本轻易勿要使用，请确保运行时服务器无重要文件或程序，出现运行bug后续可能需要重装系统**

**一定要在screen中执行该脚本，否则可能导致修改过程中ssh断链接而修改失败卡住最终SSH无法连接！不在screen中执行后果自负！**
- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
- 尝试修复nameserver为google源或cloudflare源
- 尝试修复为IP类型对应的网络优先级(默认IPV4类型，纯V6类型再替换为IPV6类型)

```bash
curl -L https://cdn.spiritlhl.workers.dev/https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/repair_scripts/network.sh -o network.sh && chmod +x network.sh && bash network.sh
```

如果是纯V6的也可以不使用上面脚本的nat64，使用warp添加V4网络

比如：https://github.com/fscarmen/warp

```bash
wget -N https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh && bash menu.sh [option] [lisence]
```

非纯V6的，带V4切换优先级到IPV4可用以下命令

```bash
sudo sed -i 's/.*precedence ::ffff:0:0\/96.*/precedence ::ffff:0:0\/96  100/g' /etc/gai.conf && sudo systemctl restart networking
```

## 一键环境安装脚本

只推荐在新服务器上安装，环境不纯净不保证不出bug

运行所有一键环境安装脚本前注意看说明，以及保证服务器无重要数据，运行后造成的一切后果作者不负任何责任，自行评判风险！

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
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/install_scripts/jupyter.sh -o jupyter.sh && chmod +x jupyter.sh && bash jupyter.sh
```

安装后记得开放 13692 端口

```bash
apt install ufw -y
ufw allow 13692
```

#### 一键安装R语言环境

- **安装前需使用Miniconda3安装虚拟环境jupyter-env，然后进行jupyter和jupyterlab的安装，再然后才能安装本内核**
- **简单的说，需要执行本仓库对应的jupyter安装脚本再运行本脚本安装R语言环境，会自动安装R环境内核和图形设备支持库**
- x11可能需要手动启动一下，执行```sudo /usr/bin/Xorg```
- 可能支持的系统(未验证)：centos 7+，Fedora，Almalinux 8.5+

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/install_scripts/R.sh -o R.sh && chmod +x R.sh && bash R.sh
```

#### 一键安装rust环境 

- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
- 加载官方脚本安装，前置条件适配系统以及后置条件判断安装的版本

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/install_scripts/rust.sh -o rust.sh && chmod +x rust.sh && bash rust.sh 
```

#### 一键安装C环境

- 一键安装C++环境
- 支持系统：使用apt或者yum作为包管理器的系统
- 如果未安装则安装，如果有安装则提示升级

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/install_scripts/cplusplus.sh -o cplusplus.sh && chmod +x cplusplus.sh && bash cplusplus.sh 
```

#### 一键安装vnstat环境

- 支持系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
- 加载官方文件编译安装，前置条件适配系统以及后置条件判断安装的版本

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/install_scripts/vnstat.sh -o vnstat.sh && chmod +x vnstat.sh && bash vnstat.sh 
```

#### 一键升级低版本debian为debian11

- 支持系统：debian 6+
- 升级后需要重启系统加载内核，升级过程中需要选择的都无脑按回车即可
- 升级是一个版本迭代一个版本，所以如果版本低，每执行一次升级一个版本，直至升级到debian11

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/install_scripts/todebian11.sh -o todebian11.sh && chmod +x todebian11.sh && bash todebian11.sh
```

#### 一键升级低版本ubuntu为ubuntu22

- 支持系统：Ubuntu 16+
- 升级后需要重启系统加载内核，升级过程中需要选择的都无脑按回车即可
- 升级是一个版本迭代一个版本，所以如果版本低，每执行一次升级一个版本，直至升级到ubuntu22

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/install_scripts/toubuntu22.sh -o toubuntu22.sh && chmod +x toubuntu22.sh && bash toubuntu22.sh
```

#### 一键安装zipline平台

- 应该支持的系统：Ubuntu 18+，Debian 8+，centos 7+，Fedora，Almalinux 8.5+
- 暂时只在Ubuntu上验证无问题
- 如若要设置反向代理绑定域名，安装前请保证原服务器未安装过nginx，如若已安装过nginx，请自行配置反向代理本机的3000端口
- 默认一路回车是不启用反代不安装nginx的，自行选择，如需通过本脚本配置反代系统一定要未安装过nginx并在填写y或Y开启安装
- [zipline](https://github.com/diced/zipline) 平台功能: ShareX，自定义短链接，文件上传分享，多用户校验，高亮显示，阅后即焚，设置简单 (含pastebin)
- 自动安装docker，docker-compose，如若已安装zipline在/root目录下，则自动更新
- 反向代理如若已设置成功，还需要在面板设置中填写域名，绑定启用

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/install_scripts/zipline.sh -o zipline.sh && chmod +x zipline.sh && bash zipline.sh
```

如果需要删除0字节文件，打开```/root/zipline```文件夹，执行

```
docker-compose exec zipline yarn scripts:clear-zero-byte
```

按照提示操作

#### 一键安装filebrowser平台

- 端口设置为3030了，其他登陆信息详见提示
- [filebrowser](https://github.com/filebrowser/filebrowser)平台支持下载上传文件到服务器，批量下载多个文件(自定义压缩格式)，构建文件分享链接，设置分享时长
- 如果本地有启用IPV6优先级可能绑定到V6去了，使用```lsof -i:3030```查看绑定情况，切换优先级后再安装就正常了

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/install_scripts/filebrowser.sh -o filebrowser.sh && chmod +x filebrowser.sh && bash filebrowser.sh
```

#### 一键删除平台监控

- 一键移除大多数云服务器监控
- 涵盖阿里云、腾讯云、华为云、UCLOUD、甲骨文云

```bash
curl -L https://raw.githubusercontent.com/spiritLHLS/one-click-installation-script/main/install_scripts/dlm.sh -o dlm.sh && chmod +x dlm.shh && bash dlm.sh
```

## 部分手动命令

### 一键开启root登陆并替换密码

```
bash <(curl -sSL https://raw.githubusercontent.com/fscarmen/tools/main/root.sh) [PASSWORD]
```

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
查看并设置语言包

language-pack-en-base 在debian中好像没有，只有Ubuntu有好像，不知道是不是个例，有问题再说

### ubuntu更新源被锁

```bash
sudo rm -rf /var/cache/apt/archives/lock
sudo pkill apt
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock
sudo dpkg --configure -a
```

然后重启系统

### debian缺失公钥

```bash
apt-get install debian-keyring debian-archive-keyring -y
```

### ubuntu或debian缺失公钥

后续这块有计划整理为一个一键脚本

```bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 公钥
```

### centos换源

```bash
sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
sudo sed -i 's/^mirrorlist=http/mirrorlist=https/' /etc/yum.repos.d/CentOS-Base.repo
```

### 安装gitea

Ubuntu 20无问题，Ubuntu 22好像不行

https://gitlab.com/packaging/gitea

### 卸载aapanel

```bash
apt install sysv-rc-conf -y && service bt stop && sysv-rc-conf bt off && rm -f /etc/init.d/bt && rm -rf /www/server/panel
```

### 安装docker和docker-compose

```bash
curl -sSL https://get.docker.com/ | sh
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

## 友链

#### 一键测试服务器的融合怪脚本

https://github.com/spiritLHLS/ecs

#### 一键批量开NAT服务器LXC

https://github.com/spiritLHLS/lxc

#### 一键安装PVE

https://github.com/spiritLHLS/pve

#### 朋友fscarmen的常用一键工具仓库

https://github.com/fscarmen/tools
