## Hadoop lzo setup guide

#### 压缩/解压命令行工具

```bash
# mac os
brew install lzop lzo

# linux
sudo apt-get install lzop liblzo2-dev
```

#### hadoop

(1) Codec支持包: `hadoop-lzo-0.4.20.jar`

```bash
cp ./hadoop-lzo-0.4.20.jar $HADOOP_HOME/share/hadoop/common
```

(2) 配置文件 `$HADOOP_HOME/etc/hadoop/core-site.xml`

```xml
<property>
    <name>io.compression.codecs</name>
    <value>org.apache.hadoop.io.compress.GzipCodec,org.apache.hadoop.io.compress.DefaultCodec,org.apache.hadoop.io.compress.BZip2Codec,org.apache.hadoop.io.compress.SnappyCodec,com.hadoop.compression.lzo.LzoCodec,com.hadoop.compression.lzo.LzopCodec</value>
</property>
<property>
    <name>io.compression.codec.lzo.class</name>
    <value>com.hadoop.compression.lzo.LzoCodec</value>
</property>
```

(3) 重启hadoop集群

重启hdfs和yarn。

#### 测试

```bash
# 生成lzo索引文件
hadoop jar $HADOOP_HOME/share/hadoop/common/hadoop-lzo-0.4.20.jar com.hadoop.compression.lzo.DistributedLzoIndexer /hdfs/path/to/big_file.lzo

# 对big_file.lzo执行 WordCount
hadoop jar 
```
