## 在Linux上安装Flume

#### (1) 安装JDK

本文档不再赘述，安装好以后JAVA_HOME为: `/var/lib/java8`

#### (2) 安装

下载文件并解压到`/var/lib/flume`目录。

配置环境变量

```bash
# flume
export FLUME_HOME=/var/lib/flume
export PATH=$PATH:FLUME_HOME/bin
```

#### (3) 调整

如果本机上已经安装好了Hadoop并已经有生效的环境变量。 应当删除`$FLUME_HOME/lib/guava-*.jar`。或升级其版本与Hadoop3依赖的guava版本一致。

#### (4) 编写你的Agent

这里只是所谓做一下演示 `$FLUME_HOME/agents/a1.conf`

```conf
a1.sources = r1
a1.channels = c1
a1.sinks = k1

a1.sources.r1.type = netcat
a1.sources.r1.bind = localhost
a1.sources.r1.port = 44444
a1.sources.r1.channels = c1

a1.channels.c1.type = memory
a1.channels.c1.capacity = 1024

a1.sinks.k1.type = logger
a1.sinks.k1.channel = c1
```

#### (5) 启动

```bash
flume-ng agent \
     --name a1 \
     --conf /opt/flume/conf \
     --conf-file /opt/flume/agents/a1.conf \
     -Dflume.root.logger=INFO,console
```

#### (8) systemd

`/etc/systemd/system/kafka.service`

```service
[Unit]
Description=Flume agent (a1)
Documentation=https://flume.apache.org/
Requires=network.target
After=network.target

[Service]
User=root
Group=root
Type=simple
EnvironmentFile=/etc/flume/flume.env
ExecStart=/var/lib/flume/bin/flume-ng agent \
    --name a1 \
    --conf /var/lib/flume/conf \
    --conf-file /var/lib/flume/agents/a1.conf \
    -Dflume.root.logger=INFO,console
KillSignal=15

[Install]
WantedBy=multi-user.target
```

注意: 在 `/etc/flume/flume.env` 中指定好 `JAVA_HOME`和`HADOOP_HOME`。
