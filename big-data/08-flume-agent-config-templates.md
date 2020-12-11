## Flume配置文件模板

#### netcat -> logfile

```conf
# ----------------------------------------
# agent: a1
# ----------
#  nc -> logger
# ----------------------------------------

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

#### file -> hdfs

```conf
# ----------------------------------------
# agent: a2
# ----------
#  file -> hdfs
# ----------------------------------------

a2.sources = r2
a2.channels = c2
a2.sinks = k2

a2.sources.r2.type = exec
a2.sources.r2.command = tail -F /var/log/playground/business/business-1.log
a2.sources.r2.channels = c2

a2.channels.c2.type = memory
a2.channels.c2.capacity = 1024

a2.sinks.k2.type = hdfs
a2.sinks.k2.hdfs.path = hdfs://localhost:9000/flume/playground/%Y%m%d
a2.sinks.k2.hdfs.useLocalTimeStamp = true
a2.sinks.k2.hdfs.filePrefix = logs-
a2.sinks.k2.hdfs.round = true
a2.sinks.k2.hdfs.roundValue = 1
a2.sinks.k2.hdfs.roundUnit = hour
a2.sinks.k2.hdfs.batchSize = 100
a2.sinks.k2.hdfs.fileType = DataStream
a2.sinks.k2.hdfs.rollInterval = 60
a2.sinks.k2.hdfs.rollSize = 134217700
a2.sinks.k2.hdfs.rollCount = 0
a2.sinks.k2.channel = c2
```
