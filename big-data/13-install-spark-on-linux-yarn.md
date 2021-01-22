## 安装Spark (YARN)

Hadoop Version: 3.1.4
Spark Version: 2.4.7

#### (1) 编译Spark

请参考另外的[文章](05-hive-on-spark.md)

#### (2) 安装Spark

解压Spark到`/opt/spark`

#### (3) 配置

##### 3.1 yarn配置微调 (可选)

因为测试环境虚拟机内存较少，防止执行过程进行被意外杀死，做如下配置

`$HADOOP_HOME/etc/hadoop/yarn-site.xml`

```xml
    <!-- 添加如下配置 -->

    <!--是否启动一个线程检查每个任务正使用的物理内存量，如果任务超出分配值，则直接将其杀掉，默认是true -->
    <property>
         <name>yarn.nodemanager.pmem-check-enabled</name>
         <value>false</value>
    </property>
    
    <!--是否启动一个线程检查每个任务正使用的虚拟内存量，如果任务超出分配值，则直接将其杀掉，默认是true -->
    <property>
         <name>yarn.nodemanager.vmem-check-enabled</name>
         <value>false</value>
    </property>
```

##### 3.2 spark相关环境

`$SPARK_HOME/conf/spark-env.sh`

```
export JAVA_HOME=/var/lib/java8

export SPARK_DIST_CLASSPATH=$(hadoop classpath)

export YARN_CONF_DIR=/opt/hadoop/etc/hadoop

export SPARK_HISTORY_OPTS="
-Dspark.history.ui.port=18080
-Dspark.history.fs.logDirectory=hdfs://ubuntu00:8020/spark-history
-Dspark.history.retainedApplications=45"
```

##### 3.3 spark模式配置

`$SPARK_HOME/conf/spark-defaults`

```text
spark.eventLog.enabled            true
spark.eventLog.dir                hdfs://ubuntu00:8020/spark-history
spark.driver.memory               2g
spark.executor.memory             2g

spark.yarn.historyServer.address  ubuntu00:18080
spark.history.ui.port             18080
```

#### (4) 开启日志服务

```bash
cd $SPARK_HOME

sbin/start-history-server.sh
```

#### (5) 测试

```bash
cd $SPARK_HOME

bin/spark-submit \
    --class org.apache.spark.examples.SparkPi \
    --master yarn \
    --deploy-mode client \
    ./examples/jars/spark-examples_2.11-2.4.7.jar \
    10
```
