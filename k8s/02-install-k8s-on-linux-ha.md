# 目标

本文档旨在帮助读者，通过`kubeadm`工具在Linux系统上顺利安装k8s (HAProxy和Keepalive实现高可用)。二进制安装方式请参考其他文档。

### 准备机器

角色        | 主机名        | IP地址 
-----------|--------------|------------------------------------
master 1   | master1      | 192.168.99.111
master 2   | master2      | 192.168.99.112
master 3   | master3      | 192.168.99.113
worker 1   | worker1      | 192.168.99.123
worker 2   | worker2      | 192.168.99.124
worker 3   | worker3      | 192.168.99.125
worker 4   | worker4      | 192.168.99.126
worker 5   | worker5      | 192.168.99.116

有几个注意事项：

* 主机名必须具有唯一性
* 所有机器预先安装好docker

**在安装过程中，请使用`root`账户。**

#### (1) 安装docker服务

篇幅有限，本文档不详细指导。请参考docker[官方文档](https://docs.docker.com/engine/install/)。

#### (2) 调整docker配置

编辑`/etc/docker/daemon` 内容如下:

```json
{
  "registry-mirrors": ["https://registry.docker-cn.com"],
  "insecure-registries": ["0.0.0.0"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "iptables": false,
  "dns": ["114.114.114.114", "8.8.8.8", "8.8.4.4"]
}
```

重启docker

```bash
sudo systemctl daemon-reload
sudo systemctl enable docker.service
sudo systemctl restart docker.service
```

#### (3) 安装kubeadm等

##### Ubuntu:

```bash 
sudo cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main
EOF

gpg --keyserver keyserver.ubuntu.com --recv-keys BA07F4FB
gpg --export --armor BA07F4FB | sudo apt-key add -
sudo apt-get update

sudo apt-get install kubeadm kubelet kubectl -y
```

##### CentOS:

```bash
sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

sudo chown root:root /etc/yum.repos.d/kubernetes.repo

sudo yum update -y

sudo yum install kubectl kubeadm kubelet -y
```

安装好以后，一定要检查kubelet守护进程是否正常启动

```bash
udo systemctl start kubelet.service
udo systemctl enable kubelet.service
```

#### (4) 前期准备

##### Ubuntu:

以下脚本务必运行一遍，并加入开机启动。

```bash
sudo swapoff -a
sudo modprobe br_netfilter
sudo echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
sudo echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
sudo sysctl -p
```

##### CentOS:

关闭swap

编辑`/etc/fstab`

```text
# 注释掉下面这一行
/dev/mapper/cl-swap     swap                    swap    defaults        0 0
```

关闭防火墙和SELinux

```bash
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

编辑`/etc/selinux/config`

```text
# 修改这一行
SELINUX=disabled
```

**CentOS下务必要重启**

#### (5) 通过"Keepalived"和"HAProxy" 构建搞可用集群。

* master1 为Keepalived的MASTER 配置文件`/etc/keepalived/keepalived.conf`

```conf
```

* master2 为Keepalived的BACKUP 配置文件`/etc/keepalived/keepalived.conf`

```conf
```

* master3 为Keepalived的BACKUP 配置文件`/etc/keepalived/keepalived.conf`

```conf
```

三台机器都要启动 keepalived

```bash
sudo systemctl enable --now haproxy.service
sudo systemctl enable --now keepalived.service
```

#### 参考

* [官方文档](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)
