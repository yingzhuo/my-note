## 在Linux上安装ganglia

#### Ubuntu

1) 布置`ganglia`服务端

```bash
# 安装apache2
# 如有必要可以通过/etc/apache2/ports.conf调整占用端口
sudo apt-get install -y apache2

# 安装PHP
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update -y

sudo apt install -y php7.2 libapache2-mod-php7.2 php7.2-common php7.2-gmp php7.2-curl php7.2-intl php7.2-mbstring php7.2-xmlrpc php7.2-mysql php7.2-gd php7.2-xml php7.2-cli php7.2-zip

# 安装ganglia-master
sudo apt-get install -y \
    ganglia-monitor \
    gmetad \
    ganglia-webfrontend \
    rrdtool
```

编辑`/etc/ganglia/gmetad.conf`

```conf
data_source "ubuntu" 10.211.55.3 # 指定集群的名字
```

编辑`/etc/ganglia/gmond.conf`

```conf
cluster {
  name = "ubuntu"  # 此行注意要指定集群的名字
  owner = "unspecified"
  latlong = "unspecified"
  url = "unspecified"
}

udp_send_channel {
  # mcast_join = 10.211.55.3 # 注释掉此行
  host = 10.211.55.3
  port = 8649 
  ttl = 1
}

udp_recv_channel {
  # mcast_join = 10.211.55.3 # 注释掉此行
  port = 8649
  bind = 10.211.55.3 # 编辑此行
}

tcp_accept_channel {
  port = 8649
}
```

拷贝Ganglia配置文件到Apache服务器配置

```bash
sudo cp /etc/ganglia-webfrontend/apache.conf /etc/apache2/sites-enabled/ganglia.conf
```

2) 布置`ganglia`客户端

```bash
# 安装ganglia-client
# 注意apache2和php等不要安装
sudo apt-get install -y \
    ganglia-monitor
```

编辑文件 `/etc/ganglia/gmond.conf`

```conf
cluster {
  name = "ubuntu"  # 此行注意要指定集群的名字
  owner = "unspecified"
  latlong = "unspecified"
  url = "unspecified"
}

udp_send_channel {
  # mcast_join = 10.211.55.3 # 注释掉此行
  host = 10.211.55.3 # 这行应当是master的IP
  port = 8649 
  ttl = 1
}

udp_recv_channel {
  # mcast_join = 10.211.55.3 # 注释掉此行
  port = 8649
  bind = 10.211.55.4 # 编辑此行 这行应当是自己的IP
}
```
