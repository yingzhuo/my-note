## 在Linux安装Hadoop (伪分布)

#### (1) 安装JDK

本文档不再赘述，安装好以后JAVA_HOME为: `/var/lib/java8`

#### (2) 创建用户

```bash
sudo adduser hdoop
```

```bash
su - hdoop
```

#### (3) 配置无需密码的SSH登录

```bash
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/id_rsa
```

#### (4) 下载和安装

下载hadoop-3.2.1，并解压。

配置环境变量

```bash
# Hadoop
export HADOOP_HOME=/home/hdoop/hadoop-home
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
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

<!-- Put site-specific property overrides in this file. -->

<configuration>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/home/hdoop/data/tmp</value>
    </property>
    <property>
        <name>fs.default.name</name>
        <value>hdfs://127.0.0.1:9000</value>
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

<!-- Put site-specific property overrides in this file. -->

<configuration>
    <property>
        <name>dfs.data.dir</name>
        <value>/home/hdoop/data/namenode</value>
    </property>
    <property>
        <name>dfs.data.dir</name>
        <value>/home/hdoop/data/datanode</value>
    </property>
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

<!-- Put site-specific property overrides in this file. -->

<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
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

<!-- Site specific YARN configuration properties -->
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>127.0.0.1</value>
    </property>
    <property>
        <name>yarn.acl.enable</name>
        <value>0</value>
    </property>
    <property>
        <name>yarn.nodemanager.env-whitelist</name>■■■
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PERPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
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
