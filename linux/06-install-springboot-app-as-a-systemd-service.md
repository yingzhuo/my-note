## SpringBoot作为systemd服务安装到Linux

#### 假设

* (1) 应用名称playground
* (2) 安装位置`/var/lib/playground/playground.jar`

#### 安装

编辑启动脚本`/var/lib/playground/playground.sh`内容如下:

```bash
#!/bin/sh -e

/var/lib/java8/bin/java -jar /var/lib/playground/playground.jar --spring.profiles.active=dev
exit 0 
```

```bash
sudo chmod 700 /var/lib/playground/playground.sh
sudo chmod 600 /var/lib/playground/playground.jar
```

编辑`/etc/systemd/system/playground.service`

```text
[Unit]
Description=playground
After=syslog.target

[Service]
User=root
ExecStart=/var/lib/playground/playground.sh
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable playground.service
sudo systemctl start playground.service
sudo systemctl status playground.service
```
