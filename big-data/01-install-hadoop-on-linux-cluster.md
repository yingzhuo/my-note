## 在Linux安装Hadoop集群

#### (1) 准备机器3台

hostname    | ip address         | OS                 | user:group           | role
----------|----------------------|--------------------|----------------------|--------------------------------------------
hadoop000  | 192.168.99.127      | Ubuntu 20.04.1 LTS | hadoop:hadoop        | NameNode,DataNode,NodeManager,JobHistoryServer
hadoop001  | 192.168.99.128      | Ubuntu 20.04.1 LTS | hadoop:hadoop        | DataNode,ResourceManager,NodeManager,DataNode
hadoop002  | 192.168.99.129      | Ubuntu 20.04.1 LTS | hadoop:hadoop        | SecondaryNameNode,NodeManager,DataNode

#### (2) hosts编排

`/etc/hosts`

```
# 注意三台机器都应添加
192.168.99.127  hadoop000
192.168.99.128  hadoop001
192.168.99.129  hadoop002
```

#### (3) 免密登录

必须保证hadoop000可以免密登录到`hadoop@hadoop001`和`hadoop@hadoop002`。请使用`ssh-copy-id`。
同时三台机器的`~hadoop/.ssh/id_rsa`请保持访问权限为`400`。

```bash
chmod 400 ~/.ssh/id_rsa
```

#### (4) 安装JDK

本文档不再赘述，安装好以后JAVA_HOME为: `/var/lib/java8`

####(5)安装HADOOP

下载`hadoop-3.2.1.tar.gz`并解压缩到`/var/lib/hadoop/`并配置环境变量，并使其生效。

```bash
# Hadoop
export HADOOP_HOME=/var/lib/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export HADOOP_DATA_DIR=/var/data/hadoop
```

#### (6) 为hadoop设置JAVA_HOME

编辑`$HADOOP_HOME/etc/hadoop/hadoop-env.sh` 指定以下几项

* `JAVA_HOME`
* `HADOOP_HOME`

#### (7) 创建数据目录

以下脚本简单为之:

```bash
#!/bin/bash -e

rm -rf $HADOOP_DATA_DIR
mkdir -p $HADOOP_DATA_DIR
sudo chown -R hadoop:hadoop $HADOOP_DATA_DIR
```

3台机器都需要创建数据目录。

#### (8) 编辑配置文件

##### 8.1 `$HADOOP_HOME/etc/hadoop/core-site.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://hadoop000:8020</value>
    </property>
    <property>
        <name>hadoop.data.dir</name>
        <value>/var/data/hadoop</value> <!-- 务必按实际情况修改 -->
    </property>

    <!-- 代理用户 -->
    <property>
        <name>hadoop.http.staticuser.user</name>
        <value>用户名</value>
    </property>
    <property>
        <name>hadoop.proxyuser.用户名.hosts</name>
        <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.用户名.groups</name>
        <value>*</value>
    </property>
</configuration>
```

##### 8.2 `$HADOOP_HOME/etc/hadoop/hdfs-site.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file://${hadoop.data.dir}/name</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file://${hadoop.data.dir}/data</value>
    </property>
    <property>
        <name>dfs.namenode.checkpoint.dir</name>
        <value>file://${hadoop.data.dir}/namesecondary</value>
    </property>
    <property>
        <name>dfs.client.datanode-restart.timeout</name>
        <value>30</value>
    </property>
    <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>hadoop002:9868</value>
    </property>

    <!-- 默认值依然是30秒，此配置为了解决HIVE的bug -->
    <property>
        <name>dfs.client.datanode-restart.timeout</name>
        <value>30</value>
    </property>

    <!-- 关闭权限检查 -->
    <property>
        <name>dfs.permissions.enabled</name>
        <value>false</value>
    </property>
</configuration>
```

##### 8.3 `$HADOOP_HOME/etc/hadoop/yarn-site.xml`

```xml
<?xml version="1.0"?>
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>hadoop001</value>
    </property>
    <property>
        <name>yarn.nodemanager.env-whitelist</name>
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
    </property>

    <property>
        <name>yarn.log-aggregation-enable</name>
        <value>true</value>
    </property>
    <property>
        <name>yarn.log.server.url</name>
        <value>http://hadoop000:19888/jobhistory/logs</value>
    </property>
    <property>
        <name>yarn.log-aggregation.retain-seconds</name>
        <value>604800</value>
    </property>
</configuration>
```

##### 8.4 `$HADOOP_HOME/etc/hadoop/mapred-site.xml`

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.jobhistory.address</name>
        <value>hadoop000:10020</value>
    </property>
    <property>
        <name>mapreduce.jobhistory.webapp.address</name>
        <value>hadoop000:19888</value>
    </property>
</configuration>
```

##### 8.5 `$HADOOP_HOME/etc/hadoop/workers`

```text
hadoop000
hadoop001
hadoop002
```

#### (9) 初始化NameNode

```bash
hdfs namenode -format
```

#### (10) 启动集群

在`hadoop000`上:

```bash
$HADOOP_HOME/sbin/start-dfs.sh
```

在`hadoop001`上:

```bash
$HADOOP_HOME/sbin/start-yarn.sh
```
