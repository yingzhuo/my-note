## 在Linux安装Zookeeper (standalone)

#### (1) 安装JDK

本文档不再赘述，安装好以后JAVA_HOME为: `/var/lib/java8`

#### (2) 安装

下载文件并解压到`/var/lib/zookeeper`目录。

配置环境变量

```bash
# ZOOKEEPER
export ZOOKEEPER_HOME=/var/lib/zookeeper
export PATH=$PATH:$ZOOKEEPER_HOME/bin
```

#### (3) 配置

`sudo vim $ZOOKEEPER_HOME/conf/zoo.cfg`

```text
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial■
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between■
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just■
# example sakes.
dataDir=/data/zookeeper/
# the port at which the clients will connect
clientPort=2181
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the■
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1

## Metrics Providers
#
# https://prometheus.io Metrics Exporter
#metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
#metricsProvider.httpPort=7000
#metricsProvider.exportJvmInfo=true

# Admin Server
admin.enableServer=false
```

#### (4) 启动

```bash
$ZOOKEEPER_HOME/bin/zkServer.sh start
$ZOOKEEPER_HOME/bin/zkServer.sh status
```

#### (5) 关闭JMS

文件: `$ZOOKEEPER_HOME/conf/zookeeper-env.sh`

```text
JMXLOCALONLY=false
JMXDISABLE=true
JMXPORT=4048
JMXAUTH=false
JMXSSL=false
```
