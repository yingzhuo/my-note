## CentOS设置静态IP地址

`sudo vim /etc/sysconfig/network-scripts/<网卡名>`

```text
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
NAME="enp0s5"
UUID="61ea8b74-2d5c-4bfe-8539-ba8ae0c21a92"
DEVICE="enp0s5"
ONBOOT=yes
IPADDR=10.211.55.200
NETMASK=255.255.255.0
```

`sudo vim /etc/sysconfig/network`

```text
NETWORKING=yes
GATEWAY=10.211.55.1
```

`sudo vim /etc/resolv.conf`

```text
nameserver 114.114.114.114
nameserver 8.8.8.8
nameserver 8.8.4.4
```

```bash
sudo systemctl restart NetworkManager
route add default gw <网关地址>
```