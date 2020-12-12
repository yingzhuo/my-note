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

如果需要，可以适当更新`$FLUME_HOME/conf/log4j.properties`

#### (4) 编写你的Agent配置文件

这里只是所谓做一下演示 `$FLUME_HOME/myagent.conf`

```conf
myagent.sources = mysource
myagent.channels = mychannel
myagent.sinks = mysink

###############################################################################
# Source(s)
###############################################################################
myagent.sources.mysource.type = avro
myagent.sources.mysource.bind = 0.0.0.0
myagent.sources.mysource.port = 4141

myagent.sources.mysource.selector.type = replicating

###############################################################################
# Channel(s)
###############################################################################

# kafka 实现
myagent.channels.mychannel.type = org.apache.flume.channel.kafka.KafkaChannel
myagent.channels.mychannel.kafka.bootstrap.servers = 192.168.99.127:9092,192.168.99.128:9092,192.168.99.129:9092
myagent.channels.mychannel.kafka.topic = flume-channel
myagent.channels.mychannel.kafka.group.id = flume

###############################################################################
# Sink(s)
############################################################################### 
myagent.sinks.mysink.type = hdfs
myagent.sinks.mysink.hdfs.path = hdfs://192.168.99.130:8020/flume/%{application}/%{logtype}/%Y-%m-%d
myagent.sinks.mysink.hdfs.useLocalTimeStamp = true
myagent.sinks.mysink.hdfs.fileType = DataStream
myagent.sinks.mysink.hdfs.writeFormat = Text
myagent.sinks.mysink.hdfs.round = true
myagent.sinks.mysink.hdfs.rollInterval = 0
myagent.sinks.mysink.hdfs.rollSize = 134217700
myagent.sinks.mysink.hdfs.rollCount= 0

###############################################################################
# Assemble
###############################################################################
myagent.sources.mysource.channels = mychannel
myagent.sinks.mysink.channel = mychannel
```

#### (5) 启动

```bash
flume-ng agent \
     --name myagent \
     --conf /var/lib/flume/conf \
     --conf-file /var/lib/flume/myagent.conf
```

#### (8) systemd

`/etc/systemd/system/flume.service`

```service
[Unit]
Description=Flume agent
Documentation=https://flume.apache.org/
Requires=network.target
After=network.target

[Service]
User=root
Group=root
Type=simple
Environment="JAVA_HOME=/var/lib/java8"
Environment="HADOOP_HOME=/opt/hadoop"
ExecStart=/var/lib/flume/bin/flume-ng agent \
    --name myagent \
    --conf /var/lib/flume/conf \
    --conf-file /var/lib/flume/myagent.conf
KillSignal=15

[Install]
WantedBy=multi-user.target
```

#### (9) 高可用

那就用`keepalived`吧。

#### 参考

* [logback-flume-appender](https://github.com/yingzhuo/logback-flume-appender)

