## Hive On Spark

Hadoop Version: 3.1.4
Hive Version: 3.1.2
Spark Version: 2.4.7

#### 准备好编译环境

* JDK-1.8
* Maven-3.6.3

#### 编译Spark

(1) 在spark官方网站下载Spark源码

[地址](https://spark.apache.org/downloads.html)

(2) 编译

```bash
cd $SOURCE_DIR

./dev/make-distribution.sh \
    --name without-hive \
    --tgz \
    -Pyarn \
    -Phadoop-3.1 \
    -Dhadoop.version=3.1.4 \
    -Pparquet-provided \
    -Porc-provided \
    -Phadoop-provided
```

**注意:** 由于编译时需要用到谷歌的maven仓库，记得要科学上网。

#### 编译Hive

(1) 在官方网站下载Hive源码

[地址](https://hive.apache.org/downloads.html)

(2) 编译

```bash
cd $SOURCE_DIR

mvn clean package \
    -Dspark.version=2.4.7 \
    -Dhadoop.version=3.1.4 \
    -DskipTests \
    -Pdist
```

**注意:** 笔者实操好像并不需要科学上网，但是科学上网了也无妨。

#### 安装Hive

(1) 将编译成功的hive解压到`/opt/hive`

配置环境变量并使其生效

```bash
export HIVE_HOME=/opt/hive
export PATH=$PATH:$HIVE_HOME/bin
```

(2) 将编译成功的spark解压到`/opt/spark`

配置环境变量并使其生效

```bash
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin
```

#### 微调依赖等

```bash
# 删除冲突的依赖
rm -rf $HIVE_HOME/lib/log4j-slf4j-impl-*.jar

# 删除guava
rm -rf $HIVE_HOME/lib/guava-*.jar

# 拷贝 mysql驱动到 $HIVE_HOME/lib/
# 拷贝 guava-27.0-jre.jar 到 $HIVE_HOME/lib/
```

#### 配置spark

`vim $SPARK_HOME/conf/spark-env.sh`

```bash
# 追加以下一行
export SPARK_DIST_CLASSPATH=$(hadoop classpath)
```

#### 配置hive

`vim $HIVE_HOME/conf/hive-site.xml`

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

    <!--
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://hadoop00:9083</value>
    </property>
    -->
    <property>
        <name>hive.server2.thrift.port</name>
        <value>10000</value>
    </property>
    <property>
        <name>hive.server2.thrift.bind.host</name>
        <value>hadoop00</value>
    </property>
    <property>
        <name>hive.server2.enable.doAs</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.metastore.event.db.notification.api.auth</name>
        <value>false</value>
    </property>

    <!--
    <property>
        <name>hive.execution.engine</name>
        <value>tez</value>
    </property>
    -->
    <property>
        <name>hive.execution.engine</name>
        <value>spark</value>
    </property>
    <property>
        <name>spark.yarn.jars</name>
        <value>hdfs://hadoop00:8020/lib/spark/*</value>
    </property>
</configuration>
```

`vim $HIVE_HOME/conf/spark-defaults.conf`

```text
spark.master           yarn
spark.eventLog.enabled true
spark.eventLog.dir     hdfs://hadoop00:8020/spark-history
spark.driver.memory    2g
spark.executor.memory  2g
```

#### 上传必要的文件到HDFS

```bash
hadoop fs -mkdir -p /spark-history
hadoop fs -mkdir -p /lib/spark
hadoop fs -put $SPARK_HOME/jars/* /lib/spark
```

#### 调整hadoop容量调度器

`vim $HADOOP_HOME/etc/hadoop/capacity-scheduler.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>

    <property>
        <name>yarn.scheduler.capacity.maximum-applications</name>
        <value>10000</value>
        <description>
            Maximum number of applications that can be pending and running.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.maximum-am-resource-percent</name>
        <value>0.1</value>
        <description>
            Maximum percent of resources in the cluster which can be used to run
            application masters i.e. controls number of concurrent running
            applications.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.resource-calculator</name>
        <value>org.apache.hadoop.yarn.util.resource.DefaultResourceCalculator</value>
        <description>
            The ResourceCalculator implementation to be used to compare
            Resources in the scheduler.
            The default i.e. DefaultResourceCalculator only uses Memory while
            DominantResourceCalculator uses dominant-resource to compare
            multi-dimensional resources such as Memory, CPU etc.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.root.queues</name>
        <value>default,hive</value>
        <description>
            The queues at the this level (root is the root queue).
        </description>
    </property>

    <!-- 本条为修改 -->
    <property>
        <name>yarn.scheduler.capacity.root.default.capacity</name>
        <value>50</value>
        <description>Default queue target capacity.</description>
    </property>

    <!-- 以下条为新增 -->
    <property>
        <name>yarn.scheduler.capacity.root.hive.capacity</name>
        <value>50</value>
        <description>
            hive队列的容量为50%
        </description>
    </property>
    <property>
        <name>yarn.scheduler.capacity.root.hive.user-limit-factor</name>
        <value>1</value>
        <description>
            一个用户最多能够获取该队列资源容量的比例
        </description>
    </property>
    <property>
        <name>yarn.scheduler.capacity.root.hive.maximum-capacity</name>
        <value>80</value>
        <description>
            hive队列的最大容量
        </description>
    </property>
    <property>
        <name>yarn.scheduler.capacity.root.hive.state</name>
        <value>RUNNING</value>
    </property>
    <property>
        <name>yarn.scheduler.capacity.root.hive.acl_submit_applications</name>
        <value>*</value>
        <description>
            访问控制，控制谁可以将任务提交到该队列
        </description>
    </property>
    <property>
        <name>yarn.scheduler.capacity.root.hive.acl_administer_queue</name>
        <value>*</value>
        <description>
            访问控制，控制谁可以管理(包括提交和取消)该队列的任务
        </description>
    </property>
    <property>
        <name>yarn.scheduler.capacity.root.hive.acl_application_max_priority</name>
        <value>*</value>
        <description>
            访问控制，控制用户可以提交到该队列的任务的最大优先级
        </description>
    </property>
    <property>
        <name>yarn.scheduler.capacity.root.hive.maximum-application-lifetime</name>
        <value>-1</value>
        <description>
            hive队列中任务的最大生命时长
        </description>
    </property>
    <property>
        <name>yarn.scheduler.capacity.root.hive.default-application-lifetime</name>
        <value>-1</value>
        <description>
            default队列中任务的最大生命时长
        </description>
    </property>
    <!-- 以上条为新增 -->

    <property>
        <name>yarn.scheduler.capacity.root.default.user-limit-factor</name>
        <value>1</value>
        <description>
            Default queue user limit a percentage from 0.0 to 1.0.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.root.default.maximum-capacity</name>
        <value>100</value>
        <description>
            The maximum capacity of the default queue.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.root.default.state</name>
        <value>RUNNING</value>
        <description>
            The state of the default queue. State can be one of RUNNING or STOPPED.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.root.default.acl_submit_applications</name>
        <value>*</value>
        <description>
            The ACL of who can submit jobs to the default queue.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.root.default.acl_administer_queue</name>
        <value>*</value>
        <description>
            The ACL of who can administer jobs on the default queue.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.root.default.acl_application_max_priority</name>
        <value>*</value>
        <description>
            The ACL of who can submit applications with configured priority.
            For e.g, [user={name} group={name} max_priority={priority} default_priority={priority}]
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.root.default.maximum-application-lifetime
        </name>
        <value>-1</value>
        <description>
            Maximum lifetime of an application which is submitted to a queue
            in seconds. Any value less than or equal to zero will be considered as
            disabled.
            This will be a hard time limit for all applications in this
            queue. If positive value is configured then any application submitted
            to this queue will be killed after exceeds the configured lifetime.
            User can also specify lifetime per application basis in
            application submission context. But user lifetime will be
            overridden if it exceeds queue maximum lifetime. It is point-in-time
            configuration.
            Note : Configuring too low value will result in killing application
            sooner. This feature is applicable only for leaf queue.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.root.default.default-application-lifetime
        </name>
        <value>-1</value>
        <description>
            Default lifetime of an application which is submitted to a queue
            in seconds. Any value less than or equal to zero will be considered as
            disabled.
            If the user has not submitted application with lifetime value then this
            value will be taken. It is point-in-time configuration.
            Note : Default lifetime can't exceed maximum lifetime. This feature is
            applicable only for leaf queue.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.node-locality-delay</name>
        <value>40</value>
        <description>
            Number of missed scheduling opportunities after which the CapacityScheduler
            attempts to schedule rack-local containers.
            When setting this parameter, the size of the cluster should be taken into account.
            We use 40 as the default value, which is approximately the number of nodes in one rack.
            Note, if this value is -1, the locality constraint in the container request
            will be ignored, which disables the delay scheduling.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.rack-locality-additional-delay</name>
        <value>-1</value>
        <description>
            Number of additional missed scheduling opportunities over the node-locality-delay
            ones, after which the CapacityScheduler attempts to schedule off-switch containers,
            instead of rack-local ones.
            Example: with node-locality-delay=40 and rack-locality-delay=20, the scheduler will
            attempt rack-local assignments after 40 missed opportunities, and off-switch assignments
            after 40+20=60 missed opportunities.
            When setting this parameter, the size of the cluster should be taken into account.
            We use -1 as the default value, which disables this feature. In this case, the number
            of missed opportunities for assigning off-switch containers is calculated based on
            the number of containers and unique locations specified in the resource request,
            as well as the size of the cluster.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.queue-mappings</name>
        <value></value>
        <description>
            A list of mappings that will be used to assign jobs to queues
            The syntax for this list is [u|g]:[name]:[queue_name][,next mapping]*
            Typically this list will be used to map users to queues,
            for example, u:%user:%user maps all users to queues with the same name
            as the user.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.queue-mappings-override.enable</name>
        <value>false</value>
        <description>
            If a queue mapping is present, will it override the value specified
            by the user? This can be used by administrators to place jobs in queues
            that are different than the one specified by the user.
            The default is false.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.per-node-heartbeat.maximum-offswitch-assignments</name>
        <value>1</value>
        <description>
            Controls the number of OFF_SWITCH assignments allowed
            during a node's heartbeat. Increasing this value can improve
            scheduling rate for OFF_SWITCH containers. Lower values reduce
            "clumping" of applications on particular nodes. The default is 1.
            Legal values are 1-MAX_INT. This config is refreshable.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.application.fail-fast</name>
        <value>false</value>
        <description>
            Whether RM should fail during recovery if previous applications'
            queue is no longer valid.
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.workflow-priority-mappings</name>
        <value></value>
        <description>
            A list of mappings that will be used to override application priority.
            The syntax for this list is
            [workflowId]:[full_queue_name]:[priority][,next mapping]*
            where an application submitted (or mapped to) queue "full_queue_name"
            and workflowId "workflowId" (as specified in application submission
            context) will be given priority "priority".
        </description>
    </property>

    <property>
        <name>yarn.scheduler.capacity.workflow-priority-mappings-override.enable</name>
        <value>false</value>
        <description>
            If a priority mapping is present, will it override the value specified
            by the user? This can be used by administrators to give applications a
            priority that is different than the one specified by the user.
            The default is false.
        </description>
    </property>
</configuration>
```

#### 重启

重启HDFS和YARN

#### 使用hive

注意事项:

* `set mapreduce.job.queuename=hive;`
