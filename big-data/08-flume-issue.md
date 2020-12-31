## Flume踩坑记录

#### (一) .lzo 文件不能正常关闭

发现情况Flume上传到HDFS上的文件没有被正常关闭。文件始终处于`OPENFORWRITE`状态。

```bash
# 查看文件的状态
hdfs fsck /xxx/2020-12-31/aaa.lzo.tmp -openforwrite | grep OPENFORWRITE
```

`OPENFORWRITE`状态的文件扩展名为`.tmp`并且无法正常为其生成LZO索引。

这是HDFSSink没有正常滚动。最好的解决办法是合理设置按时间滚动的节奏。

如:

```conf
myagent.sinks.mysink.type = hdfs
myagent.sinks.mysink.hdfs.path = hdfs://192.168.99.130:8020/%{application}/log/%{type}/%Y-%m-%d
myagent.sinks.mysink.hdfs.useLocalTimeStamp = true
myagent.sinks.mysink.hdfs.fileType = CompressedStream
myagent.sinks.mysink.hdfs.codeC = lzop
myagent.sinks.mysink.hdfs.fileSuffix = .lzo
myagent.sinks.mysink.hdfs.writeFormat = Text
myagent.sinks.mysink.hdfs.round = true
myagent.sinks.mysink.hdfs.rollInterval = 3600
myagent.sinks.mysink.hdfs.rollSize = 268435456
myagent.sinks.mysink.hdfs.rollCount = 0
myagent.sinks.mysink.hdfs.timeZone = Asia/Shanghai
```

以上配置案例同时设置了两种滚动策略。

如果这种情况还是不幸地发生了，还是可以使用命令补救的。

```bash
hdfs debug recoverLease -path /xxx/2020-12-31/aaa.lzo.tmp -retries 10
```
