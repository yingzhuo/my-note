## 在Linux上安装samba服务

#### 创建用户`samba`和共享目录

```bash
sudo useradd samba
sudo mkdir -p /mnt/sambashare/public
sudo mkdir -p /mnt/sambashare/private
sudo chown -R samba:samba /mnt/sambashare/public
sudo chown -R samba:samba /mnt/sambashare/private
```

#### 安装软件

```bash
sudo apt-get install samba -y
```

check软件是否成功启动

```bash
sudo systemctl status smbd
```

#### 配置

```bash
sudo vim /etc/samba/smb.conf
```

在文件最后加入

```text
[public]
  comment = Samba on Ubuntu (public)
  path = /mnt/sambashare/public
  read only = no
  browsable = yes
  guest ok = yes
  create mask = 0660
  directory mask = 0771

[private]
  comment = Samba on Ubuntu (private)
  path = /mnt/sambashare/private
  read only = no
  browsable = yes
  guest ok = no
  valid users = samba
  create mask = 0660
  directory mask = 0771
```

#### 重启服务

```bash
sudo systemctl restart smbd
```

#### 设置密码

```bash
sudo smbpasswd -a samba
```
