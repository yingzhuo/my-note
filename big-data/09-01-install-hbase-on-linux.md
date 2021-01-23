## 在Linux上安装HBase

#### (1) 安装JDK

本文档不再赘述，安装好以后JAVA_HOME为: `/var/lib/java8`

#### (2) 安装Zookeeper

安装好zookeeper并保证其正常运行。参考:

* [cluster](02-01-install-zookeeper-on-linux-cluster.md)
* [standalone](02-02-install-zookeeper-on-linux-standalone.md)

#### (3) 安装Hadoop集群

安装好hadoop并保证其正常运行。参考:

* [cluster](01-01-install-hadoop-on-linux-cluster.md)
* [standalone](02-02-install-zookeeper-on-linux-standalone.md)

#### (4) 安装HBase

下载文件并解压到`/var/lib/hbase`目录。

配置环境变量

```bash
# flume
export HBASE_HOME=/var/lib/hbase
export PATH=$PATH:HBASE_HOME/bin
```

#### ~~(5) 调整~~

```bash
rm -rf $HBASE_HOME/lib/client-facing-thirdparty/slf4j-log4j12-*.jar
```

#### (6) 配置文件

1) `vim $HBASE_HOME/conf/hbase-env.sh`

```bash
export HBASE_MANAGES_ZK=false  # 修改此行使用外部zk
```

2) `vim $HBASE_HOME/conf/regionservers`

```bash
localhost
```

3) `vim $HBASE_HOME/conf/hbase-site.xml`

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <!-- cluster -->
    <property>
        <name>hbase.cluster.distributed</name>
        <value>true</value>
    </property>
    <property>
        <name>hbase.tmp.dir</name>
        <value>/data/hbase</value>
    </property>

    <!-- hdfs -->
    <property>
        <name>hbase.rootdir</name>
        <value>hdfs://localhost:9000/hbase</value>
    </property>

    <!-- zk -->
    <property>
        <name>hbase.zookeeper.quorum</name>
        <value>10.211.55.3</value>
    </property>
    <property>
        <name>hbase.zookeeper.property.clientPort</name>
        <value>2181</value>
    </property>

    <property>
        <name>hbase.unsafe.stream.capability.enforce</name>
        <value>false</value>
    </property>
    <property>
        <name>hbase.wal.provider</name>
        <value>filesystem</value>
    </property>
</configuration>
```

#### (6) 启动 & 关闭

```bash
$HBASE_HOME/bin/start-hbase.sh
$HBASE_HOME/bin/stop-hbase.sh
```

#### (7) 高可用

新增配置文件`$HBASE_HOME/conf/backup-masters`，内容如下:

```txt
10.211.55.4
```