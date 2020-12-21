## 在Linux上安装Sqoop

#### (1) 安装JDK

本文档不再赘述，安装好以后JAVA_HOME为: `/var/lib/java8`

#### (2) 安装sqoop

解压到`/opt/sqoop`, 并配置环境变量

```bash
# Sqoop
export SQOOP_HOME=/opt/sqoop
export PATH=$PATH:$SQOOP_HOME/bin
```

#### (3) 调整配置

`$SQOOP_HOME/conf/`

```bash
export JAVA_HOME=/var/lib/java8

#Set path to where bin/hadoop is available
export HADOOP_COMMON_HOME=/opt/hadoop

#Set path to where hadoop-*-core.jar is available
export HADOOP_MAPRED_HOME=/opt/hadoop

#set the path to where bin/hbase is available
export HBASE_HOME=/opt/hbase

#Set the path to where bin/hive is available
export HIVE_HOME=/opt/hive

#Set the path for where zookeper config dir is
#export ZOOCFGDIR=
```

#### (4) 验证

```bash
sqoop list-databases \
    -connect jdbc:mysql://localhost:3306/ \
    --username root \
    --password root
```
