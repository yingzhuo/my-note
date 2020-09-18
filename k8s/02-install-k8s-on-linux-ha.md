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

#### (5) 通过"Keepalived"和"HAProxy" 构建高可用集群。

三台机器必须安装软件

```bash
sudo apt-get install keepalived haproxy -y
```

* master1 为Keepalived的MASTER 配置文件`/etc/keepalived/keepalived.conf`

```conf
! Configuration File for keepalived

# 全局配置
global_defs {
    keepalived_script {
        script_user root root
    }
}

# 检查脚本以确认haproxy是否在正常工作
vrrp_script chk_haproxy {
    script "/usr/bin/killall -0 haproxy"
    interval 2
    weight 2
}

# Configuration for Virtual Interface
vrrp_instance LB_VIP {
    state MASTER  #角色
    interface ens160 #网卡
    virtual_router_id 54
    priority 100  #权值
    mcast_src_ip 192.168.99.111 #真实IP

    authentication {
        auth_type PASS
        auth_pass haproxy123456
    }

    track_script {
        chk_haproxy
    }

    virtual_ipaddress {
        192.168.99.250  #虚拟IP
    }
}
```

* master2 为Keepalived的BACKUP 配置文件`/etc/keepalived/keepalived.conf`

```conf
! Configuration File for keepalived

# 全局配置
global_defs {
    keepalived_script {
        script_user root root
    }
}

# 检查脚本以确认haproxy是否在正常工作
vrrp_script chk_haproxy {
    script "/usr/bin/killall -0 haproxy"
    interval 2
    weight 2
}

# Configuration for Virtual Interface
vrrp_instance LB_VIP {
    state BACKUP  #角色
    interface ens160 #网卡
    virtual_router_id 54
    priority 90  #权值
    mcast_src_ip 192.168.99.112 #真实IP

    authentication {
        auth_type PASS
        auth_pass haproxy123456
    }

    track_script {
        chk_haproxy
    }

    virtual_ipaddress {
        192.168.99.250  #虚拟IP
    }
}
```

* master3 为Keepalived的BACKUP 配置文件`/etc/keepalived/keepalived.conf`

```conf
! Configuration File for keepalived

# 全局配置
global_defs {
    keepalived_script {
        script_user root root
    }
}

# 检查脚本以确认haproxy是否在正常工作
vrrp_script chk_haproxy {
    script "/usr/bin/killall -0 haproxy"
    interval 2
    weight 2
}

# Configuration for Virtual Interface
vrrp_instance LB_VIP {
    state BACKUP #角色
    interface ens160 #网卡
    virtual_router_id 54
    priority 80  #权值
    mcast_src_ip 192.168.99.113 #真实IP

    authentication {
        auth_type PASS
        auth_pass haproxy123456
    }

    track_script {
        chk_haproxy
    }

    virtual_ipaddress {
        192.168.99.250  #虚拟IP
    }
}
```

三台机器都要启动 keepalived

```bash
sudo systemctl enable --now haproxy.service
sudo systemctl enable --now keepalived.service
```

#### (6) 初始化master

在master1上执行:

```bash
kubeadm init \
    --kubernetes-version=v1.19.1 \
    --control-plane-endpoint=192.168.99.250:6443 \
    --image-repository=registry.cn-shanghai.aliyuncs.com/yingzhuo \
    --token=abcdef.0123456789abcdef \
    --token-ttl=0 \
    --upload-certs | tee ~/kubeadm.init.log
```

**注意**: `192.168.99.250` 事由keepalived生成的虚拟IP。

如果看到诸如以下的输出，则说明第一个master节点正常启动了。

```text
...
...
...
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join 192.168.99.250:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:9a336bc2dfad45db42521e1f2d55f129f9adb5ffa24187b6710d778f88abaeba \
    --control-plane --certificate-key 13891781cdf0cb2bbe2515b6b3fbd2119eb9efee8ebdd1faf9caeff55d1533ed

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.99.250:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:9a336bc2dfad45db42521e1f2d55f129f9adb5ffa24187b6710d778f88abaeba
```

安装网络add-on，笔者使用的是`weave`

```bash
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

待网络插件正常安装好以后，master2和master3应当加入集群。

```bash
  kubeadm join 192.168.99.250:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:9a336bc2dfad45db42521e1f2d55f129f9adb5ffa24187b6710d778f88abaeba \
    --control-plane --certificate-key 13891781cdf0cb2bbe2515b6b3fbd2119eb9efee8ebdd1faf9caeff55d1533ed
```

#### (7) worker节点加入集群

```bash
kubeadm join 192.168.99.250:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:9a336bc2dfad45db42521e1f2d55f129f9adb5ffa24187b6710d778f88abaeba
```

#### (8) 初始化kubectl所需的配置文件

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### (9) 确认安装结果

```text
❯ kubectl get node -o wide
NAME      STATUS   ROLES    AGE   VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
bear      Ready    master   18h   v1.19.1   192.168.99.113   <none>        Ubuntu 18.04.5 LTS   4.15.0-118-generic   docker://19.3.12
dog       Ready    <none>   17h   v1.19.1   192.168.99.126   <none>        Ubuntu 18.04.5 LTS   4.15.0-118-generic   docker://19.3.12
fox       Ready    <none>   18h   v1.19.1   192.168.99.122   <none>        Ubuntu 18.04.5 LTS   4.15.0-118-generic   docker://19.3.12
jackal    Ready    <none>   17h   v1.19.1   192.168.99.125   <none>        Ubuntu 18.04.5 LTS   4.15.0-118-generic   docker://19.3.12
leopard   Ready    <none>   18h   v1.19.1   192.168.99.123   <none>        Ubuntu 18.04.5 LTS   4.15.0-118-generic   docker://19.3.12
lion      Ready    master   18h   v1.19.1   192.168.99.112   <none>        Ubuntu 18.04.5 LTS   4.15.0-118-generic   docker://19.3.12
mule      Ready    <none>   18h   v1.19.1   192.168.99.116   <none>        Ubuntu 18.04.5 LTS   4.15.0-118-generic   docker://19.3.12
panda     Ready    <none>   17h   v1.19.1   192.168.99.124   <none>        Ubuntu 18.04.5 LTS   4.15.0-118-generic   docker://19.3.12
tiger     Ready    master   18h   v1.19.1   192.168.99.111   <none>        Ubuntu 18.04.5 LTS   4.15.0-118-generic   docker://19.3.12
```

#### 参考

* [官方文档](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)
