## 安装安全的Cluster集群

#### (1) 准备签名工具

在github上下载[cfssl工具](https://github.com/cloudflare/cfssl)，只需下载`cfssl`,`cfssljson`两个工具即可。笔者这里用的是1.5.0版本。
注意要给这两个工具可执行权限。

#### (2) 生成签名

可使用一下脚本放在`/tmp`下并执行

```bash
#!/usr/bin/env bash

cd /tmp

# 失效时间为100年
cat > ca-config.json << EOF
{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "www": {
         "expiry": "876000h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ]
      }
    }
  }
}
EOF

cat > ca-csr.json << EOF
{
    "CN": "etcd CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Shanghai",
            "ST": "Shanghai"
        }
    ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca -

# hosts里要包换集群所有的IP地址
cat > server-csr.json << EOF
{
    "CN": "etcd",
    "hosts": [
        "10.211.55.3"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Shanghai",
            "ST": "Shanghai"
        }
    ]
}
EOF

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=www server-csr.json | cfssljson -bare server

mv ca.pem ca.crt
mv server-key.pem server.key
mv server.pem server.crt

rm -rf *.json *.csr *.pem
```

脚本执行之后，`ca.crt`, `server.key`, `server.crt`有用，保存到`$ETCD_HOME/certs/`，其他文件无用，删除即可。

#### (3) systemctl 准备

准备配置文件 `$ETCD_HOME/etcd.conf`

```bash
# [Member]
ETCD_NAME=node
ETCD_LISTEN_PEER_URLS="https://10.211.55.3:2380"
ETCD_LISTEN_CLIENT_URLS="https://10.211.55.3:2379"

# [Clustering]
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER="node=https://10.211.55.3:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://10.211.55.3:2380"

# [SSL]
ETCD_ADVERTISE_CLIENT_URLS="https://10.211.55.3:2379"
ETCD_TRUSTED_CA_FILE="/opt/etcd/certs/ca.crt"
ETCD_KEY_FILE="/opt/etcd/certs/server.key"
ETCD_CERT_FILE="/opt/etcd/certs/server.crt"

ETCD_PEER_CLIENT_CERT_AUTH=true
ETCD_PEER_TRUSTED_CA_FILE="/opt/etcd/certs/ca.crt"
ETCD_PEER_KEY_FILE="/opt/etcd/certs/server.key"
ETCD_PEER_CERT_FILE="/opt/etcd/certs/server.crt"

# [Data]
ETCD_DATA_DIR="/data/etcd"

# [Log]
# ETCD_LOGGER="zap"
```

准备`/etc/systemd/system/etcd.service`

```service
[Unit]
Description=ETCD server
Documentation=https://etcd.io/
Requires=network.target
After=network.target

[Service]
Type=simple
EnvironmentFile=/opt/etcd/etcd.conf
ExecStart=/opt/etcd/bin/etcd
KillSignal=15
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

通过以上两个文件，读者一定看出来了，笔者的ETCD_HOME实际是`/opt/etcd`

启动服务

```bash
sudo systemctl daemon-reload
sudo systemctl start etcd
sudo systemctl enable etcd
```

#### (4) 测试

配置环境变量并使其生效

```bash
# server
export ETCD_HOME=/opt/etcd
export PATH=$PATH:$ETCD_HOME/bin

# client
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=https://10.211.55.3:2379
export ETCDCTL_CACERT=/opt/etcd/certs/ca.crt
export ETCDCTL_CERT=/opt/etcd/certs/server.crt
export ETCDCTL_KEY=/opt/etcd/certs/server.key
```

```bash
❯ etcdctl member list -w table
+------------------+---------+------+-------------------------+--------------------------+------------+
|        ID        | STATUS  | NAME |       PEER ADDRS        |       CLIENT ADDRS       | IS LEARNER |
+------------------+---------+------+-------------------------+--------------------------+------------+
| 29ae8f507898fed6 | started | node | http://10.211.55.3:2380 | https://10.211.55.3:2379 |      false |
+------------------+---------+------+-------------------------+--------------------------+------------+
```

#### (5) 设置密码

```bash
etcdctl user add root  # 命令行会要求你设置密码和确认密码
etcdctl auth enable
```

如果要求使用密码登录环境变量应添加

```bash
export ETCDCTL_USER="<用户名>:<密码>"
```
