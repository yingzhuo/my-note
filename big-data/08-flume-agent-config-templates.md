## Flume配置文件模板

```conf
###############################################################################
# Basic
###############################################################################
myagent.sources = mysource
myagent.channels = mychannel
myagent.sinks = mysink

###############################################################################
# Source
###############################################################################

# ----
# netcat
# ----
myagent.sources.mysource.type = netcat
myagent.sources.mysource.bind = 0.0.0.0
myagent.sources.mysource.port = 6666

# ---
# avro
# ---
myagent.sources.mysource.type = avro
myagent.sources.mysource.bind = 0.0.0.0
myagent.sources.mysource.port = 4141

###############################################################################
# Interceptor
###############################################################################

# ---
# static
# ---
myagent.sources.mysource.interceptors = i1
myagent.sources.mysource.interceptors.i1.type = static
myagent.sources.mysource.interceptors.i1.key = datacenter
myagent.sources.mysource.interceptors.i1.value = NEW_YORK

###############################################################################
# Channel Selector
###############################################################################

# ---
# replicating (default)
# ---
myagent.sources.mysource.selector.type = replicating
# myagent.sources.mysource.selector.optional = mychannel

# ---
# multiplexing 
# ---
myagent.sources.mysource.selector.type = multiplexing
myagent.sources.mysource.selectorheader = state
myagent.sources.mysource.selectormapping.CZ = c1
myagent.sources.mysource.selectormapping.US = c2 c3
myagent.sources.mysource.selectordefault = c4

###############################################################################
# Channel
###############################################################################

# ---
# memory
# ---
myagent.channels.mychannel.type = memory
myagent.channels.mychannel.capacity = 1024

# ---
# kafka
# ---
myagent.channels.mychannel.type = org.apache.flume.channel.kafka.KafkaChannel
myagent.channels.mychannel.kafka.bootstrap.servers = xxx.xxx.xx.xxx:9092,xxx.xxx.xx.xxx:9092,xxx.xxx.xx.xxx:9092
myagent.channels.mychannel.kafka.topic = flume-channel
myagent.channels.mychannel.kafka.group.id = flume

###############################################################################
# Sink
###############################################################################

# ---
# logger
# ---
myagent.sinks.mysink.type = logger

# ---
# file roll
# ---
myagent.sinks.mysink.type = file_roll
myagent.sinks.mysink.sink.directory = /var/log/flume

# ---
# avro
# ---
myagent.sinks.mysink.type = avro
myagent.sinks.mysink.hostname = xxx.xxx.xx.xxx
myagent.sinks.mysink.port = 6666

# ---
# null
# ---
myagent.sinks.mysink.type = null

# ---
# hdfs
# ---
myagent.sinks.mysink.type = hdfs
myagent.sinks.mysink.hdfs.path = hdfs://192.168.99.130:8020/%{application}/log/%{type}/%Y-%m-%d
myagent.sinks.mysink.hdfs.useLocalTimeStamp = true
myagent.sinks.mysink.hdfs.fileType = CompressedStream
myagent.sinks.mysink.hdfs.codeC = lzop
myagent.sinks.mysink.hdfs.fileSuffix = .lzo
myagent.sinks.mysink.hdfs.writeFormat = Text
myagent.sinks.mysink.hdfs.round = true
myagent.sinks.mysink.hdfs.rollInterval = 600
myagent.sinks.mysink.hdfs.rollSize = 268435456
myagent.sinks.mysink.hdfs.rollCount = 0
myagent.sinks.mysink.hdfs.timeZone = Asia/Shanghai

###############################################################################
# Assemble
###############################################################################
myagent.sources.mysource.channels = mychannel
myagent.sinks.mysink.channel = mychannel
```

#### 参考

* [Flume官方文档](https://flume.apache.org/releases/content/1.9.0/FlumeUserGuide.html)
