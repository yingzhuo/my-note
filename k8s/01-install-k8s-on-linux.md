# 目标

本文档旨在帮助读者，通过`kubeadm`工具在Linux系统上顺利安装k8s。二进制安装方式请参考其他文档。

### 准备机器

角色       | 主机名        | IP地址 
----------|--------------|------------------------------------
master    | tiger        | 192.168.99.111
slave (1) | lion         | 192.168.99.112
slave (2) | bear         | 192.168.99.113

**在安装过程中，请使用`root`账户。**

#### (1) 安装docker服务

篇幅有限，本文档不详细指导。请参考docker[官方文档](https://docs.docker.com/engine/install/)。

#### (2) 调整docker配置

编辑`/etc/docker/daemon` 内容如下:

```json
{
  "registry-mirrors": ["https://registry.docker-cn.com"],
  "insecure-registries": ["<harbo 地址>"],
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
 #修改这一行
SELINUX=disabled
```

**CentOS下务必要重启**

#### (5) 初始化master节点

由于一些总所周知的原因，在中国大陆地区，无法正常获取谷歌云上的docker镜像。因此，笔者把kubeadm所需的镜像搬运到了阿里云。项目[在此](https://github.com/yingzhuo/kubeadm-inside-the-great-wall)。

```bash
kubeadm init \
	--kubernetes-version=v1.19.0 \
	--apiserver-advertise-address=192.168.99.111 \ # 广播地址
	--image-repository=registry.cn-shanghai.aliyuncs.com/yingzhuo \ # 阿里云
	--token=abcdef.0123456789abcdef \
	--token-ttl=0 | tee ~/.kubeadm.init.log
```

如果看到诸如以下的输出，则说明master节点正常启动了。

```text
...
...
...
Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join 192.168.99.111:6443 --token abcdef.0123456789abcdef \
  		--discovery-token-ca-cert-hash sha256:59d74f30d7d05c22ca4767b9e7de72b10242646b814183ef6fef1678abcafa48
```

按照提示执行以下命令，以正确使用kubectl命令。

```text
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### (6) 安装网络插件

```bash
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

#### (7) 其他节点加入集群

slave节点依然需要使用root账户

```bash
kubeadm join 192.168.99.111:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:59d74f30d7d05c22ca4767b9e7de72b10242646b814183ef6fef1678abcafa48
```

#### (8) 确认安装结果

```bash
kubectl get node -o wide
```

如下:

```text
NAME      STATUS     ROLES    AGE   VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
bear      Ready      <none>   12d   v1.19.0   192.168.99.113   <none>        Ubuntu 18.04.5 LTS   4.15.0-117-generic   docker://19.3.12
lion      Ready      <none>   12d   v1.19.0   192.168.99.112   <none>        Ubuntu 18.04.5 LTS   4.15.0-117-generic   docker://19.3.12
tiger     Ready      master   12d   v1.19.0   192.168.99.111   <none>        Ubuntu 18.04.5 LTS   4.15.0-117-generic   docker://19.3.12
```
