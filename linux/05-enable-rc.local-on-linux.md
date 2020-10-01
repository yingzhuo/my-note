## 在Linux上通过Systemd启用/etc/rc.local

#### Ubuntu

编辑`/etc/systemd/system/rc-local.service`

```bash
sudo vim /etc/systemd/system/rc-local.service
```

内容如下:

```text
[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target
```

```bash
sudo touch /etc/rc.local
sudo chown root:root /etc/rc.local
sudo chmod 755 /etc/rc.local
sudo chmod +x /etc/rc.local
sudo systemctl enable rc-local
sudo systemctl start rc-local
```

#### CentOS

```bash
sudo chmod +x /etc/rc.local
```
