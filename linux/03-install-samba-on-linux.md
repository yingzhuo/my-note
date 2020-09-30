## 在Linux上安装samba服务

安装软件

```bash
sudo apt-get install samba -y
```

check软件是否成功启动

```bash
sudo systemctl status smbd
```

配置

```bash
sudo vim /etc/samba/smb.conf
```

在文件最后加入

```text
[sambashare]
    comment = Samba on Ubuntu
    path = /mnt/sambashare
    read only = no
    browsable = yes
```

重启服务

```bash
sudo systemctl restart smbd
```

设置密码

```bash
sudo smbpasswd -a <username>
```

> **注意:** Username used must belong to a system account, else it won’t save.
