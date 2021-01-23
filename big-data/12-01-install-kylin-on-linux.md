# 在Linux上安装Kylin

#### 版本选择

* Hadoop 3.1.4
* Hive 3.1.2 on Spark 2.4.7
* HBase 2.2.6
* Kylin 3.1.1

#### 安装

解压到`/opt/kylin`，并配置如下环境变量并使其生效。

```bash
export KYLIN_HOME=/opt/kylin
export PATH=$PATH:$KYLIN_HOME/bin
```

#### 前置条件

* 启动`hadoop-dfs`
* 启动`hadoop-yarn`
* 启动`hadoop-historyserver` 参考[这里](01-04-enable-historyserver.md)
* 启动`hbase`

#### 调整kylin启动脚本

`sudo vim $KYLIN_HOME/bin/find-hbase-dependency.sh`

大约39行处

```bash
# 修改成如下
result=`echo $data | grep -E 'hbase-(common|shaded\-client)[a-z0-9A-Z\.-]*jar' | grep -v tests`
```

#### 启动

```bash
kylin.sh start
```
