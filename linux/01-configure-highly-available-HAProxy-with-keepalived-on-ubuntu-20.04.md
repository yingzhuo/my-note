## 通过Keepalived实现高可用 (Ubuntu 20.04)

machine        | hostname      | ip                | State
---------------|---------------|-------------------|----------
Ubuntu 20.04   | mockingbird   | 10.211.55.3       | MASTER
Ubuntu 20.04   | thunderbird   | 10.211.55.4       | BACKUP

**vip:** 10.211.55.99

### 安装`keepalived`和`haproxy`

```bash
sudo apt-get install haproxy -y
sudo apt-get install keepalived -y
```

### 配置IP转发

```bash
sudo vim /etc/sysctl.conf
```

```conf
# 这一行取消注释
net.ipv4.ip_forward=1
```

```bash
sudo sysctl -p
```

### 配置keepalived

MASTER: ↓↓↓

编辑`/etc/keepalived/keepalived.conf`，内容如下:

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

# 检查脚本以确认应用playground是否在正常工作
vrrp_script chk_app {
    script "/home/yingzhuo/dco-service/playground/chk-playground.sh"
    interval 2
    weight 2
}

# Configuration for Virtual Interface
vrrp_instance LB_VIP {
    state MASTER  #角色
    interface enp0s5 #网卡
    virtual_router_id 54
    priority 100  #权值
    mcast_src_ip 10.211.55.3 #真实IP

    authentication {
        auth_type PASS
        auth_pass haproxy123
    }

    track_script {
        chk_haproxy
        chk_app
    }

    virtual_ipaddress {
        10.211.55.99  #虚拟IP
    }
}
```

BACKUP: ↓↓↓

编辑`/etc/keepalived/keepalived.conf`，内容如下:

```config
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

# 检查脚本以确认应用playground是否在正常工作
vrrp_script chk_app {
    script "/home/yingzhuo/dco-service/playground/chk-playground.sh"
    interval 2
    weight 2
}

# Configuration for Virtual Interface
vrrp_instance LB_VIP {
    state BACKUP  #角色
    interface enp0s5  #网卡
    virtual_router_id 54
    priority 90  #权值 (BACKUP稍低于MASTER)
    mcast_src_ip 10.211.55.4  #真实IP

    authentication {
        auth_type PASS
        auth_pass haproxy123
    }

    track_script {
        chk_haproxy
        chk_app
    }

    virtual_ipaddress {
        10.211.55.99  #虚拟IP
    }
}
```

### 重启服务

```bash
sudo systemctl daemon-reload
sudo systemctl restart keepalived.service
```

### 应用程序检查脚本参考

```bash
#!/usr/bin/env bash
#  (1) 本脚本一定要有可执行权限
#  (2) playground是一个基于spring-boot开发的Java应用程序。

url=http://localhost:8080/actuator/health/readiness

status_code=$(curl --write-out %{http_code} --silent --output /dev/null $url)

if [[ "$status_code" -ne 200 ]] ; then
  echo "ERROR"
  echo "status: $status_code"

  # 关闭keepalived
  /usr/bin/systemctl stop keepalived.service
  exit 1
else
  echo "OK"
  exit 0
fi
```

### 参考
* [https://kifarunix.com/configure-highly-available-haproxy-with-keepalived-on-ubuntu-20-04/](https://kifarunix.com/configure-highly-available-haproxy-with-keepalived-on-ubuntu-20-04/)
