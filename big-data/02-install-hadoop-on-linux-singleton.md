## 在Linux安装Hadoop (伪分布)

#### (1) 安装JDK

本文档不再赘述，安装好以后JAVA_HOME为: `/var/lib/java8`

> 注意: 请安装Oracle-JDK 8

#### (2) 创建用户

```bash
sudo adduser -m hadoop
```

```bash
su - hadoop
```

#### (3) 配置无需密码的SSH登录

```bash
rm -rf ~/.ssh/
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/id_rsa
```

#### (4) 下载和安装

下载hadoop-3.2.1，并解压。

配置环境变量

```bash
# Hadoop
export HADOOP_HOME=/var/lib/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_COMMON_LIB_NATIVE_DIR"
```

#### (5) 配置

##### 5.1 

```bash
vim $HADOOP_HOME/etc/hadoop/hadoop-env.sh
```

在这里务必要配置好`JAVA_HOME`

##### 5.2

```bash
vim $HADOOP_HOME/etc/hadoop/core-site.xml
```

内容:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://10.211.55.200:9000</value> <!-- 如果使用虚拟机需要换成虚拟机的地址 -->
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/data/hadoop</value>
    </property>
</configuration>
```

##### 5.3

```bash
vim $HADOOP_HOME/etc/hadoop/hdfs-site.xml
```

内容:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
```

##### 5.4

```bash
vim $HADOOP_HOME/etc/hadoop/mapred-site.xml
```

内容:

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.application.classpath</name>
        <value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>
    </property>
</configuration>
```

##### 5.5

```bash
vim $HADOOP_HOME/etc/hadoop/yarn-site.xml
```

内容:

```xml
<?xml version="1.0"?>
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.env-whitelist</name>
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
    </property>
</configuration>
```

#### (6) 初始化NameNode

```bash
hdfs namenode -format
```

#### (7) 启动

```bash
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh
```
