# hadoop启用历史服务器

`vim $HADOOP_HOME/etc/hadoop/mapred-site.xml`

添加如下: 

```xml
<!-- 历史服务器端地址 -->
<property>
    <name>mapreduce.jobhistory.address</name>
    <value>hadoop00:10020</value>
</property>
<property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>hadoop00:19888</value>
</property>
```

# 开启日志收集功能

`vim $HADOOP_HOME/etc/hadoop/yarn-site.xml`

添加如下: 

```xml
<property>
    <name>yarn.log-aggregation-enable</name>
    <value>true</value>
</property>
<property>  
    <name>yarn.log.server.url</name>  
    <value>http://hadoop00:19888/jobhistory/logs</value>  
</property>
<property>
    <name>yarn.log-aggregation.retain-seconds</name>
    <value>604800</value>
</property>
```

# 脚本

```bash
mapred --daemon start historyserver
mapred --daemon stop historyserver
```
