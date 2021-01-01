## 在Hadoop安装Hive服务

本文档所有操作都在NameNode节点上完成!

#### (1) 安装mysql供hive存储元数据

笔者实际使用docker/docker-compose启动的mysql-5.7.x实例。如需安装mysql实例，可以自行安装。

#### (2) 解压压缩包

得到两个目录

* `/var/lib/tez`
* `/var/lib/hive`

配置环境变量，并使环境变量生效

```bash
export TEZ_HOME=/var/lib/tez

export HIVE_HOME=/var/lib/hive
export PATH=$PATH:$HIVE_HOME/bin
```

#### (3) 调整杂项

* 删除`$HIVE_HOME/lib/log4j-sfl4j-impl-x.x.x.jar`
* 拷贝java-jdbc-driver到`$HIVE_HOME/lib`
* 升级hive依赖的guava.jar到`guava-27.0-jre.jar` (需要从maven中央仓库下载)
* 删除`$TEZ/lib/slf4j-log4j12-x.x.x.jar`

#### (4) 配置

* `$HIVE_HOME/conf/hive-site.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://192.168.99.114:3306/hive_metastore?useSSL=false</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>com.mysql.jdbc.Driver</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>root</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>root</value>
    </property>
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
    </property>
    <property>
        <name>hive.metastore.schema.verification</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://hadoop000:9083</value>
    </property>
    <property>
        <name>hive.server2.thrift.port</name>
        <value>10000</value>
    </property>
    <property>
        <name>hive.server2.thrift.bind.host</name>
        <value>hadoop000</value>
    </property>
    <property>
        <name>hive.server2.enable.doAs</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.metastore.event.db.notification.api.auth</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.execution.engine</name>
        <value>tez</value>
    </property>
    <!-- 客户端设置 -->
    <property>
        <name>hive.cli.print.header</name>
        <value>true</value>
    </property>
    <property>
        <name>hive.cli.print.current.db</name>
        <value>true</value>
    </property>
</configuration>
```

* `$HADOOP_HOME/etc/hadoop/tez-site.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>tez.lib.uris</name>
        <value>${fs.defaultFS}/tez/tez.tar.gz</value>
    </property>
    <property>
        <name>tez.use.cluster.hadoop-libs</name>
        <value>false</value>
    </property>
    <property>
        <name>tez.history.logging.service.class</name>
        <value>org.apache.tez.dag.history.logging.ats.ATSHistoryLoggingService</value>
    </property>
</configuration>
```

* `$HADOOP_HOME/etc/hadoop/hadoop-env.sh` (追加)

```bash
export TEZ_CONF_DIR=$HADOOP_HOME/etc/hadoop
export TEZ_JARS=/var/lib/tez
export HADOOP_CLASSPATH="$HADOOP_CLASSPATH:$TEZ_CONF_DIR:$TEZ_JARS/*:$TEZ_JARS/lib/*"
```

#### (5) 初始化MySQL表结构

> **注意**: 要先创建数据库

```bash
schematool -initSchema -dbType mysql -verbose
```

#### (6) 准备tez必要的依赖和HDFS所需的目录

上传`$TEZ_HOME/share/tez.tar.gz`到HDFS的目录`/tez`

```bash
hadoop fs -mkdir -p /tez
hadoop fs -put $TEZ_HOME/share/tez.tar.gz /tez
hadoop fs -mkdir -p /tmp
hadoop fs -chmod g+w /tmp

hadoop fs -mkdir -p /user/hive/warehouse
hadoop fs -chmod g+w /user/hive/warehouse
```

#### (7) 启动hive

使用如下脚本方便：

```bash
#!/usr/bin/env bash

HIVE_LOG_DIR=$HIVE_HOME/logs

mkdir -p $HIVE_LOG_DIR

#检查进程是否运行正常，参数1为进程名，参数2为进程端口
function check_process()
{
    pid=$(ps -ef 2>/dev/null | grep -v grep | grep -i $1 | awk '{print $2}')
    ppid=$(netstat -nltp 2>/dev/null | grep $2 | awk '{print $7}' | cut -d '/' -f 1)
    echo $pid
    [[ "$pid" =~ "$ppid" ]] && [ "$ppid" ] && return 0 || return 1
}

function hive_start()
{
    metapid=$(check_process HiveMetastore 9083)
    cmd="nohup hive --service metastore >$HIVE_LOG_DIR/metastore.log 2>&1 &"
    cmd=$cmd" sleep 4; hdfs dfsadmin -safemode wait >/dev/null 2>&1"
    [ -z "$metapid" ] && eval $cmd || echo "Metastroe服务已启动"
    server2pid=$(check_process HiveServer2 10000)
    cmd="nohup hive --service hiveserver2 >$HIVE_LOG_DIR/hiveServer2.log 2>&1 &"
    [ -z "$server2pid" ] && eval $cmd || echo "HiveServer2服务已启动"
}

function hive_stop()
{
    metapid=$(check_process HiveMetastore 9083)
    [ "$metapid" ] && kill $metapid || echo "Metastore服务未启动"
    server2pid=$(check_process HiveServer2 10000)
    [ "$server2pid" ] && kill $server2pid || echo "HiveServer2服务未启动"
}

case $1 in
"start")
    hive_start
    ;;
"stop")
    hive_stop
    ;;
"restart")
    hive_stop
    sleep 2
    hive_start
    ;;
"status")
    check_process HiveMetastore 9083 >/dev/null && echo "Metastore服务运行正常" || echo "Metastore服务运行异常"
    check_process HiveServer2 10000 >/dev/null && echo "HiveServer2服务运行正常" || echo "HiveServer2服务运行异常"
    ;;
*)
    echo Invalid Args!
    echo 'Usage: '$(basename $0)' start|stop|restart|status'
    ;;
esac
```