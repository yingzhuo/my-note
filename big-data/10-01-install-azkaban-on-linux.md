## 在Linux上安装Azkaban

#### (1) 安装JDK

本文档不再赘述，安装好以后JAVA_HOME为: `/var/lib/java8`

#### (2) 安装Azkaban

解压到`/opt/azkaban`

目录结构如下:

```text
/opt/azkaban
├── executor
│   ├── azkaban.version
│   ├── bin
│   │   ├── azkaban-executor-shutdown.sh
│   │   ├── azkaban-executor-start.sh
│   │   └── start-exec.sh
│   ├── conf
│   │   ├── azkaban.private.properties
│   │   ├── azkaban.properties
│   │   └── global.properties
│   ├── executions
│   ├── extlib
│   ├── lib
│   ├── plugins
│   ├── projects
│   └── temp
├── sql-backup
└── web
    ├── azkaban.version
    ├── bin
    │   ├── azkaban-web-shutdown.sh
    │   ├── azkaban-web-start.sh
    │   ├── schedule2trigger.sh
    │   └── start-web.sh
    ├── conf
    │   ├── azkaban.properties
    │   └── azkaban-users.xml
    ├── executions
    ├── extlib
    ├── keystore
    ├── lib
    ├── plugins
    ├── projects
    ├── temp
    └── web
```

#### (3) 准备数据库

初始化脚本为: `/opt/azkaban/sql-backup/create-all-sql-2.5.0.sql`

#### (4) 调整配置

1) 生成SSL需要的keystore， 注意密码不宜过于复杂

```bash
cd /opt/azkaban/web
keytool -keystore keystore -alias jetty -genkey -keyalg RSA
```

2) 配置用户: `/opt/azkaban/web/conf/azkaban-users.xml`

笔者创建一个名为`root`的用户，

```xml
<user username="root" password="root" roles="admin,metrics"/>
```

3) 配置web服务器: `/opt/azkaban/web/conf/azkaban.properties`

**注意**: 笔者在配置文件里所有的文件和目录都是用的绝对路径。

配置大项有三个:

* SSL信息
* 时区
* MySQL信息

4) 配置executor服务器：`/opt/azkaban/executor/conf/azkaban.properties`

**注意**: 笔者在配置文件里所有的文件和目录都是用的绝对路径。

配置大项有三个:

* 时区
* MySQL信息

#### (5) 启动与关闭

```bash
# web服务器
/opt/azkaban/web/bin/azkaban-web-start.sh
/opt/azkaban/web/bin/azkaban-web-shutdown.sh

# executor服务器
/opt/azkaban/executor/bin/azkaban-executor-start.sh
/opt/azkaban/executor/bin/azkaban-executor-shutdown.sh
```

#### (6) systemd

**WEB**

```service
[Unit]
Description=Azkaban web server
Documentation=https://github.com/azkaban/azkaban
Requires=network.target
After=network.target

[Service]
Type=forking
User=root
Group=root
EnvironmentFile=/etc/azkaban/azkaban.env
WorkingDirectory=/opt/azkaban/web
ExecStart=/opt/azkaban/web/bin/azkaban-web-start.sh
ExecStop=/opt/azkaban/web/bin/azkaban-web-shutdown.sh

[Install]
WantedBy=multi-user.target
```

**EXECUTOR**

```service
[Unit]
Description=Azkaban executor server
Documentation=https://github.com/azkaban/azkaban
Requires=network.target
After=network.target

[Service]
Type=forking
User=root
Group=root
EnvironmentFile=/etc/azkaban/azkaban.env
WorkingDirectory=/opt/azkaban/executor
ExecStart=/opt/azkaban/executor/bin/azkaban-executor-start.sh
ExecStop=/opt/azkaban/executor/bin/azkaban-executor-shutdown.sh

[Install]
WantedBy=multi-user.target
```

**/etc/azkaban/azkaban.env**

```text
JAVA_HOME=/var/lib/java8
HADOOP_HOME=/opt/hadoop
HIVE_HOME=/opt/hive
HBASE_HOME=/opt/hbase
```
