## 在Linux上编译安装redis (集群)

#### (1) gcc 准备

```bash
# centos
sudo yum install -y gcc
gcc --version

# ubuntu
sudo yum install -y gcc
gcc --version
```

如果gcc版本号为`4.8.x` 则需要调整。

```bash
sudo yum install -y centos-release-scl devtoolset-7 llvm-toolset-7
scl enable devtoolset-7 llvm-toolset-7 bash
```

#### (2) 编译

```bash
wget "https://download.redis.io/releases/redis-6.0.9.tar.gz" -o redis.tgz
tar xzf redis.tgz
cd redis-6.0.9
make
```

#### (4) 编排redis目录

```txt
/opt/redis
├── bin
│   ├── redis-benchmark
│   ├── redis-check-aof
│   ├── redis-check-rdb
│   ├── redis-cli
│   ├── redis-sentinel
│   ├── redis-server
│   ├── redis-trib.rb
│   └── setup-cluster.bash
├── cluster-cnf
└── config
    ├── redis6379.conf
    ├── redis6380.conf
    └── redis.conf.bak
```

#### (5) systemd

##### 5.1 redis6379.conf

```conf
# -----------------------------------------------------------------------------
# 通用
# -----------------------------------------------------------------------------

# 占用端口
port 6379

# 非保护模式
protected-mode no

# 守护进程模式
daemonize no

# APPEND ONLY 模式
appendonly yes
appendfilename "appendonly.aof"

# 数据目录
dir /var/data/redis/6379

# pid
pidfile /opt/redis/redis6379.pid

# 密码
requirepass root

# -----------------------------------------------------------------------------
# 集群
# -----------------------------------------------------------------------------

# 启用集群模式
cluster-enabled yes

# 集群配置文件，文件由redis-server进程创建并管理
cluster-config-file /opt/redis/cluster-cnf/nodes-6379.conf

# 集群超时时间 (毫秒)
cluster-node-timeout 10000
```

##### 5.2 redis6380.conf

```config
# -----------------------------------------------------------------------------
# 通用
# -----------------------------------------------------------------------------

# 占用端口
port 6380

# 非保护模式
protected-mode no

# 守护进程模式
daemonize no

# APPEND ONLY 模式
appendonly yes
appendfilename "appendonly.aof"

# 数据目录
dir /var/data/redis/6380

# pid
pidfile /opt/redis/redis6380.pid

# 密码
requirepass root

# -----------------------------------------------------------------------------
# 集群
# -----------------------------------------------------------------------------

# 启用集群模式
cluster-enabled yes

# 集群配置文件，文件由redis-server进程创建并管理
cluster-config-file /opt/redis/cluster-cnf/nodes-6380.conf

# 集群超时时间 (毫秒)
cluster-node-timeout 10000
```

##### 5.3 /etc/systemd/system/redis6379.service

```service
[Unit]
Description=Redis server
Documentation=https://redis.io/
Requires=network.target
After=network.target

[Service]
Type=simple
ExecStart=/opt/redis/bin/redis-server /opt/redis/config/redis6379.conf
ExecStop=/opt/redis/bin/redis-cli --no-auth-warning -a root -h 127.0.0.1 -p 6379 shutdown
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

##### 5.4 /etc/systemd/system/redis6380.service

```service
[Unit]
Description=Redis server
Documentation=https://redis.io/
Requires=network.target
After=network.target

[Service]
Type=simple
ExecStart=/opt/redis/bin/redis-server /opt/redis/config/redis6379.conf
ExecStop=/opt/redis/bin/redis-cli --no-auth-warning -a root -h 127.0.0.1 -p 6379 shutdown
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

#### 5.5 启动

```bash
sudo systemctl daemon-reload
sudo systemctl start redis6379
sudo systemctl start redis6380
```

#### 启动集群

在另外两个节点上也分别启动两个实例

```bash
/opt/redis/bin/redis-cli \
  -a root \
  --no-auth-warning \
  --cluster create \
    192.168.99.130:6379 \
    192.168.99.130:6380 \
    192.168.99.131:6379 \
    192.168.99.131:6380 \
    192.168.99.132:6379 \
    192.168.99.132:6380 \
  --cluster-replicas 1
```
