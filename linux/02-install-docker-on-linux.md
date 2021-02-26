## 在Linux上安装docker-engine

#### Ubuntu

```bash
# 删除旧版本 (可选)
sudo apt-get remove docker docker-engine docker.io containerd runc

# 更新apt源
sudo curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# 跟新依赖
sudo apt-get update

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# 安装
sudo apt-get install docker-ce

# 一般用户加入docker组
sudo usermod -aG docker $(whoami)
```

#### CentOS

```bash
# 删除旧版本 (可选)
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

# 更新yum源
sudo yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装
sudo yum install docker-ce

# 一般用户加入docker组
sudo usermod -aG docker $(whoami)
```

#### 配置参考

`/etc/docker/daemon.json`

```json
{
  "registry-mirrors": ["https://registry.docker-cn.com", "https://aih1ikpl.mirror.aliyuncs.com"],
  "insecure-registries" : ["0.0.0.0"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "iptables": false,
  "dns": ["114.114.114.114", "8.8.8.8", "8.8.4.4"]
}
```

不要忘记重启docker服务使配置生效

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker.service
```

#### 其他

建议一并安装[docker-compose](https://docs.docker.com/compose/install/)

#### 参考

* [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)