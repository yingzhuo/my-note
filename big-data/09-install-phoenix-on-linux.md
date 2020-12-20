## 在Linux上安装Phoenix

#### (0) 参考前文，正常启动Hadoop/HBase

参考:

* [hadoop-cluster](01-install-hadoop-on-linux-cluster.md)
* [hadoop-standalone](02-install-zookeeper-on-linux-standalone.md)
* [hbase-cluster](09-install-hbase-on-linux.md)

#### (1) 安装python2.x版本

如果没有安装，请自行安装。并设置软连接 /usr/bin/python -> /usr/bin/python2

```bash
sudo apt install -y python2
```

#### (2) 安装phoenix

解压到`/var/lib/phoenix`

#### (3) 配置环境变量

```bash
PHOENIX_HOME=/var/lib/phoenix
PATH=$PATH:PHOENIX_HOME/bin
```

#### (4) 调整和重启HBase

```bash
cp $PHOENIX_HOME/phoenix-5.0.0-HBase-2.0-client.jar $HBASE_HOME/lib/
cp $PHOENIX_HOME/phoenix-5.0.0-HBase-2.0-server.jar $HBASE_HOME/lib/
```

```bash
$HBASE_HOME/bin/stop-hbase.sh
$HBASE_HOME/bin/start-hbase.sh
```

#### (5) 启动phoenix (query-server)

```bash
# query server
queryserver.py start

# 客户端
sqlline.py zoo00,zoo01,zoo02:2181
```

#### (6) 使用DBearer

* 驱动类型: `org.apache.phoenix.queryserver.client.Driver`
* URL模板: `jdbc:phoenix:thin:url=http://{host}:{port};serialization=PROTOBUF`
* 默认端口: `8756`
* 驱动包Maven坐标: `org.apache.phoenix:phoenix-queryserver-client:5.0.0-HBase-2.0`
